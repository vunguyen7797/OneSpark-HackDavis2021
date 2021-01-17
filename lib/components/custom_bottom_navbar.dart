import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_spark/helper/size_config.dart';

import 'custom_fade_in.dart';

class CustomBottomNavyBar extends StatelessWidget {
  final int selectedIndex;
  final double iconSize;
  final Color backgroundColor;
  final bool showElevation;
  final Duration animationDuration;
  final List<BottomNavyBarCustomItem> items;
  final ValueChanged<int> onItemSelected;
  final MainAxisAlignment mainAxisAlignment;
  final double itemCornerRadius;
  final double containerHeight;
  final Curve curve;
  final double containerWidth;
  final enableAnimation;
  final BottomNavyBarCustomItem homeItem;

  CustomBottomNavyBar({
    Key key,
    this.homeItem,
    this.containerWidth,
    this.selectedIndex = 0,
    this.showElevation = true,
    this.iconSize = 24,
    this.backgroundColor,
    this.enableAnimation,
    this.itemCornerRadius = 50,
    this.containerHeight = 56,
    this.animationDuration = const Duration(milliseconds: 0),
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    @required this.items,
    @required this.onItemSelected,
    this.curve = Curves.linear,
  }) {
    assert(items != null);
    assert(items.length >= 2 && items.length <= 5);
    assert(onItemSelected != null);
    assert(curve != null);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = (backgroundColor == null)
        ? Theme.of(context).bottomAppBarColor
        : backgroundColor;

    return SafeArea(
      child: CustomFadeIn(
        delay: enableAnimation == false ? 0 : 2,
        transformDuration: enableAnimation == false ? 0 : null,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5 * SizeConfig.heightMultiplier),
                topRight: Radius.circular(5 * SizeConfig.heightMultiplier)),
            boxShadow: [
              if (showElevation)
                BoxShadow(
                    offset: Offset(0, 0),
                    color: Colors.blueGrey.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 8),
          width: double.infinity,
          height: containerHeight * 1.0,
          child: Row(
            mainAxisAlignment: mainAxisAlignment,
            children: items.map((item) {
              var index = items.indexOf(item);
              return CustomFadeIn(
                delay: enableAnimation == false ? 0 : index.toDouble() + 0.25,
                transformDuration: enableAnimation == false ? 0 : null,
                transform: false,
                child: CustomBounceAnimationWidget(
                    onTap: () => onItemSelected(index),
                    child: _ItemWidget(
                      item: item,
                      iconSize: iconSize,
                      isSelected: index == selectedIndex,
                      backgroundColor: bgColor,
                      itemCornerRadius: itemCornerRadius,
                      animationDuration: animationDuration,
                      curve: curve,
                      containerHeight: containerHeight,
                    )),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _ItemWidget extends StatelessWidget {
  final double iconSize;
  final bool isSelected;
  final BottomNavyBarCustomItem item;
  final Color backgroundColor;
  final double itemCornerRadius;
  final Duration animationDuration;
  final Curve curve;
  final containerHeight;

  const _ItemWidget({
    Key key,
    this.containerHeight,
    @required this.item,
    @required this.isSelected,
    @required this.backgroundColor,
    @required this.animationDuration,
    @required this.itemCornerRadius,
    @required this.iconSize,
    this.curve = Curves.linear,
  })  : assert(isSelected != null),
        assert(item != null),
        assert(backgroundColor != null),
        assert(animationDuration != null),
        assert(itemCornerRadius != null),
        assert(iconSize != null),
        assert(curve != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: containerHeight * 1,

      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(3.2 * SizeConfig.heightMultiplier),
              topRight: Radius.circular(3.2 * SizeConfig.heightMultiplier))),
      // width: 15 * SizeConfig.widthMultiplier,
      width: MediaQuery.of(context).size.width / 4.3,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconTheme(
            data: IconThemeData(
              size: iconSize,
              color: isSelected
                  ? item.activeColor.withOpacity(1)
                  : item.inactiveColor == null
                      ? item.activeColor
                      : item.inactiveColor,
            ),
            child: item.icon,
          ),
        ],
      ),
    );
  }
}

class BottomNavyBarCustomItem {
  final Icon icon;
  final Text title;
  final Color activeColor;
  final Color inactiveColor;
  final TextAlign textAlign;

  BottomNavyBarCustomItem({
    @required this.icon,
    this.title,
    this.activeColor = Colors.blue,
    this.textAlign,
    this.inactiveColor,
  }) {
    assert(icon != null);
  }
}

class CustomBounceAnimationWidget extends StatefulWidget {
  final Widget child;
  final Function onTap;
  const CustomBounceAnimationWidget(
      {Key key, @required this.child, @required this.onTap})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _CustomBounceAnimationWidgetState();
}

class _CustomBounceAnimationWidgetState
    extends State<CustomBounceAnimationWidget>
    with TickerProviderStateMixin<CustomBounceAnimationWidget> {
  AnimationController controller;
  Animation<double> easeInAnimation;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: 180,
        ),
        value: 1.0);
    easeInAnimation = Tween(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.ease,
      ),
    );
    controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onTap == null) {
          return;
        }
        widget.onTap();
        controller.forward().then((val) {
          controller.reverse().then((val) {});
        });
      },
      child: ScaleTransition(
        scale: easeInAnimation,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
