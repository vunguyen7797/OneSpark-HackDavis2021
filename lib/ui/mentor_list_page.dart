import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_spark/blocs/mentors_bloc.dart';
import 'package:one_spark/components/custom_search_bar.dart';
import 'package:one_spark/helper/constant.dart';
import 'package:one_spark/helper/size_config.dart';
import 'package:one_spark/models/user.dart';
import 'package:one_spark/ui/chat_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MentorListPage extends StatefulWidget {
  @override
  _MentorListPageState createState() => _MentorListPageState();
}

class _MentorListPageState extends State<MentorListPage> {
  @override
  Widget build(BuildContext context) {
    final mentorsBloc = Provider.of<MentorsBloc>(context);
    List<UserModel> mentorsList = mentorsBloc.mentorsList;
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                delegate: MentorPageHeader(41 * SizeConfig.heightMultiplier,
                    41 * SizeConfig.heightMultiplier),
                floating: true,
                pinned: true,
              ),
              SliverPadding(
                  padding:
                      EdgeInsets.only(bottom: 2 * SizeConfig.heightMultiplier)),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 5 * SizeConfig.widthMultiplier,
                        vertical: 1.25 * SizeConfig.heightMultiplier),
                    child: Container(
                      child: Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: 6 * SizeConfig.widthMultiplier,
                                top: 3 * SizeConfig.heightMultiplier),
                            child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          2 * SizeConfig.heightMultiplier),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left:
                                                30 * SizeConfig.widthMultiplier,
                                            right:
                                                5 * SizeConfig.widthMultiplier),
                                        child: Text(
                                          mentorsList[index].displayName,
                                          overflow: TextOverflow.clip,
                                          maxLines: 1,
                                          style: GoogleFonts.rubik(
                                              color: CupertinoColors.black,
                                              fontSize: 2.5 *
                                                  SizeConfig.textMultiplier,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left:
                                                30 * SizeConfig.widthMultiplier,
                                            right:
                                                5 * SizeConfig.widthMultiplier),
                                        child: RichText(
                                            overflow: TextOverflow.clip,
                                            text: TextSpan(
                                                text: mentorsList[index]
                                                        .position +
                                                    (mentorsList[index]
                                                                .position !=
                                                            ""
                                                        ? ' at '
                                                        : '\"'),
                                                style: GoogleFonts.rubik(
                                                    color:
                                                        CupertinoColors.black,
                                                    fontSize: 1.75 *
                                                        SizeConfig
                                                            .textMultiplier),
                                                children: [
                                                  TextSpan(
                                                    text: mentorsList[index]
                                                        .organization,
                                                    style: GoogleFonts.rubik(
                                                        color: CupertinoColors
                                                            .black,
                                                        fontSize: 1.75 *
                                                            SizeConfig
                                                                .textMultiplier),
                                                  ),
                                                ])),
                                      ),
                                      SizedBox(
                                        height: 1 * SizeConfig.heightMultiplier,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left:
                                                30 * SizeConfig.widthMultiplier,
                                            right:
                                                5 * SizeConfig.widthMultiplier),
                                        child: Text(
                                          "\"" + mentorsList[index].bio == ""
                                              ? ""
                                              : mentorsList[index].bio + "\"",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: GoogleFonts.rubik(
                                              color: CupertinoColors.black
                                                  .withOpacity(0.7),
                                              fontSize: 1.8 *
                                                  SizeConfig.textMultiplier,
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 2 * SizeConfig.heightMultiplier,
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          String uid =
                                              prefs.getString('uid') ?? '';
                                          if (mentorsList[index].uid != uid)
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChatPage(
                                                          peerName:
                                                              mentorsList[index]
                                                                  .displayName,
                                                          peerId:
                                                              mentorsList[index]
                                                                  .uid,
                                                          peerAvatar:
                                                              mentorsList[index]
                                                                  .photoUrl,
                                                        )));
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 30 *
                                                  SizeConfig.widthMultiplier,
                                              right: 5 *
                                                  SizeConfig.widthMultiplier),
                                          child: Container(
                                            width:
                                                30 * SizeConfig.widthMultiplier,
                                            decoration: BoxDecoration(
                                                color:
                                                    ColorPalette.kPrimaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 1.2 *
                                                    SizeConfig
                                                        .heightMultiplier),
                                            child: Center(
                                              child: Text(
                                                'Inbox me!',
                                                style: GoogleFonts.rubik(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 2 *
                                                        SizeConfig
                                                            .textMultiplier),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 3 * SizeConfig.heightMultiplier,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left:
                                                5 * SizeConfig.widthMultiplier,
                                            right:
                                                5 * SizeConfig.widthMultiplier),
                                        child: Container(
                                          child: Tags(
                                            alignment: WrapAlignment.start,
                                            runSpacing: 5,
                                            spacing: 5,
                                            itemCount: mentorsList[index]
                                                .interests
                                                .length,
                                            itemBuilder: (int tIndex) {
                                              return ItemTags(
                                                title: mentorsList[index]
                                                    .interests[tIndex],
                                                index: tIndex,
                                                activeColor: Color(0xffD86262)
                                                    .withOpacity(0.5),
                                                elevation: 0,
                                                textActiveColor: CupertinoColors
                                                    .black
                                                    .withOpacity(0.5),
                                                alignment:
                                                    MainAxisAlignment.center,
                                                pressEnabled: false,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ),
                          Positioned(
                            child: CachedNetworkImage(
                              imageUrl: mentorsList[index].photoUrl,
                              imageBuilder: (context, imageProvider) =>
                                  ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    5 * SizeConfig.heightMultiplier),
                                child: Container(
                                  height: 23 * SizeConfig.heightMultiplier,
                                  width: 15 * SizeConfig.heightMultiplier,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  )),
                                ),
                              ),
                              placeholder: (context, url) => Container(
                                height: 23 * SizeConfig.heightMultiplier,
                                width: 15 * SizeConfig.heightMultiplier,
                                decoration: BoxDecoration(
                                  color: Colors.white30,
                                  borderRadius: BorderRadius.circular(
                                      5 * SizeConfig.heightMultiplier),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 23 * SizeConfig.heightMultiplier,
                                width: 15 * SizeConfig.heightMultiplier,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(
                                      5 * SizeConfig.heightMultiplier),
                                ),
                                child: Icon(Icons.error),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }, childCount: mentorsList.length),
              ),
              SliverPadding(
                  padding:
                      EdgeInsets.only(bottom: 5 * SizeConfig.heightMultiplier)),
            ],
          ),
        ),
      ),
    );
  }
}

class MentorPageHeader implements SliverPersistentHeaderDelegate {
  final double minExtent;
  final double maxExtent;

  MentorPageHeader(this.minExtent, this.maxExtent);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5 * SizeConfig.widthMultiplier),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: ColorPalette.kScaffoldColor,
                blurRadius: 8.0,
                spreadRadius: 10,
                offset: Offset(0.0, 0.1 * SizeConfig.heightMultiplier))
          ],
          color: ColorPalette.kScaffoldColor,
        ),
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
              'Unstuck\nYour Problem',
              overflow: TextOverflow.clip,
              style: GoogleFonts.rubik(
                color: ColorPalette.kPrimaryColor,
                fontSize: 6 * SizeConfig.textMultiplier,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 3 * SizeConfig.heightMultiplier,
            ),
            CustomSearchBar(
              searchQuestion: 'Search a mentor to help',
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  // TODO: implement snapConfiguration
  FloatingHeaderSnapConfiguration get snapConfiguration => null;

  @override
  // TODO: implement stretchConfiguration
  OverScrollHeaderStretchConfiguration get stretchConfiguration => null;

  @override
  // TODO: implement showOnScreenConfiguration
  PersistentHeaderShowOnScreenConfiguration get showOnScreenConfiguration =>
      null;

  @override
  // TODO: implement vsync
  TickerProvider get vsync => null;
}
