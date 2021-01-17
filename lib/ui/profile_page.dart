import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_spark/blocs/auth_bloc.dart';
import 'package:one_spark/blocs/user_bloc.dart';
import 'package:one_spark/helper/constant.dart';
import 'package:one_spark/helper/size_config.dart';
import 'package:one_spark/ui/login_page.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  TextEditingController _positionController = TextEditingController();
  TextEditingController _organizationController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    Future.delayed(Duration(seconds: 0), () {
      final userBloc = Provider.of<UserBloc>(context);
      _nameController.text = userBloc.name;
      _bioController.text = userBloc.bio;
      _emailController.text = userBloc.email;
      _locationController.text = userBloc.location;
      _positionController.text = userBloc.position;
      _organizationController.text = userBloc.organization;
    });
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _positionController.dispose();
    _organizationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userBloc = Provider.of<UserBloc>(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 5 * SizeConfig.heightMultiplier,
                ),
                Text(
                  'My Profile',
                  style: GoogleFonts.rubik(
                    color: ColorPalette.kPrimaryColor,
                    fontSize: 5 * SizeConfig.textMultiplier,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 3 * SizeConfig.heightMultiplier,
                ),
                CachedNetworkImage(
                  imageUrl: userBloc.photoUrl,
                  imageBuilder: (context, imageProvider) => ClipRRect(
                    borderRadius:
                        BorderRadius.circular(20 * SizeConfig.heightMultiplier),
                    child: Container(
                      height: 23 * SizeConfig.heightMultiplier,
                      width: 23 * SizeConfig.heightMultiplier,
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
                          20 * SizeConfig.heightMultiplier),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 23 * SizeConfig.heightMultiplier,
                    width: 15 * SizeConfig.heightMultiplier,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(
                          20 * SizeConfig.heightMultiplier),
                    ),
                    child: Icon(Icons.error),
                  ),
                ),
                SizedBox(
                  height: 2 * SizeConfig.heightMultiplier,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 5 * SizeConfig.widthMultiplier),
                  child: Tags(
                    itemCount: userBloc.interests.length,
                    alignment: WrapAlignment.start,
                    itemBuilder: (int index) {
                      return ItemTags(
                        title: userBloc.interests[index],
                        index: index,
                        activeColor: ColorPalette.kAccentColor.withOpacity(0.7),
                        padding: EdgeInsets.symmetric(
                            vertical: 0.8 * SizeConfig.heightMultiplier,
                            horizontal: 3 * SizeConfig.widthMultiplier),
                        elevation: 0,
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 2 * SizeConfig.heightMultiplier,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10 * SizeConfig.widthMultiplier),
                  child: Column(
                    children: [
                      TextField(
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rubik(
                            color: CupertinoColors.black,
                            fontSize: 2 * SizeConfig.textMultiplier),
                        decoration: InputDecoration(
                          labelText: 'Preferred Name',
                          labelStyle: GoogleFonts.rubik(
                              color: ColorPalette.kPrimaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 2 * SizeConfig.textMultiplier),
                        ),
                        controller: _nameController,
                      ),
                      TextField(
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rubik(
                            color: CupertinoColors.black,
                            fontSize: 2 * SizeConfig.textMultiplier),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: GoogleFonts.rubik(
                              color: ColorPalette.kPrimaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 2 * SizeConfig.textMultiplier),
                        ),
                        controller: _emailController,
                      ),
                      TextField(
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rubik(
                            color: CupertinoColors.black,
                            fontSize: 2 * SizeConfig.textMultiplier),
                        decoration: InputDecoration(
                          labelText: 'Position',
                          labelStyle: GoogleFonts.rubik(
                              color: ColorPalette.kPrimaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 2 * SizeConfig.textMultiplier),
                        ),
                        controller: _positionController,
                      ),
                      TextField(
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rubik(
                            color: CupertinoColors.black,
                            fontSize: 2 * SizeConfig.textMultiplier),
                        decoration: InputDecoration(
                          labelText: 'Organization',
                          labelStyle: GoogleFonts.rubik(
                              color: ColorPalette.kPrimaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 2 * SizeConfig.textMultiplier),
                        ),
                        controller: _organizationController,
                      ),
                      TextField(
                        style: GoogleFonts.rubik(
                            color: CupertinoColors.black,
                            fontSize: 2 * SizeConfig.textMultiplier),
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Bio',
                          labelStyle: GoogleFonts.rubik(
                              color: ColorPalette.kPrimaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 2 * SizeConfig.textMultiplier),
                        ),
                        controller: _bioController,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 5 * SizeConfig.widthMultiplier,
                      vertical: 5 * SizeConfig.heightMultiplier),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () async {
                        final authBloc = Provider.of<AuthBloc>(context);
                        await authBloc.signOut();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: ColorPalette.kPrimaryColor,
                            borderRadius: BorderRadius.circular(30)),
                        padding: EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.exit_to_app,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 3 * SizeConfig.widthMultiplier,
                            ),
                            Text(
                              'Sign Out',
                              style: GoogleFonts.rubik(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
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
}
