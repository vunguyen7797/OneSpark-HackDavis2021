import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:one_spark/models/meeting_room.dart';
import 'package:one_spark/services/cloud_function_service.dart';
import 'package:one_spark/services/platform_service.dart';
import 'package:one_spark/services/twilioModels/twilio_enums.dart';
import 'package:one_spark/services/twilioModels/twilio_room_request.dart';
import 'package:one_spark/services/twilioModels/twilio_room_token_request.dart';
import 'package:rxdart/rxdart.dart';

class VideoRoomBloc {
  final CloudFunctionService cloudServices;

  final BehaviorSubject<MeetingRoomModel> _modelSubject =
      BehaviorSubject<MeetingRoomModel>.seeded(MeetingRoomModel());
  final StreamController<bool> _loadingController =
      StreamController<bool>.broadcast();

  VideoRoomBloc({@required this.cloudServices}) : assert(cloudServices != null);

  Stream<MeetingRoomModel> get modelStream => _modelSubject.stream;

  Stream<bool> get onLoading => _loadingController.stream;

  MeetingRoomModel get meetingRoomModel => _modelSubject.value;

  Future<MeetingRoomModel> submitRoomRequest(
      MeetingRoomModel meetingRoom) async {
    updateWith(isSubmitted: true, isLoading: true);
    try {
      await _createRoom(meetingRoom);
      await _generateToken(meetingRoom);
      return meetingRoomModel;
    } catch (err) {
      rethrow;
    } finally {
      updateWith(isLoading: false);
    }
  }

  Future _generateToken(MeetingRoomModel roomModel) async {
    final twilioRoomTokenResponse = await cloudServices.createToken(
      TwilioRoomTokenRequest(
        uniqueName: roomModel.name,
        identity: await _getDeviceId(),
      ),
    );
    updateWith(
      token: twilioRoomTokenResponse.token,
      identity: twilioRoomTokenResponse.identity,
    );
  }

  Future _createRoom(MeetingRoomModel roomModel) async {
    try {
      print('Creating room.... ${roomModel.name} ${roomModel.type}');

      await cloudServices.createRoom(
        TwilioRoomRequest(
          uniqueName: roomModel.name,
          type: roomModel.type,
        ),
      );
    } on PlatformException catch (err) {
      if (err.code != 'functionsError' ||
          err.details['message'] != 'Error: Room exists') {
        print('Error Debug: $err');
        rethrow;
      }
    } catch (err) {
      print('Error Debug: $err');
      rethrow;
    }
  }

  Future<String> _getDeviceId() async {
    try {
      return await PlatformService.deviceId;
    } catch (err) {
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  void dispose() {
    _modelSubject.close();
    _loadingController.close();
  }

  void updateName(String name) => updateWith(name: name);

  void updateType(TwilioRoomType type) => updateWith(type: type);

  void updateWith({
    String name,
    bool isLoading,
    bool isSubmitted,
    String token,
    String identity,
    TwilioRoomType type,
  }) {
    var raiseLoading = false;
    if (isLoading != null && _modelSubject.value.isLoading != isLoading) {
      raiseLoading = true;
    }
    _modelSubject.value = meetingRoomModel.copyWith(
      name: name,
      isLoading: isLoading,
      isSubmitted: isSubmitted,
      token: token,
      identity: identity,
      type: type,
    );
    if (raiseLoading) {
      _loadingController.add(_modelSubject.value.isLoading);
    }
  }
}
