import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_spark/blocs/auth_bloc.dart';
import 'package:one_spark/helper/constant.dart';
import 'package:one_spark/helper/size_config.dart';
import 'package:one_spark/ui/dashboard_page.dart';
import 'package:one_spark/ui/login_page.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({
    Key key,
  }) : super(key: key);
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    /// Show splash screen for 2 seconds
    Future.delayed(
      Duration(seconds: 2),
      () async {
        final AuthBloc signInBloc = Provider.of<AuthBloc>(context);

        signInBloc.isLoggedIn();

        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
                pageBuilder: (_, __, ___) => signInBloc.isSignedIn == false
                    ? LoginPage()
                    : DashboardPage()));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                height: 20 * SizeConfig.heightMultiplier,
                width: 20 * SizeConfig.heightMultiplier,
                child: Image.asset('res/images/OneSpark-logo.png'),
              ),
            ),
            Text('OneSpark',
                style: GoogleFonts.rubik(
                  fontWeight: FontWeight.bold,
                  color: ColorPalette.kPrimaryColor,
                  fontSize: 5 * SizeConfig.textMultiplier,
                ))
          ],
        ),
      ),
    );
  }
}
