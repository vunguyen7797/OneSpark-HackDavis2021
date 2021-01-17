import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:one_spark/blocs/user_bloc.dart';
import 'package:one_spark/components/custom_bottom_navbar.dart';
import 'package:one_spark/helper/constant.dart';
import 'package:one_spark/helper/size_config.dart';
import 'package:one_spark/ui/home_page.dart';
import 'package:one_spark/ui/inbox_page.dart';
import 'package:one_spark/ui/profile_page.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _bottomNavIndex = 0;

  List<Widget> pages = [HomePage(), InboxPage(), ProfilePage()];
  Widget body = HomePage();
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 0), () {
      final userBloc = Provider.of<UserBloc>(context);
      userBloc.getUserFirestore();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        body: body,
        bottomNavigationBar: CustomBottomNavyBar(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            backgroundColor: Colors.white,
            selectedIndex: _bottomNavIndex,
            animationDuration: Duration(milliseconds: 500),
            enableAnimation: false,
            showElevation: true,
            onItemSelected: (i) {
              setState(() {
                _bottomNavIndex = i;
                body = pages[i];
              });
            },
            containerHeight: 6.5 * SizeConfig.heightMultiplier,
            items: [
              BottomNavyBarCustomItem(
                inactiveColor: Colors.grey,
                icon: Icon(FontAwesomeIcons.fire,
                    size: 3 * SizeConfig.textMultiplier),
                activeColor: ColorPalette.kPrimaryColor,
              ),
              BottomNavyBarCustomItem(
                inactiveColor: Colors.grey,
                icon: Icon(FontAwesomeIcons.inbox,
                    size: 3 * SizeConfig.textMultiplier),
                activeColor: ColorPalette.kPrimaryColor,
              ),
              BottomNavyBarCustomItem(
                inactiveColor: Colors.grey,
                icon: Icon(FontAwesomeIcons.user,
                    size: 3 * SizeConfig.textMultiplier),
                activeColor: ColorPalette.kPrimaryColor,
              ),
            ]));
  }
}
