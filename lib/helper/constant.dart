import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_spark/helper/size_config.dart';

class ColorPalette {
  static const kPrimaryColor = Color(0xffA23019);
  static const kSecondaryColor = Color(0xffF0E4E4);
  static const kAccentColor = Color(0xffA23019);
  static const kScaffoldColor = Color(0xffF8F7F7);
}

class CustomizedTextStyle {
  static final kTextFieldTextStyle = TextStyle(
    color: CupertinoColors.black,
    fontSize: 2 * SizeConfig.textMultiplier, // == size 17

    fontWeight: FontWeight.w500,
  );

  static final kHintTextFieldTextStyle = TextStyle(
    color: Colors.grey,
    fontSize: 2 * SizeConfig.textMultiplier,
  );

  static final kSubtitleLightSmallTextStyle = GoogleFonts.rubik(
    color: ColorPalette.kPrimaryColor.withOpacity(0.6),
    fontSize: 1.75 * SizeConfig.textMultiplier,
  );
}
