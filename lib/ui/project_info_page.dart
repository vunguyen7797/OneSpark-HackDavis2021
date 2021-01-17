import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_spark/blocs/project_feeds_bloc.dart';
import 'package:one_spark/helper/constant.dart';
import 'package:one_spark/helper/size_config.dart';
import 'package:one_spark/models/project.dart';
import 'package:one_spark/ui/chat_page.dart';
import 'package:one_spark/ui/write_feed_page.dart';
import 'package:provider/provider.dart';

class ProjectInfoPage extends StatefulWidget {
  final Project project;

  const ProjectInfoPage({Key key, @required this.project}) : super(key: key);
  @override
  _ProjectInfoPageState createState() => _ProjectInfoPageState(this.project);
}

class _ProjectInfoPageState extends State<ProjectInfoPage> {
  final Project project;

  int _currentIndex = 0;

  _ProjectInfoPageState(this.project);

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 0), () async {
      final feedsBloc = Provider.of<ProjectFeedsBloc>(context);
      await feedsBloc.getFeedsData(project.pid);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorPalette.kPrimaryColor,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WriteFeedPage(pidId: project.pid)));
        },
        child: Icon(
          FontAwesomeIcons.comment,
          color: Colors.white,
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.45,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: CachedNetworkImage(
                      imageUrl: project.photoUrl,
                      imageBuilder: (context, imageProvider) => ClipRRect(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(
                                5 * SizeConfig.heightMultiplier),
                            bottomRight: Radius.circular(
                                5 * SizeConfig.heightMultiplier)),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.42,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          )),
                        ),
                      ),
                      placeholder: (context, url) => Container(
                        height: MediaQuery.of(context).size.height * 0.42,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(
                                  5 * SizeConfig.heightMultiplier),
                              bottomRight: Radius.circular(
                                  5 * SizeConfig.heightMultiplier)),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: MediaQuery.of(context).size.height * 0.42,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(
                                  5 * SizeConfig.heightMultiplier),
                              bottomRight: Radius.circular(
                                  5 * SizeConfig.heightMultiplier)),
                        ),
                        child: Icon(Icons.error),
                      ),
                    ),
                  ),
                  _buildMenuBar(),
                  Positioned(
                    top: 5 * SizeConfig.heightMultiplier,
                    left: 5 * SizeConfig.widthMultiplier,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        FontAwesomeIcons.arrowLeft,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5 * SizeConfig.heightMultiplier,
                    right: 5 * SizeConfig.widthMultiplier,
                    child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          decoration: BoxDecoration(
                              color: CupertinoColors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(
                              vertical: 1.5 * SizeConfig.heightMultiplier,
                              horizontal: 5 * SizeConfig.widthMultiplier),
                          child: Text(
                            'Follow',
                            style: GoogleFonts.rubik(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 2 * SizeConfig.textMultiplier),
                          ),
                        )),
                  )
                ],
              ),
            ),
            Expanded(
              child: _currentIndex == 0
                  ? _buildInformationContainer()
                  : _currentIndex == 1
                      ? _buildFeedsContainer()
                      : _currentIndex == 2
                          ? _buildDonationContainer()
                          : Container(),
            ),
          ],
        ),
      ),
    );
  }

  _buildContainerHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          project.name,
          style: GoogleFonts.rubik(
            color: CupertinoColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 3 * SizeConfig.textMultiplier,
          ),
        ),
        RichText(
            text: TextSpan(children: [
          WidgetSpan(
            child: Icon(
              FontAwesomeIcons.mapPin,
              color: Colors.grey,
              size: 1.8 * SizeConfig.textMultiplier,
            ),
          ),
          TextSpan(
            text: project.location,
            style: GoogleFonts.rubik(
              color: Colors.grey,
              fontSize: 1.8 * SizeConfig.textMultiplier,
            ),
          ),
        ])),
        SizedBox(
          height: 2 * SizeConfig.heightMultiplier,
        ),
        _buildOrganizationBar(),
      ],
    );
  }

  _buildDonationContainer() {
    return SingleChildScrollView(
      child: Container(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 5 * SizeConfig.widthMultiplier,
              vertical: 2.5 * SizeConfig.heightMultiplier),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContainerHeader(),
              SizedBox(
                height: 2 * SizeConfig.heightMultiplier,
              ),
              Container(
                height: 25 * SizeConfig.heightMultiplier,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(2 * SizeConfig.heightMultiplier),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Donation amount',
                      style: GoogleFonts.rubik(
                        color: CupertinoColors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 3 * SizeConfig.textMultiplier,
                      ),
                    ),
                    SizedBox(
                      height: 2 * SizeConfig.heightMultiplier,
                    ),
                    Text(
                      '\$' + project.donation.toString(),
                      style: GoogleFonts.rubik(
                        color: ColorPalette.kPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 6 * SizeConfig.textMultiplier,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 2 * SizeConfig.heightMultiplier,
              ),
              GestureDetector(
                onTap: () {},
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColorPalette.kPrimaryColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: EdgeInsets.symmetric(
                        vertical: 1.5 * SizeConfig.heightMultiplier,
                        horizontal: 8 * SizeConfig.widthMultiplier),
                    child: Text('Donate Us',
                        style: GoogleFonts.rubik(
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                          color: CupertinoColors.white,
                          fontSize: 2.5 * SizeConfig.textMultiplier,
                        )),
                  ),
                ),
              ),
              SizedBox(
                height: 3 * SizeConfig.heightMultiplier,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildFeedsContainer() {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 5 * SizeConfig.widthMultiplier,
            vertical: 2.5 * SizeConfig.heightMultiplier),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContainerHeader(),
            SizedBox(
              height: 2 * SizeConfig.heightMultiplier,
            ),
            Expanded(
                child: Container(
              child: _buildListFeeds(),
            )),
          ],
        ),
      ),
    );
  }

  _buildInformationContainer() {
    return SingleChildScrollView(
      child: Container(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 5 * SizeConfig.widthMultiplier,
              vertical: 2.5 * SizeConfig.heightMultiplier),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContainerHeader(),
              SizedBox(
                height: 2 * SizeConfig.heightMultiplier,
              ),
              Text(
                'Recommendation Score',
                style: GoogleFonts.rubik(
                  color: CupertinoColors.black.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                  fontSize: 2.2 * SizeConfig.textMultiplier,
                ),
              ),
              Row(
                children: [
                  RatingBar.builder(
                    initialRating: project.popScore,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      print(rating);
                    },
                  ),
                  Text(
                    project.popScore.toString() + '/5.0',
                    style: GoogleFonts.rubik(
                      color: CupertinoColors.black.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                      fontSize: 2.2 * SizeConfig.textMultiplier,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 3 * SizeConfig.heightMultiplier,
              ),
              Text(
                'About the project',
                style: GoogleFonts.rubik(
                  color: CupertinoColors.black.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                  fontSize: 2.2 * SizeConfig.textMultiplier,
                ),
              ),
              SizedBox(
                height: 1 * SizeConfig.heightMultiplier,
              ),
              Text(
                project.description,
                style: GoogleFonts.rubik(
                  color: CupertinoColors.black.withOpacity(0.7),
                  fontSize: 1.75 * SizeConfig.textMultiplier,
                ),
              ),
              SizedBox(
                height: 3 * SizeConfig.heightMultiplier,
              ),
              Text(
                'Tags',
                style: GoogleFonts.rubik(
                  color: CupertinoColors.black.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                  fontSize: 2.2 * SizeConfig.textMultiplier,
                ),
              ),
              SizedBox(
                height: 1 * SizeConfig.heightMultiplier,
              ),
              Tags(
                itemCount: project.tags.length,
                alignment: WrapAlignment.start,
                itemBuilder: (int index) {
                  return ItemTags(
                    title: project.tags[index],
                    index: index,
                    activeColor: ColorPalette.kAccentColor.withOpacity(0.5),
                    padding: EdgeInsets.symmetric(
                        vertical: 0.8 * SizeConfig.heightMultiplier,
                        horizontal: 3 * SizeConfig.widthMultiplier),
                    elevation: 0,
                    pressEnabled: false,
                  );
                },
              ),
              SizedBox(
                height: 3 * SizeConfig.heightMultiplier,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildOrganizationBar() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 6 * SizeConfig.heightMultiplier,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2 * SizeConfig.heightMultiplier),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              child: RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(children: [
                    TextSpan(
                      text: 'Organized By',
                      style: GoogleFonts.rubik(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 1.75 * SizeConfig.textMultiplier,
                      ),
                    ),
                    WidgetSpan(
                      child: SizedBox(
                        width: 2 * SizeConfig.widthMultiplier,
                      ),
                    ),
                    TextSpan(
                      text: project.author,
                      style: GoogleFonts.rubik(
                        color: ColorPalette.kPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 1.75 * SizeConfig.textMultiplier,
                      ),
                    ),
                  ])),
            ),
            Icon(
              FontAwesomeIcons.arrowRight,
              color: Colors.grey,
              size: 1.5 * SizeConfig.textMultiplier,
            ),
          ],
        ),
      ),
    );
  }

  _buildMenuBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 7 * SizeConfig.heightMultiplier,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2 * SizeConfig.heightMultiplier),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                });
              },
              child: Container(
                height: 7 * SizeConfig.heightMultiplier,
                child: Center(
                  child: Text(
                    'Information',
                    style: GoogleFonts.rubik(
                        color: _currentIndex == 0
                            ? ColorPalette.kPrimaryColor
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 1.75 * SizeConfig.textMultiplier),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
              child: Container(
                height: 7 * SizeConfig.heightMultiplier,
                child: Center(
                  child: Text(
                    'Feeds',
                    style: GoogleFonts.rubik(
                        color: _currentIndex == 1
                            ? ColorPalette.kPrimaryColor
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 1.75 * SizeConfig.textMultiplier),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = 2;
                });
              },
              child: Container(
                height: 7 * SizeConfig.heightMultiplier,
                child: Center(
                  child: Text(
                    'Donation',
                    style: GoogleFonts.rubik(
                        color: _currentIndex == 2
                            ? ColorPalette.kPrimaryColor
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 1.75 * SizeConfig.textMultiplier),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = 3;
                });
                print('PID ID : ${project.pid} ${project.name}');
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatPage(
                            peerId: project.pid,
                            peerAvatar: project.photoUrl,
                            peerName: project.name))).then((value) {
                  setState(() {
                    _currentIndex = 0;
                  });
                });
              },
              child: Container(
                height: 7 * SizeConfig.heightMultiplier,
                child: Center(
                  child: Text(
                    'Inbox',
                    style: GoogleFonts.rubik(
                        color: _currentIndex == 3
                            ? ColorPalette.kPrimaryColor
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 1.75 * SizeConfig.textMultiplier),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildListFeeds() {
    final feedsBloc = Provider.of<ProjectFeedsBloc>(context);

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        vertical: 1 * SizeConfig.heightMultiplier,
      ),
      itemCount: feedsBloc.data.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 1 * SizeConfig.heightMultiplier),
          child: Container(
              padding: EdgeInsets.only(
                  top: SizeConfig.heightMultiplier,
                  bottom: 2 * SizeConfig.heightMultiplier),
              margin: EdgeInsets.only(bottom: SizeConfig.heightMultiplier),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(3 * SizeConfig.heightMultiplier)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: feedsBloc.data[index]['photoUrl'],
                        imageBuilder: (context, imageProvider) => ClipRRect(
                          child: ClipRRect(
                            child: Container(
                              height: 8 * SizeConfig.heightMultiplier,
                              width: 15 * SizeConfig.widthMultiplier,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    2 * SizeConfig.heightMultiplier),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        placeholder: (context, url) => Container(
                          height: 8 * SizeConfig.heightMultiplier,
                          width: 15 * SizeConfig.widthMultiplier,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                2 * SizeConfig.heightMultiplier),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 8 * SizeConfig.heightMultiplier,
                          width: 15 * SizeConfig.widthMultiplier,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                2 * SizeConfig.heightMultiplier),
                          ),
                          child: Icon(Icons.error),
                        ),
                      ),
                      subtitle: Text(feedsBloc.data[index]['date'],
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 1.5 * SizeConfig.textMultiplier,
                              fontWeight: FontWeight.w500)),
                      title: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: feedsBloc.data[index]['name'],
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 1.8 * SizeConfig.textMultiplier,
                                fontWeight: FontWeight.w700),
                          ),
                        ]),
                        overflow: TextOverflow.clip,
                      )),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 5 * SizeConfig.widthMultiplier,
                        right: 5 * SizeConfig.widthMultiplier,
                        top: SizeConfig.heightMultiplier),
                    child: Text(
                      feedsBloc.data[index]['feed'],
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 1.8 * SizeConfig.textMultiplier,
                        color: CupertinoColors.black,
                      ),
                    ),
                  ),
                ],
              )),
        );
      },
    );
  }
}
