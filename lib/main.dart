import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one_spark/blocs/project_feeds_bloc.dart';
import 'package:one_spark/services/cloud_function_service.dart';
import 'package:one_spark/ui/splash_page.dart';
import 'package:provider/provider.dart';

import 'blocs/auth_bloc.dart';
import 'blocs/mentors_bloc.dart';
import 'blocs/projects_bloc.dart';
import 'blocs/user_bloc.dart';
import 'helper/constant.dart';
import 'helper/size_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(OneSpark());
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class OneSpark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    final systemTheme = SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        statusBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.grey);
    SystemChrome.setSystemUIOverlayStyle(systemTheme);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        ChangeNotifierProvider<UserBloc>(
          create: (context) => UserBloc(),
        ),
        ChangeNotifierProvider<ProjectsBloc>(
          create: (context) => ProjectsBloc(),
        ),
        ChangeNotifierProvider<MentorsBloc>(
          create: (context) => MentorsBloc(),
        ),
        ChangeNotifierProvider<ProjectFeedsBloc>(
          create: (context) => ProjectFeedsBloc(),
        ),
        Provider<CloudFunctionService>(
            create: (_) => FirebaseCloudFunctions.instance)
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          return OrientationBuilder(
            builder: (context, orientation) {
              SizeConfig().init(constraints, orientation);
              return MaterialApp(
                  builder: (context, child) {
                    return ScrollConfiguration(
                      behavior: MyBehavior(),
                      child: child,
                    );
                  },
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData.dark().copyWith(
                    primaryColor: ColorPalette.kPrimaryColor,
                    accentColor: ColorPalette.kSecondaryColor,
                    scaffoldBackgroundColor: ColorPalette.kScaffoldColor,
                  ),
                  home: SplashPage());
            },
          );
        },
      ),
    );
  }
}
