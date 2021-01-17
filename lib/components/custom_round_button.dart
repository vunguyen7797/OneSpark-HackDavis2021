import 'dart:async';

import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

class CustomRoundButton extends StatefulWidget {
  final VoidCallback onLongPress;
  final VoidCallback onPressed;
  final GestureTapDownCallback onTapDown;
  final VoidCallback onTapCancel;
  final Widget child;
  final Color color;
  final double radius;

  const CustomRoundButton({
    Key key,
    this.onLongPress,
    this.onPressed,
    this.child,
    this.color,
    this.radius = 25.0,
    this.onTapCancel,
    this.onTapDown,
  })  : assert(radius != null),
        super(key: key);

  @override
  _CustomRoundButtonState createState() => _CustomRoundButtonState();
}

class _CustomRoundButtonState extends State<CustomRoundButton> {
  double _rotationAngle = 0.0;

  final Stream<NativeDeviceOrientation> _orientationStream =
      NativeDeviceOrientationCommunicator()
          .onOrientationChanged(useSensor: true);
  StreamSubscription<NativeDeviceOrientation> _orientationSubscription;

  void _handleOrientationChange(NativeDeviceOrientation orientation) {
    var targetAngle = 0.0;
    switch (orientation) {
      case NativeDeviceOrientation.unknown:
      case NativeDeviceOrientation.portraitUp:
        targetAngle = 0.0;
        break;
      case NativeDeviceOrientation.portraitDown:
        targetAngle = 180.0;
        break;
      case NativeDeviceOrientation.landscapeLeft:
        targetAngle = 90.0;
        break;
      case NativeDeviceOrientation.landscapeRight:
        targetAngle = 270.0;
        break;
    }
    setState(() {
      _rotationAngle = targetAngle;
    });
  }

  @override
  void initState() {
    super.initState();
    _orientationSubscription = _orientationStream.listen(
      _handleOrientationChange,
      onError: (dynamic err) => print(""),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _orientationSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final size = 2 * widget.radius;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: (widget.color ?? Theme.of(context).primaryColor).withAlpha(200),
        borderRadius: BorderRadius.all(
          Radius.circular(widget.radius),
        ),
      ),
      child: GestureDetector(
        onLongPress: widget.onLongPress,
        onTapDown: widget.onTapDown,
        onTapCancel: widget.onTapCancel,
        child: RawMaterialButton(
          onPressed: widget.onPressed,
          child: RotationTransition(
            child: widget.child,
            turns: AlwaysStoppedAnimation<double>(_rotationAngle / 360),
          ),
          elevation: 0,
          shape: const CircleBorder(),
        ),
      ),
    );
  }
}
