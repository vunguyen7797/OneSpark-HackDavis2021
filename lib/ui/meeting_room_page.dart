import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:one_spark/helper/constant.dart';
import 'package:one_spark/models/meeting_room.dart';
import 'package:wakelock/wakelock.dart';

import '../components/draggable_publisher.dart';
import '../components/meeting_room.dart';
import '../components/meeting_room_button_bar.dart';
import '../components/participant_display.dart';

class MeetingRoomPage extends StatefulWidget {
  final MeetingRoomModel roomModel;

  const MeetingRoomPage({Key key, this.roomModel}) : super(key: key);

  @override
  _MeetingRoomPageState createState() => _MeetingRoomPageState(this.roomModel);
}

class _MeetingRoomPageState extends State<MeetingRoomPage> {
  final MeetingRoomModel roomModel;

  final StreamController<bool> _onButtonBarVisibleStreamController =
      StreamController<bool>.broadcast();
  final StreamController<double> _onButtonBarHeightStreamController =
      StreamController<double>.broadcast();
  MeetingRoom _meetingRoom;
  StreamSubscription _onMeetingRoomException;

  _MeetingRoomPageState(this.roomModel);

  @override
  void initState() {
    super.initState();
    _lockScreenPortrait();
    _connectToRoom();
    _wakeLock(true);
  }

  Future<void> _lockScreenPortrait() async {
    await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _connectToRoom() async {
    try {
      final meetingRoom = MeetingRoom(
        name: roomModel.name,
        token: roomModel.token,
        identity: roomModel.identity,
      );
      await meetingRoom.connect();
      setState(() {
        _meetingRoom = meetingRoom;
        _onMeetingRoomException =
            _meetingRoom.onException.listen((err) async {});
        _meetingRoom.addListener(_meetingRoomUpdated);
      });
    } catch (err) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _wakeLock(false);
    _disposeStreamsAndSubscriptions();
    if (_meetingRoom != null) _meetingRoom.removeListener(_meetingRoomUpdated);
    super.dispose();
  }

  Future<void> _disposeStreamsAndSubscriptions() async {
    if (_onButtonBarVisibleStreamController != null)
      await _onButtonBarVisibleStreamController.close();
    if (_onButtonBarHeightStreamController != null)
      await _onButtonBarHeightStreamController.close();
    if (_onMeetingRoomException != null) await _onMeetingRoomException.cancel();
  }

  Future<void> _onHangup() async {
    await _meetingRoom.disconnect();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: _meetingRoom == null ? _waitingIndicator() : _buildBodyLayout(),
        ),
      ),
    );
  }

  LayoutBuilder _buildBodyLayout() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          children: <Widget>[
            _buildParticipants(context, constraints.biggest, _meetingRoom),
            MeetingRoomButtonBar(
              audioEnabled: _meetingRoom.onAudioEnabled,
              videoEnabled: _meetingRoom.onVideoEnabled,
              flashState: _meetingRoom.flashStateStream,
              onAudioEnabled: _meetingRoom.toggleAudioEnabled,
              onVideoEnabled: _meetingRoom.toggleVideoEnabled,
              onHangup: _onHangup,
              onSwitchCamera: _meetingRoom.switchCamera,
              onHeight: _onHeightBar,
              onShow: _onShowBar,
            ),
          ],
        );
      },
    );
  }

  Widget _waitingIndicator() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(
            child: SpinKitFadingFour(
          color: ColorPalette.kPrimaryColor,
        )),
        SizedBox(
          height: 10,
        ),
        Text(
          'Connecting to the meeting room...',
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildParticipants(
      BuildContext context, Size size, MeetingRoom meetingRoom) {
    final children = <Widget>[];
    final length = meetingRoom.participants.length;

    if (length <= 2) {
      _buildOverlayLayout(context, size, children);
      return Stack(children: children);
    }
    return Column(
      children: children,
    );
  }

  void _buildOverlayLayout(
      BuildContext context, Size size, List<Widget> children) {
    final participants = _meetingRoom.participants;
    if (participants.length == 1) {
      children.add(_buildWaitingBackground());
    } else {
      final remoteParticipant = participants.firstWhere(
          (ParticipantDisplay participant) => participant.isRemote,
          orElse: () => null);
      if (remoteParticipant != null) {
        children.add(remoteParticipant);
      }
    }

    final localParticipant = participants.firstWhere(
        (ParticipantDisplay participant) => !participant.isRemote,
        orElse: () => null);
    if (localParticipant != null) {
      children.add(DraggablePublisher(
        key: Key('publisher'),
        child: localParticipant,
        availableScreenSize: size,
        onButtonBarVisible: _onButtonBarVisibleStreamController.stream,
        onButtonBarHeight: _onButtonBarHeightStreamController.stream,
      ));
    }
  }

  Widget _buildWaitingBackground() {
    return Container(
      color: CupertinoColors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          color: Colors.black54,
          width: double.infinity,
          height: 40,
          child: Center(
            child: Text(
              'Waiting for another participant to connect to the room...',
              key: Key('text-wait'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  void _onHeightBar(double height) {
    _onButtonBarHeightStreamController.add(height);
  }

  void _onShowBar() {
    setState(() {
      SystemChrome.setEnabledSystemUIOverlays(
          [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    });
    _onButtonBarVisibleStreamController.add(true);
  }

  Future<void> _wakeLock(bool enable) async {
    try {
      return await (enable ? Wakelock.enable() : Wakelock.disable());
    } catch (err) {}
  }

  void _meetingRoomUpdated() {
    setState(() {});
  }
}
