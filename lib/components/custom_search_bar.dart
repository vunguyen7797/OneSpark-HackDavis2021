import 'package:fleva_icons/fleva_icons.dart';
import 'package:flutter/material.dart';
import 'package:one_spark/helper/constant.dart';
import 'package:one_spark/helper/size_config.dart';

class CustomSearchBar extends StatefulWidget {
  final searchQuestion;
  final onTap;

  const CustomSearchBar({Key key, this.searchQuestion, this.onTap})
      : super(key: key);
  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap ?? () {},
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(4 * SizeConfig.heightMultiplier),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey.withOpacity(0.2),
                offset: Offset(0, 1),
                blurRadius: 20,
                spreadRadius: 0.5,
              )
            ]),
        height: 5 * SizeConfig.heightMultiplier,
        width: double.infinity,
        padding:
            EdgeInsets.symmetric(horizontal: 5 * SizeConfig.widthMultiplier),
        child: Row(
          children: <Widget>[
            Icon(
              FlevaIcons.search,
              color: ColorPalette.kPrimaryColor,
              size: 6 * SizeConfig.imageSizeMultiplier,
            ),
            SizedBox(
              width: 5 * SizeConfig.widthMultiplier,
            ),
            Expanded(
              child: Text(
                widget.searchQuestion ?? 'Search a project/campaign',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Color(0xff4A4A4A).withOpacity(0.6),
                    letterSpacing: 0.5,
                    fontSize: 1.6 * SizeConfig.textMultiplier),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
