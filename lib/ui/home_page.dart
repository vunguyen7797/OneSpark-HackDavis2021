import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_spark/blocs/user_bloc.dart';
import 'package:one_spark/helper/constant.dart';
import 'package:one_spark/helper/size_config.dart';
import 'package:one_spark/ui/mentor_list_page.dart';
import 'package:one_spark/ui/project_list_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userBloc = Provider.of<UserBloc>(context);
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.65,
                      decoration: BoxDecoration(
                        color: ColorPalette.kPrimaryColor,
                        borderRadius:
                            BorderRadius.only(bottomLeft: Radius.circular(50)),
                      ),
                    ),
                    Positioned(
                      top: 20 * SizeConfig.heightMultiplier,
                      left: 8 * SizeConfig.widthMultiplier,
                      right: 8 * SizeConfig.widthMultiplier,
                      child: Text(
                        'Share\nYour Spark',
                        style: GoogleFonts.rubik(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 7 * SizeConfig.textMultiplier,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40 * SizeConfig.heightMultiplier,
                      left: 10 * SizeConfig.widthMultiplier,
                      right: 5 * SizeConfig.widthMultiplier,
                      child: Text(
                        'You are here to make an impact',
                        style: GoogleFonts.rubik(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 2.5 * SizeConfig.textMultiplier,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 5 * SizeConfig.heightMultiplier,
                      left: 10 * SizeConfig.widthMultiplier,
                      right: 10 * SizeConfig.widthMultiplier,
                      child: Tags(
                        itemCount: userBloc.interests.length,
                        alignment: WrapAlignment.start,
                        itemBuilder: (int index) {
                          return ItemTags(
                            title: userBloc.interests[index],
                            index: index,
                            activeColor: Color(0xffF0E4E4).withOpacity(0.3),
                            padding: EdgeInsets.symmetric(
                                vertical: 0.8 * SizeConfig.heightMultiplier,
                                horizontal: 3 * SizeConfig.widthMultiplier),
                            elevation: 0,
                            pressEnabled: false,
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 4 * SizeConfig.heightMultiplier,
              ),
              _buildMenuWidget(context),
            ],
          ),
        ),
      ),
    );
  }

  _buildMenuWidget(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProjectListPage()));
          },
          child: Center(
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.width * 0.4,
                  width: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(2, 4),
                            color: Colors.blueGrey.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 1),
                      ]),
                  padding: EdgeInsets.all(10),
                  child: Center(
                    child: Text(
                      'Find A Project to Support',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(
                        color: ColorPalette.kPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 2 * SizeConfig.textMultiplier,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0 * SizeConfig.widthMultiplier,
                  bottom: 0 * SizeConfig.heightMultiplier,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      color: Color(0xffF0E4E4),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    padding: EdgeInsets.all(1.5 * SizeConfig.heightMultiplier),
                    child: Center(
                      child: Text(
                        'For supporters, mentors, donors,...',
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rubik(
                            color: CupertinoColors.black,
                            fontSize: 1.75 * SizeConfig.textMultiplier,
                            fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => MentorListPage()));
          },
          child: Center(
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.width * 0.4,
                  width: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(2, 4),
                            color: Colors.blueGrey.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 1),
                      ]),
                  padding: EdgeInsets.all(10),
                  child: Center(
                    child: Text(
                      'Find A Mentor For Your Project',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(
                        color: ColorPalette.kPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 2 * SizeConfig.textMultiplier,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0 * SizeConfig.widthMultiplier,
                  bottom: 0 * SizeConfig.heightMultiplier,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      color: Color(0xffF0E4E4),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    padding: EdgeInsets.all(1.5 * SizeConfig.heightMultiplier),
                    child: Center(
                      child: Text(
                        'For organizations, campaign/project organizers,...',
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.rubik(
                            color: CupertinoColors.black,
                            fontSize: 1.75 * SizeConfig.textMultiplier,
                            fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
