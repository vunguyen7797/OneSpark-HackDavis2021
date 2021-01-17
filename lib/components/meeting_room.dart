import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one_spark/components/participant_display.dart';
import 'package:twilio_programmable_video/twilio_programmable_video.dart';

class MeetingRoom with ChangeNotifier {
  final String name;
  final String token;
  final String identity;

  final StreamController<bool> _onAudioEnabledStreamController =
      StreamController<bool>.broadcast();
  Stream<bool> onAudioEnabled;
  final StreamController<bool> _onVideoEnabledStreamController =
      StreamController<bool>.broadcast();
  Stream<bool> onVideoEnabled;
  final StreamController<Map<String, bool>> _flashStateStreamController =
      StreamController<Map<String, bool>>.broadcast();
  Stream<Map<String, bool>> flashStateStream;
  final StreamController<Exception> _onExceptionStreamController =
      StreamController<Exception>.broadcast();
  Stream<Exception> onException;
  final StreamController<NetworkQualityLevel>
      _onNetworkQualityStreamController =
      StreamController<NetworkQualityLevel>.broadcast();
  Stream<NetworkQualityLevel> onNetworkQualityLevel;

  final Completer<Room> _completer = Completer<Room>();

  final List<ParticipantDisplay> _participants = [];
  final List<ParticipantBuffer> _participantBuffer = [];
  final List<StreamSubscription> _streamSubscriptions = [];
  final List<RemoteDataTrack> _dataTracks = [];
  final List<String> _messages = [];

  CameraCapturer _cameraCapturer;
  Room _room;
  Timer _timer;

  bool flashEnabled = false;

  MeetingRoom({
    @required this.name,
    @required this.token,
    @required this.identity,
  }) {
    onAudioEnabled = _onAudioEnabledStreamController.stream;
    onVideoEnabled = _onVideoEnabledStreamController.stream;
    flashStateStream = _flashStateStreamController.stream;
    onException = _onExceptionStreamController.stream;
    onNetworkQualityLevel = _onNetworkQualityStreamController.stream;
  }

  List<ParticipantDisplay> get participants {
    return [..._participants];
  }

  Future<Room> connect() async {
    try {
      await TwilioProgrammableVideo.debug(dart: true, native: true);
      await TwilioProgrammableVideo.setSpeakerphoneOn(true);

      _cameraCapturer = CameraCapturer(CameraSource.FRONT_CAMERA);
      var connectOptions = ConnectOptions(
        token,
        roomName: name,
        preferredAudioCodecs: [OpusCodec()],
        audioTracks: [LocalAudioTrack(true)],
        dataTracks: [LocalDataTrack()],
        videoTracks: [LocalVideoTrack(true, _cameraCapturer)],
        enableNetworkQuality: true,
        networkQualityConfiguration: NetworkQualityConfiguration(
          remote: NetworkQualityVerbosity.NETWORK_QUALITY_VERBOSITY_MINIMAL,
        ),
        enableDominantSpeaker: true,
      );

      _room = await TwilioProgrammableVideo.connect(connectOptions);

      _streamSubscriptions.add(_room.onConnected.listen(_onConnected));
      _streamSubscriptions
          .add(_room.onConnectFailure.listen(_onConnectFailure));
      _streamSubscriptions
          .add(_cameraCapturer.onCameraSwitched.listen(_onCameraSwitched));

      await _updateFlashState();

      return _completer.future;
    } catch (err) {
      rethrow;
    }
  }

  Future<void> disconnect() async {
    if (_timer != null) {
      _timer.cancel();
    }
    await _room.disconnect();
  }

  @override
  void dispose() {
    _disposeStreamsAndSubscriptions();
    super.dispose();
  }

  Future<void> _disposeStreamsAndSubscriptions() async {
    await _onAudioEnabledStreamController.close();
    await _onVideoEnabledStreamController.close();
    await _flashStateStreamController.close();
    await _onExceptionStreamController.close();
    await _onNetworkQualityStreamController.close();
    for (var streamSubscription in _streamSubscriptions) {
      await streamSubscription.cancel();
    }
  }

  Future<void> sendMessage(String message) async {
    final tracks = _room.localParticipant.localDataTracks;
    final localDataTrack = tracks.isEmpty ? null : tracks[0].localDataTrack;
    if (localDataTrack == null || _messages.isNotEmpty) {
      _messages.add(message);
      return;
    }
    await localDataTrack.send(message);
  }

  Future<void> sendBufferMessage(ByteBuffer message) async {
    final tracks = _room.localParticipant.localDataTracks;
    final localDataTrack = tracks.isEmpty ? null : tracks[0].localDataTrack;
    if (localDataTrack == null) {
      return;
    }
    await localDataTrack.sendBuffer(message);
  }

  Future<void> toggleVideoEnabled() async {
    final tracks = _room.localParticipant.localVideoTracks;
    final localVideoTrack = tracks.isEmpty ? null : tracks[0].localVideoTrack;
    if (localVideoTrack == null) {
      return;
    }
    await localVideoTrack.enable(!localVideoTrack.isEnabled);

    var index = _participants
        .indexWhere((ParticipantDisplay participant) => !participant.isRemote);
    if (index < 0) {
      return;
    }
    _participants[index] =
        _participants[index].copyWith(videoEnabled: localVideoTrack.isEnabled);

    _onVideoEnabledStreamController.add(localVideoTrack.isEnabled);
    notifyListeners();
  }

  Future<void> toggleMute(RemoteParticipant remoteParticipant) async {
    final enabled = await remoteParticipant
        .remoteAudioTracks.first.remoteAudioTrack
        .isPlaybackEnabled();
    remoteParticipant.remoteAudioTracks
        .forEach((remoteAudioTrackPublication) async {
      await remoteAudioTrackPublication.remoteAudioTrack
          .enablePlayback(!enabled);
    });

    var index = _participants.indexWhere((ParticipantDisplay participant) =>
        participant.id == remoteParticipant.sid);
    if (index < 0) {
      return;
    }
    _participants[index] =
        _participants[index].copyWith(audioEnabledLocally: !enabled);
    notifyListeners();
  }

  Future<void> toggleAudioEnabled() async {
    final tracks = _room.localParticipant.localAudioTracks;
    final localAudioTrack = tracks.isEmpty ? null : tracks[0].localAudioTrack;
    if (localAudioTrack == null) {
      return;
    }
    await localAudioTrack.enable(!localAudioTrack.isEnabled);

    var index = _participants
        .indexWhere((ParticipantDisplay participant) => !participant.isRemote);
    if (index < 0) {
      return;
    }
    _participants[index] =
        _participants[index].copyWith(audioEnabled: localAudioTrack.isEnabled);

    _onAudioEnabledStreamController.add(localAudioTrack.isEnabled);
    notifyListeners();
  }

  Future<void> switchCamera() async {
    try {
      await _cameraCapturer.switchCamera();
    } on FormatException catch (e) {}
  }

  Future<void> toggleFlashlight() async {
    await _cameraCapturer.setTorch(!flashEnabled);
    flashEnabled = !flashEnabled;
    await _updateFlashState();
  }

  void addDummy({Widget child}) {
    if (_participants.length >= 18) {
      throw PlatformException(
        code: 'ConferenceRoom.maximumReached',
        message: 'Maximum reached',
        details:
            'Currently the lay-out can only render a maximum of 18 participants',
      );
    }
    _participants.insert(
      0,
      ParticipantDisplay(
        id: (_participants.length + 1).toString(),
        child: child,
        isRemote: true,
        audioEnabled: true,
        videoEnabled: true,
        isDummy: true,
      ),
    );
    notifyListeners();
  }

  void removeDummy() {
    var dummy = _participants.firstWhere((participant) => participant.isDummy,
        orElse: () => null);
    if (dummy != null) {
      _participants.remove(dummy);
      notifyListeners();
    }
  }

  void _onConnected(Room room) {
    // When connected for the first time, add remote participant listeners
    _streamSubscriptions
        .add(_room.onParticipantConnected.listen(_onParticipantConnected));
    _streamSubscriptions.add(
        _room.onParticipantDisconnected.listen(_onParticipantDisconnected));
    _streamSubscriptions
        .add(_room.onDominantSpeakerChange.listen(_onDominantSpeakerChanged));
    // Only add ourselves when connected for the first time too.
    _participants.add(
      _buildParticipant(
          child: room.localParticipant.localVideoTracks[0].localVideoTrack
              .widget(),
          id: identity,
          audioEnabled: true,
          videoEnabled: true,
          networkQualityLevel: room.localParticipant.networkQualityLevel,
          onNetworkQualityChanged:
              room.localParticipant.onNetworkQualityLevelChanged),
    );

    for (final remoteParticipant in room.remoteParticipants) {
      var participant = _participants.firstWhere(
          (participant) => participant.id == remoteParticipant.sid,
          orElse: () => null);
      if (participant == null) {
        _addRemoteParticipantListeners(remoteParticipant);
      }
    }

    // We have to listen for the [onDataTrackPublished] event on the [LocalParticipant] in
    // order to be able to use the [send] method.
    _streamSubscriptions.add(room.localParticipant.onDataTrackPublished
        .listen(_onLocalDataTrackPublished));
    notifyListeners();
    _completer.complete(room);

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      // Let's see if we can send some data over the DataTrack API
      sendMessage('And another minute has passed since I connected...');
      // Also try the ByteBuffer way of sending data
      final list =
          'This data has been sent over the ByteBuffer channel of the DataTrack API'
              .codeUnits;
      var bytes = Uint8List.fromList(list);
      sendBufferMessage(bytes.buffer);
    });
  }

  void _onLocalDataTrackPublished(LocalDataTrackPublishedEvent event) {
    // Send buffered messages, if any...
    while (_messages.isNotEmpty) {
      var message = _messages.removeAt(0);

      event.localDataTrackPublication.localDataTrack.send(message);
    }
  }

  void _onConnectFailure(RoomConnectFailureEvent event) {
    _completer.completeError(event.exception);
  }

  void _onDominantSpeakerChanged(DominantSpeakerChangedEvent event) {
    var oldDominantParticipantIndex =
        _participants.indexWhere((p) => p.isDominant);
    if (oldDominantParticipantIndex >= 0) {
      _participants[oldDominantParticipantIndex] =
          _participants[oldDominantParticipantIndex]
              .copyWith(isDominant: false);
    }

    var newDominantParticipantIndex =
        _participants.indexWhere((p) => p.id == event.remoteParticipant.sid);
    _participants[newDominantParticipantIndex] =
        _participants[newDominantParticipantIndex].copyWith(isDominant: true);
    notifyListeners();
  }

  void _onParticipantConnected(RoomParticipantConnectedEvent event) {
    _addRemoteParticipantListeners(event.remoteParticipant);
  }

  void _onParticipantDisconnected(RoomParticipantDisconnectedEvent event) {
    _participants.removeWhere(
        (ParticipantDisplay p) => p.id == event.remoteParticipant.sid);
    notifyListeners();
  }

  Future _onCameraSwitched(CameraSwitchedEvent event) async {
    flashEnabled = false;
    await _updateFlashState();
  }

  Future _updateFlashState() async {
    var flashState = <String, bool>{
      'hasFlash': await _cameraCapturer.hasTorch(),
      'flashEnabled': flashEnabled,
    };
    _flashStateStreamController.add(flashState);
  }

  ParticipantDisplay _buildParticipant({
    @required Widget child,
    @required String id,
    @required bool audioEnabled,
    @required bool videoEnabled,
    @required NetworkQualityLevel networkQualityLevel,
    @required Stream<NetworkQualityLevelChangedEvent> onNetworkQualityChanged,
    RemoteParticipant remoteParticipant,
  }) {
    return ParticipantDisplay(
      id: remoteParticipant?.sid,
      isRemote: remoteParticipant != null,
      child: child,
      audioEnabled: audioEnabled,
      videoEnabled: videoEnabled,
      networkQualityLevel: networkQualityLevel,
      onNetworkQualityChanged: onNetworkQualityChanged,
      toggleMute: () => toggleMute(remoteParticipant),
    );
  }

  void _addRemoteParticipantListeners(RemoteParticipant remoteParticipant) {
    _streamSubscriptions.add(
        remoteParticipant.onAudioTrackDisabled.listen(_onAudioTrackDisabled));
    _streamSubscriptions.add(
        remoteParticipant.onAudioTrackEnabled.listen(_onAudioTrackEnabled));
    _streamSubscriptions.add(
        remoteParticipant.onAudioTrackPublished.listen(_onAudioTrackPublished));
    _streamSubscriptions.add(remoteParticipant.onAudioTrackSubscribed
        .listen(_onAudioTrackSubscribed));
    _streamSubscriptions.add(remoteParticipant.onAudioTrackSubscriptionFailed
        .listen(_onAudioTrackSubscriptionFailed));
    _streamSubscriptions.add(remoteParticipant.onAudioTrackUnpublished
        .listen(_onAudioTrackUnpublished));
    _streamSubscriptions.add(remoteParticipant.onAudioTrackUnsubscribed
        .listen(_onAudioTrackUnsubscribed));

    _streamSubscriptions.add(
        remoteParticipant.onDataTrackPublished.listen(_onDataTrackPublished));
    _streamSubscriptions.add(
        remoteParticipant.onDataTrackSubscribed.listen(_onDataTrackSubscribed));
    _streamSubscriptions.add(remoteParticipant.onDataTrackSubscriptionFailed
        .listen(_onDataTrackSubscriptionFailed));
    _streamSubscriptions.add(remoteParticipant.onDataTrackUnpublished
        .listen(_onDataTrackUnpublished));
    _streamSubscriptions.add(remoteParticipant.onDataTrackUnsubscribed
        .listen(_onDataTrackUnsubscribed));

    _streamSubscriptions.add(remoteParticipant.onNetworkQualityLevelChanged
        .listen(_onNetworkQualityChanged));

    _streamSubscriptions.add(
        remoteParticipant.onVideoTrackDisabled.listen(_onVideoTrackDisabled));
    _streamSubscriptions.add(
        remoteParticipant.onVideoTrackEnabled.listen(_onVideoTrackEnabled));
    _streamSubscriptions.add(
        remoteParticipant.onVideoTrackPublished.listen(_onVideoTrackPublished));
    _streamSubscriptions.add(remoteParticipant.onVideoTrackSubscribed
        .listen(_onVideoTrackSubscribed));
    _streamSubscriptions.add(remoteParticipant.onVideoTrackSubscriptionFailed
        .listen(_onVideoTrackSubscriptionFailed));
    _streamSubscriptions.add(remoteParticipant.onVideoTrackUnpublished
        .listen(_onVideoTrackUnpublished));
    _streamSubscriptions.add(remoteParticipant.onVideoTrackUnsubscribed
        .listen(_onVideoTrackUnsubscribed));
  }

  void _onAudioTrackDisabled(RemoteAudioTrackEvent event) {
    _setRemoteAudioEnabled(event);
  }

  void _onAudioTrackEnabled(RemoteAudioTrackEvent event) {
    _setRemoteAudioEnabled(event);
  }

  void _onAudioTrackPublished(RemoteAudioTrackEvent event) {}

  void _onAudioTrackSubscribed(RemoteAudioTrackSubscriptionEvent event) {
    _addOrUpdateParticipant(event);
  }

  void _onAudioTrackSubscriptionFailed(
      RemoteAudioTrackSubscriptionFailedEvent event) {
    _onExceptionStreamController.add(
      PlatformException(
        code: 'ConferenceRoom.audioTrackSubscriptionFailed',
        message: 'AudioTrack Subscription Failed',
        details: event.exception.toString(),
      ),
    );
  }

  void _onAudioTrackUnpublished(RemoteAudioTrackEvent event) {}

  void _onAudioTrackUnsubscribed(RemoteAudioTrackSubscriptionEvent event) {}

  void _onDataTrackPublished(RemoteDataTrackEvent event) {}

  void _onDataTrackSubscribed(RemoteDataTrackSubscriptionEvent event) {
    final dataTrack = event.remoteDataTrackPublication.remoteDataTrack;
    _dataTracks.add(dataTrack);
    _streamSubscriptions.add(dataTrack.onMessage.listen(_onMessage));
    _streamSubscriptions
        .add(dataTrack.onBufferMessage.listen(_onBufferMessage));
  }

  void _onDataTrackSubscriptionFailed(
      RemoteDataTrackSubscriptionFailedEvent event) {
    _onExceptionStreamController.add(
      PlatformException(
        code: 'ConferenceRoom.dataTrackSubscriptionFailed',
        message: 'DataTrack Subscription Failed',
        details: event.exception.toString(),
      ),
    );
  }

  void _onDataTrackUnpublished(RemoteDataTrackEvent event) {}

  void _onDataTrackUnsubscribed(RemoteDataTrackSubscriptionEvent event) {}

  void _onNetworkQualityChanged(RemoteNetworkQualityLevelChangedEvent event) {}

  void _onVideoTrackDisabled(RemoteVideoTrackEvent event) {
    _setRemoteVideoEnabled(event);
  }

  void _onVideoTrackEnabled(RemoteVideoTrackEvent event) {
    _setRemoteVideoEnabled(event);
  }

  void _onVideoTrackPublished(RemoteVideoTrackEvent event) {}

  void _onVideoTrackSubscribed(RemoteVideoTrackSubscriptionEvent event) {
    _addOrUpdateParticipant(event);
  }

  void _onVideoTrackSubscriptionFailed(
      RemoteVideoTrackSubscriptionFailedEvent event) {
    _onExceptionStreamController.add(
      PlatformException(
        code: 'ConferenceRoom.videoTrackSubscriptionFailed',
        message: 'VideoTrack Subscription Failed',
        details: event.exception.toString(),
      ),
    );
  }

  void _onVideoTrackUnpublished(RemoteVideoTrackEvent event) {}

  void _onVideoTrackUnsubscribed(RemoteVideoTrackSubscriptionEvent event) {}

  void _onMessage(RemoteDataTrackStringMessageEvent event) {}

  void _onBufferMessage(RemoteDataTrackBufferMessageEvent event) {}

  void _setRemoteAudioEnabled(RemoteAudioTrackEvent event) {
    if (event.remoteAudioTrackPublication == null) {
      return;
    }
    var index = _participants.indexWhere((ParticipantDisplay participant) =>
        participant.id == event.remoteParticipant.sid);
    if (index < 0) {
      return;
    }
    _participants[index] = _participants[index].copyWith(
        audioEnabled: event.remoteAudioTrackPublication.isTrackEnabled);
    notifyListeners();
  }

  void _setRemoteVideoEnabled(RemoteVideoTrackEvent event) {
    if (event.remoteVideoTrackPublication == null) {
      return;
    }
    var index = _participants.indexWhere((ParticipantDisplay participant) =>
        participant.id == event.remoteParticipant.sid);
    if (index < 0) {
      return;
    }
    _participants[index] = _participants[index].copyWith(
        videoEnabled: event.remoteVideoTrackPublication.isTrackEnabled);
    notifyListeners();
  }

  void _addOrUpdateParticipant(RemoteParticipantEvent event) {
    final participant = _participants.firstWhere(
      (ParticipantDisplay participant) =>
          participant.id == event.remoteParticipant.sid,
      orElse: () => null,
    );
    if (participant != null) {
      _setRemoteVideoEnabled(event);
      _setRemoteAudioEnabled(event);
    } else {
      final bufferedParticipant = _participantBuffer.firstWhere(
        (ParticipantBuffer participant) =>
            participant.id == event.remoteParticipant.sid,
        orElse: () => null,
      );
      if (bufferedParticipant != null) {
        _participantBuffer.remove(bufferedParticipant);
      } else if (event is RemoteAudioTrackEvent) {
        _participantBuffer.add(
          ParticipantBuffer(
            id: event.remoteParticipant.sid,
            audioEnabled: event
                    .remoteAudioTrackPublication?.remoteAudioTrack?.isEnabled ??
                true,
          ),
        );
        return;
      }
      if (event is RemoteVideoTrackSubscriptionEvent) {
        _participants.insert(
          0,
          _buildParticipant(
            child: event.remoteVideoTrack.widget(),
            id: event.remoteParticipant.sid,
            remoteParticipant: event.remoteParticipant,
            audioEnabled: bufferedParticipant?.audioEnabled ?? true,
            videoEnabled: event
                    .remoteVideoTrackPublication?.remoteVideoTrack?.isEnabled ??
                true,
            networkQualityLevel: event.remoteParticipant.networkQualityLevel,
            onNetworkQualityChanged:
                event.remoteParticipant.onNetworkQualityLevelChanged,
          ),
        );
      }
      notifyListeners();
    }
  }
}
