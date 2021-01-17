import 'package:one_spark/helper/validators.dart';
import 'package:one_spark/services/twilioModels/twilio_enums.dart';

class MeetingRoomModel with RoomValidators {
  final String name;
  final bool isLoading;
  final bool isSubmitted;
  final String token;
  final String identity;
  final TwilioRoomType type;

  MeetingRoomModel({
    this.name,
    this.isLoading = false,
    this.isSubmitted = false,
    this.token,
    this.identity,
    this.type = TwilioRoomType.groupSmall,
  });

  static String getTypeText(TwilioRoomType type) {
    switch (type) {
      case TwilioRoomType.peerToPeer:
        return 'peer 2 peer';
        break;
      case TwilioRoomType.group:
        return 'large (max 50 participants)';
        break;
      case TwilioRoomType.groupSmall:
        return 'small (max 4 participants)';
        break;
    }
    return '';
  }

  String get nameErrorText {
    return isSubmitted && !nameValidator.isValid(name)
        ? invalidNameErrorText
        : null;
  }

  String get typeText {
    return MeetingRoomModel.getTypeText(type);
  }

  bool get canSubmit {
    return nameValidator.isValid(name);
  }

  MeetingRoomModel copyWith({
    String name,
    bool isLoading,
    bool isSubmitted,
    String token,
    String identity,
    TwilioRoomType type,
  }) {
    return MeetingRoomModel(
      name: name ?? this.name,
      token: token ?? this.token,
      identity: identity ?? this.identity,
      isLoading: isLoading ?? this.isLoading,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      type: type ?? this.type,
    );
  }
}
