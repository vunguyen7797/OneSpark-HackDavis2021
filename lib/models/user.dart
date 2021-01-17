import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_spark/blocs/user_bloc.dart';
import 'package:one_spark/helper/constant.dart';
import 'package:one_spark/helper/size_config.dart';

class UserModel implements ListInboxItem {
  String uid;
  String displayName;
  String email;
  String organization;
  String photoUrl;
  String position;
  String bio;
  List<String> role;
  List<String> interests;
  List<String> followedProjects;

  UserModel(
      {this.uid,
      this.displayName,
      this.email,
      this.organization,
      this.photoUrl,
      this.position,
      this.role,
      this.bio,
      this.interests,
      this.followedProjects});

  factory UserModel.fromMapUser(Map<String, dynamic> data) {
    return UserModel(
        uid: data['uid'],
        displayName: data['displayName'],
        email: data['email'],
        organization: data['organization'],
        photoUrl: data['photoUrl'],
        position: data['position'],
        role: List.from(data['role']),
        bio: data['bio'],
        interests: List.from(data['interests']),
        followedProjects: List.from(data['followedProjects']));
  }

  @override
  Widget buildTitle(BuildContext context) {
    return Text(
      displayName,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.rubik(
        color: ColorPalette.kPrimaryColor,
        fontSize: 4 * SizeConfig.textMultiplier,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget buildImage(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: photoUrl,
      imageBuilder: (context, imageProvider) => ClipRRect(
        borderRadius: BorderRadius.circular(5 * SizeConfig.heightMultiplier),
        child: Container(
          height: 8 * SizeConfig.heightMultiplier,
          width: 8 * SizeConfig.heightMultiplier,
          decoration: BoxDecoration(
              image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          )),
        ),
      ),
      placeholder: (context, url) => Container(
        height: 8 * SizeConfig.heightMultiplier,
        width: 8 * SizeConfig.heightMultiplier,
        decoration: BoxDecoration(
          color: Colors.white30,
          borderRadius: BorderRadius.circular(5 * SizeConfig.heightMultiplier),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: 8 * SizeConfig.heightMultiplier,
        width: 8 * SizeConfig.heightMultiplier,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(5 * SizeConfig.heightMultiplier),
        ),
        child: Icon(Icons.error),
      ),
    );
  }

  @override
  // TODO: implement name
  String get name => displayName;

  @override
  // TODO: implement id
  String get id => uid;
}
