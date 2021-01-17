import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_spark/blocs/video_room_bloc.dart';
import 'package:one_spark/components/custom_button_to_progress.dart';
import 'package:one_spark/helper/constant.dart';
import 'package:one_spark/helper/size_config.dart';
import 'package:one_spark/models/meeting_room.dart';
import 'package:one_spark/services/cloud_function_service.dart';
import 'package:one_spark/services/twilioModels/twilio_enums.dart';
import 'package:one_spark/ui/meeting_room_page.dart';
import 'package:provider/provider.dart';

class VideoCallPage extends StatefulWidget {
  final VideoRoomBloc videoRoomBloc;
  final String roomName;

  const VideoCallPage({
    Key key,
    @required this.videoRoomBloc,
    this.roomName,
  }) : super(key: key);

  static Widget create(BuildContext context, String roomName) {
    final cloudServices =
        Provider.of<CloudFunctionService>(context, listen: false);
    return Provider<VideoRoomBloc>(
      create: (BuildContext context) =>
          VideoRoomBloc(cloudServices: cloudServices),
      child: Consumer<VideoRoomBloc>(
        builder: (BuildContext context, VideoRoomBloc videoRoomBloc, _) =>
            VideoCallPage(
          videoRoomBloc: videoRoomBloc,
          roomName: roomName,
        ),
      ),
      dispose: (BuildContext context, VideoRoomBloc videoRoomBloc) =>
          videoRoomBloc.dispose(),
    );
  }

  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  final TextEditingController _roomNameController = TextEditingController();

  @override
  void initState() {
    _roomNameController.text = widget.roomName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 5 * SizeConfig.widthMultiplier),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 5 * SizeConfig.heightMultiplier,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                          color: ColorPalette.kAccentColor.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(50)),
                      padding: EdgeInsets.all(20),
                      child: Icon(
                        FontAwesomeIcons.arrowLeft,
                        color: CupertinoColors.black,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 3 * SizeConfig.heightMultiplier,
                  ),
                  Text(
                    'Set Up Video Room',
                    overflow: TextOverflow.clip,
                    style: GoogleFonts.rubik(
                      color: ColorPalette.kPrimaryColor,
                      fontSize: 6 * SizeConfig.textMultiplier,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _buildSettingBody(MeetingRoomModel(
                          name: widget.roomName,
                          type: TwilioRoomType.groupSmall)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSettingBody(MeetingRoomModel roomModel) {
    return <Widget>[
      TextField(
        key: Key('enter-room-name'),
        style: GoogleFonts.rubik(
            color: CupertinoColors.black,
            fontWeight: FontWeight.w500,
            fontSize: 2.5 * SizeConfig.textMultiplier),
        decoration: InputDecoration(
          labelText: 'Your Meeting Room ID',
          labelStyle: GoogleFonts.rubik(
            color: ColorPalette.kPrimaryColor,
            fontWeight: FontWeight.w500,
          ),
          errorText: roomModel.nameErrorText,
          enabled: !roomModel.isLoading,
        ),
        controller: _roomNameController,
        onChanged: widget.videoRoomBloc.updateName,
      ),
      SizedBox(
        height: 16,
      ),
      CustomButtonToProgress(
        onLoading: widget.videoRoomBloc.onLoading,
        loadingText: 'Creating the room...',
        progressHeight: 2,
        child: GestureDetector(
          onTap: roomModel.canSubmit && !roomModel.isLoading
              ? () => _submit(roomModel)
              : null,
          child: Container(
            decoration: BoxDecoration(
                color: ColorPalette.kPrimaryColor,
                borderRadius: BorderRadius.circular(30)),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 5 * SizeConfig.widthMultiplier),
              child: Center(
                child: Text(
                  'START MEETING',
                  style: GoogleFonts.rubik(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 2 * SizeConfig.textMultiplier),
                ),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Future<void> _submit(MeetingRoomModel roomModel) async {
    try {
      print('Submit creating room');
      final returnedRoomModel =
          await widget.videoRoomBloc.submitRoomRequest(roomModel);
      await Navigator.of(context).push(
        MaterialPageRoute<MeetingRoomPage>(
          fullscreenDialog: true,
          builder: (BuildContext context) =>
              MeetingRoomPage(roomModel: returnedRoomModel),
        ),
      );
    } catch (err) {}
  }
}
