import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:one_spark/components/custom_round_button.dart';

class MeetingRoomButtonBar extends StatefulWidget {
  final VoidCallback onVideoEnabled;
  final VoidCallback onAudioEnabled;
  final VoidCallback onHangup;
  final VoidCallback onSwitchCamera;
  final VoidCallback toggleFlashlight;
  final void Function(double) onHeight;
  final VoidCallback onHide;
  final VoidCallback onShow;
  final Stream<bool> videoEnabled;
  final Stream<bool> audioEnabled;
  final Stream<Map<String, bool>> flashState;

  const MeetingRoomButtonBar({
    Key key,
    this.onVideoEnabled,
    this.onAudioEnabled,
    this.onHangup,
    this.onSwitchCamera,
    this.toggleFlashlight,
    @required this.videoEnabled,
    @required this.audioEnabled,
    this.flashState,
    this.onHeight,
    this.onHide,
    this.onShow,
  })  : assert(videoEnabled != null),
        assert(audioEnabled != null),
        super(key: key);

  @override
  _MeetingRoomButtonBarState createState() => _MeetingRoomButtonBarState();
}

class _MeetingRoomButtonBarState extends State<MeetingRoomButtonBar>
    with AfterLayoutMixin<MeetingRoomButtonBar> {
  var _bottom = -100.0;
  Timer _timer;
  int _remaining;
  var _videoEnabled = true;
  var _audioEnabled = true;
  double _hidden;
  double _visible;
  final _keyButtonBarHeight = GlobalKey();
  bool hasFlash = false;
  bool flashEnabled = false;

  final Duration timeout = const Duration(seconds: 5);
  final Duration ms = const Duration(milliseconds: 1);
  final Duration periodicDuration = const Duration(milliseconds: 100);
  final List<StreamSubscription> _subscriptions = [];

  Timer startTimeout([int milliseconds]) {
    final duration = milliseconds == null ? timeout : ms * milliseconds;
    _remaining = duration.inMilliseconds;
    return Timer.periodic(periodicDuration, (Timer timer) {
      _remaining -= periodicDuration.inMilliseconds;
      if (_remaining <= 0) {
        timer.cancel();
        _toggleBar();
      }
    });
  }

  void _pauseTimer() {
    if (_timer == null) {
      return;
    }
    _timer.cancel();
    _timer = null;
  }

  void _resumeTimer() {
    // resume the timer only when there is no timer active or when
    // the bar is not already hidden.
    if ((_timer != null && _timer.isActive) || _bottom == _hidden) {
      return;
    }
    _timer = startTimeout(_remaining);
  }

  void _toggleBar() {
    setState(() {
      _bottom = _bottom == _visible ? _hidden : _visible;
      if (_bottom == _visible && widget.onShow != null) {
        widget.onShow();
      }
      if (_bottom == _hidden && widget.onHide != null) {
        widget.onHide();
      }
    });
  }

  void _toggleBarOnEnd() {
    if (_timer != null) {
      if (_timer.isActive) {
        _timer.cancel();
      }
      _timer = null;
    }
    if (_bottom == 0) {
      _timer = startTimeout();
    }
  }

  @override
  void initState() {
    super.initState();
    _timer = startTimeout();
    _subscriptions.add(widget.flashState.listen((event) => setState(() {
          hasFlash = event['hasFlash'];
          flashEnabled = event['flashEnabled'];
        })));
  }

  @override
  void didChangeDependencies() {
    _visible = MediaQuery.of(context).viewPadding.bottom;
    super.didChangeDependencies();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    final RenderBox renderBoxButtonBar =
        _keyButtonBarHeight.currentContext.findRenderObject();
    final heightButtonBar = renderBoxButtonBar.size.height;
    // Because the `didChangeDependencies` fires before the `afterFirstLayout`, we can use the `_visible` property here.
    _hidden = -(heightButtonBar + _visible);
    widget.onHeight(heightButtonBar);
    _toggleBar();
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
      _timer = null;
    }
    _subscriptions.forEach((subscription) => subscription.cancel());
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        key: Key('show-hide-button-bar-gesture'),
        behavior: HitTestBehavior.translucent,
        onTapDown: (_) => _pauseTimer(),
        onTapUp: (_) => _toggleBar(),
        onTapCancel: () => _resumeTimer(),
        child: Stack(
          children: <Widget>[
            AnimatedPositioned(
              key: Key('button-bar'),
              bottom: _bottom,
              left: 0,
              right: 0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear,
              child: _buildButtonRow(context),
              onEnd: _toggleBarOnEnd,
            ),
          ],
        ),
      ),
    );
  }

  void _onPressed(VoidCallback callback) {
    if (callback != null) {
      callback();
    }
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
    }
    _timer = startTimeout();
  }

  Widget _buildButtonRow(BuildContext context) {
    return Padding(
      key: _keyButtonBarHeight,
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          CustomRoundButton(
            child: StreamBuilder<bool>(
                stream: widget.videoEnabled,
                initialData: _videoEnabled,
                builder: (context, snapshot) {
                  _videoEnabled = snapshot.data;
                  return Icon(
                    _videoEnabled ? Icons.videocam : Icons.videocam_off,
                    color: Colors.white,
                  );
                }),
            key: Key('camera-button'),
            onPressed: () => _onPressed(widget.onVideoEnabled),
          ),
          CustomRoundButton(
            radius: 35,
            child: const RotationTransition(
              turns: AlwaysStoppedAnimation<double>(135 / 360),
              child: Icon(
                Icons.phone,
                color: Colors.white,
                size: 40,
              ),
            ),
            color: Colors.red.withAlpha(200),
            key: Key('hangup-button'),
            onPressed: () => _onPressed(widget.onHangup),
          ),
          CustomRoundButton(
            child: StreamBuilder<bool>(
                stream: widget.audioEnabled,
                initialData: _audioEnabled,
                builder: (context, snapshot) {
                  _audioEnabled = snapshot.data;
                  return Icon(
                    _audioEnabled ? Icons.mic : Icons.mic_off,
                    color: Colors.white,
                  );
                }),
            key: Key('microphone-button'),
            onPressed: () => _onPressed(widget.onAudioEnabled),
          ),
        ],
      ),
    );
  }
}
