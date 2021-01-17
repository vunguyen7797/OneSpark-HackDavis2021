import 'package:flutter/material.dart';

class VideoThumbnail extends StatefulWidget {
  final double width;
  final double height;
  final Widget child;

  const VideoThumbnail({
    Key key,
    @required this.width,
    @required this.height,
    @required this.child,
  }) : super(key: key);

  @override
  _VideoThumbnailState createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(
          color: Colors.white24,
        ),
      ),
      child: ClipRRect(
        child: widget.child,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
    );
  }
}
