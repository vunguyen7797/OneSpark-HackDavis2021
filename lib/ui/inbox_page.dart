import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_spark/blocs/user_bloc.dart';
import 'package:one_spark/helper/constant.dart';
import 'package:one_spark/helper/size_config.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_page.dart';

class InboxPage extends StatefulWidget {
  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 0), () async {
      final userBloc = Provider.of<UserBloc>(context);
      userBloc.setInbox = [];
      await userBloc.getInboxMentorsList(context);
      await userBloc.getInboxProjectsList(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userBloc = Provider.of<UserBloc>(context);
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                delegate: InboxPageHeader(27 * SizeConfig.heightMultiplier,
                    27 * SizeConfig.heightMultiplier),
                floating: true,
                pinned: true,
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 5 * SizeConfig.widthMultiplier,
                        vertical: 1.5 * SizeConfig.heightMultiplier),
                    child: Container(
                      child: FlatButton(
                        child: Row(
                          children: <Widget>[
                            userBloc.inbox[index].buildImage(context),
                            Flexible(
                              child: Container(
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      child: userBloc.inbox[index]
                                          .buildTitle(context),
                                      alignment: Alignment.centerLeft,
                                    ),
                                  ],
                                ),
                                margin: EdgeInsets.only(left: 20.0),
                              ),
                            ),
                          ],
                        ),
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          String uid = prefs.getString('uid') ?? '';

                          if (userBloc.inbox[index].id != uid)
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                          peerName: userBloc.inbox[index].name,
                                          peerId: userBloc.inbox[index].id,
                                          peerAvatar:
                                              userBloc.inbox[index].photoUrl,
                                        )));
                        },
                        color: Colors.white,
                        padding: EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  );
                }, childCount: userBloc.inbox.length),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InboxPageHeader implements SliverPersistentHeaderDelegate {
  final double minExtent;
  final double maxExtent;

  InboxPageHeader(this.minExtent, this.maxExtent);

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
              'My Inbox',
              overflow: TextOverflow.clip,
              style: GoogleFonts.rubik(
                color: ColorPalette.kPrimaryColor,
                fontSize: 7 * SizeConfig.textMultiplier,
                fontWeight: FontWeight.bold,
              ),
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
