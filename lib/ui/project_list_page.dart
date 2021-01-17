import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:one_spark/blocs/projects_bloc.dart';
import 'package:one_spark/components/custom_search_bar.dart';
import 'package:one_spark/helper/constant.dart';
import 'package:one_spark/helper/size_config.dart';
import 'package:one_spark/models/project.dart';
import 'package:one_spark/ui/project_info_page.dart';
import 'package:provider/provider.dart';

class ProjectListPage extends StatefulWidget {
  @override
  _ProjectListPageState createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  @override
  Widget build(BuildContext context) {
    final projectBloc = Provider.of<ProjectsBloc>(context);
    List<Project> projectList = projectBloc.projectList;
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                delegate: ProjectPageHeader(45 * SizeConfig.heightMultiplier,
                    45 * SizeConfig.heightMultiplier),
                floating: false,
                pinned: true,
              ),
              SliverPadding(
                  padding:
                      EdgeInsets.only(bottom: 2 * SizeConfig.heightMultiplier)),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProjectInfoPage(
                                    project: projectList[index],
                                  )));
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 1 * SizeConfig.heightMultiplier,
                          horizontal: 5 * SizeConfig.widthMultiplier),
                      child: Container(
                        height: 35 * SizeConfig.heightMultiplier,
                        child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  5 * SizeConfig.heightMultiplier),
                            ),
                            color: Colors.white,
                            child: Stack(
                              children: [
                                Column(
                                  children: <Widget>[
                                    Container(
                                        child: Stack(
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: projectList[index].photoUrl,
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  ClipRRect(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(5 *
                                                  SizeConfig.heightMultiplier),
                                              topRight: Radius.circular(5 *
                                                  SizeConfig.heightMultiplier),
                                            ),
                                            child: Container(
                                              height: 24 *
                                                  SizeConfig.heightMultiplier,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              )),
                                            ),
                                          ),
                                          placeholder: (context, url) =>
                                              Container(
                                            height: 24 *
                                                SizeConfig.heightMultiplier,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.white30,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(5 *
                                                    SizeConfig
                                                        .heightMultiplier),
                                                topRight: Radius.circular(5 *
                                                    SizeConfig
                                                        .heightMultiplier),
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            height: 24 *
                                                SizeConfig.heightMultiplier,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(5 *
                                                    SizeConfig
                                                        .heightMultiplier),
                                                topRight: Radius.circular(5 *
                                                    SizeConfig
                                                        .heightMultiplier),
                                              ),
                                            ),
                                            child: Icon(Icons.error),
                                          ),
                                        ),
                                      ],
                                    )),
                                    SizedBox(
                                      height: 1 * SizeConfig.heightMultiplier,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal:
                                              4 * SizeConfig.widthMultiplier),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          projectList[index].name,
                                          maxLines: 1,
                                          textAlign: TextAlign.left,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.rubik(
                                            color: CupertinoColors.black,
                                            fontSize:
                                                2 * SizeConfig.textMultiplier,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  top: 28 * SizeConfig.heightMultiplier,
                                  right: 0,
                                  left: 0,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            5 * SizeConfig.widthMultiplier),
                                    child: Text(
                                      projectList[index].description,
                                      maxLines: 2,
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.rubik(
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                        fontSize:
                                            1.75 * SizeConfig.textMultiplier,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                    ),
                  );
                }, childCount: projectList.length),
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

class ProjectPageHeader implements SliverPersistentHeaderDelegate {
  final double minExtent;
  final double maxExtent;

  ProjectPageHeader(this.minExtent, this.maxExtent);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final appBarSize = maxExtent - shrinkOffset;

    final proportion = 2 - (maxExtent / appBarSize);

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
              'Projects\nNeed Help',
              style: GoogleFonts.rubik(
                color: ColorPalette.kPrimaryColor,
                fontSize: 8 * SizeConfig.textMultiplier,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 3 * SizeConfig.heightMultiplier,
            ),
            CustomSearchBar(),
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
