import 'package:one_spark/services/twilioModels/twilio_page_meta.dart';
import 'package:one_spark/services/twilioModels/twilio_room_response.dart';

class TwilioListRoomResponse {
  final List<TwilioRoomResponse> rooms;
  final TwilioPageMeta meta;

  TwilioListRoomResponse({
    this.rooms,
    this.meta,
  });

  factory TwilioListRoomResponse.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    return TwilioListRoomResponse(
      rooms: (List<Map<String, dynamic>>.from(data['rooms']))
          .map(
            (Map<String, dynamic> room) => TwilioRoomResponse.fromMap(
                Map<String, dynamic>.from(data['room'])),
          )
          .toList(),
      meta: TwilioPageMeta.fromMap(Map<String, dynamic>.from(data['meta'])),
    );
  }
}
