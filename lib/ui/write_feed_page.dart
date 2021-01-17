import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_spark/blocs/project_feeds_bloc.dart';
import 'package:one_spark/helper/constant.dart';
import 'package:one_spark/helper/size_config.dart';
import 'package:provider/provider.dart';

class WriteFeedPage extends StatefulWidget {
  final pidId;

  const WriteFeedPage({
    Key key,
    @required this.pidId,
  }) : super(key: key);
  @override
  _WriteFeedPageState createState() => _WriteFeedPageState(this.pidId);
}

class _WriteFeedPageState extends State<WriteFeedPage> {
  final pidId;

  var _formKey = GlobalKey<FormState>();
  var _textFieldController = TextEditingController();

  String _feedContent;

  _WriteFeedPageState(this.pidId);

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final feedBloc = Provider.of<ProjectFeedsBloc>(context);

    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      feedBloc.saveNewFeeds(pidId, _feedContent, context);

      feedBloc.getFeedsData(pidId);
      _textFieldController.clear();
      FocusScope.of(context).requestFocus(new FocusNode());
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 5 * SizeConfig.widthMultiplier),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWidgetActionBar(),
                SizedBox(height: 2 * SizeConfig.heightMultiplier),
                Padding(
                  padding:
                      EdgeInsets.only(bottom: 4 * SizeConfig.heightMultiplier),
                  child: Container(
                    child: Text('Write A Feed',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rubik(
                          color: ColorPalette.kPrimaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 6 * SizeConfig.heightMultiplier,
                        )),
                  ),
                ),
                SizedBox(height: 1.5 * SizeConfig.heightMultiplier),
                SizedBox(
                  height: 1.5 * SizeConfig.heightMultiplier,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 5 * SizeConfig.widthMultiplier,
                    right: 5 * SizeConfig.widthMultiplier,
                    bottom: 3 * SizeConfig.heightMultiplier,
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                            2 * SizeConfig.heightMultiplier)),
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        style: GoogleFonts.rubik(
                          color: CupertinoColors.black,
                        ),
                        decoration: InputDecoration(
                            errorStyle: TextStyle(fontSize: 0),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 5 * SizeConfig.widthMultiplier,
                              vertical: 3 * SizeConfig.heightMultiplier,
                            ),
                            border: InputBorder.none,
                            hintText: 'How is the project going?',
                            hintStyle:
                                CustomizedTextStyle.kHintTextFieldTextStyle
                            //prefixIcon: Icon(Icons.comment, size:20, color:Colors.deepPurpleAccent),
                            ),
                        controller: _textFieldController,
                        onSaved: (String value) {
                          setState(() {
                            this._feedContent = value;
                          });
                        },
                        validator: (value) {
                          if (value.length == 0) return 'nullllll';
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 20.0 * SizeConfig.widthMultiplier,
                      vertical: 2 * SizeConfig.heightMultiplier),
                  child: GestureDetector(
                    onTap: () async {
                      _handleSubmit();
                    },
                    child: Container(
                      height: 7 * SizeConfig.heightMultiplier,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: ColorPalette.kPrimaryColor,
                        borderRadius: BorderRadius.circular(
                            5 * SizeConfig.heightMultiplier),
                      ),
                      child: Center(
                        child: Text(
                          'Submit',
                          overflow: TextOverflow.clip,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.rubik(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 2 * SizeConfig.textMultiplier,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetActionBar() {
    return Padding(
      padding: EdgeInsets.only(
        top: 6.5 * SizeConfig.heightMultiplier,
      ),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Align(
          alignment: Alignment.topLeft,
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
      ),
    );
  }
}
