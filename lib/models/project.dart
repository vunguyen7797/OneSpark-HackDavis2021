import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_spark/blocs/user_bloc.dart';
import 'package:one_spark/helper/constant.dart';
import 'package:one_spark/helper/size_config.dart';

class Project implements ListInboxItem {
  String pid;
  String name;
  String location;
  String description;
  String photoUrl;
  String author;
  List<String> tags;
  double donation;
  double popScore;

  Project(
      {this.pid,
      this.name,
      this.location,
      this.description,
      this.photoUrl,
      this.author,
      this.donation,
      this.popScore,
      this.tags});

  factory Project.fromMapProject(Map<String, dynamic> data) {
    return Project(
      pid: data['pid'],
      name: data['name'] ?? "",
      location: data['location'] ?? "",
      description: data['description'] ?? "",
      photoUrl: data['photoURL'],
      author: data['author'] ?? "",
      tags: List.from(data['tags']) ?? List(),
      donation: data['donation'].toDouble() ?? 0.0,
      popScore: data['popScore'].toDouble() ?? 0.0,
    );
  }

  @override
  Widget buildTitle(BuildContext context) {
    return Text(
      name,
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
  String get id => pid;
}
