import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// A circular progress indicator showing the progress as percent.
class NumberedCircularProgressIndicator extends StatefulWidget {
  /// Default duration of the animation.
  static const Duration _defaultDuration = Duration(seconds: 1);

  /// Default color of the indicator in the beginning of the animation.
  static const Color _defaultBeginColor = Colors.black26;

  /// Default color of the indicator in the end of the animation.
  static const Color _defaultEndColor = Colors.redAccent;

  /// Default curve of the animation.
  static const Curve _defaultCurve = Curves.easeOut;

  /// Default size of the indicator.
  static const double _defaultSize = 50.0;

  /// Default stroke with of the indicator.
  static const double _defaultStrokeWidth = 2.0;

  /// Progress to show. In range [0.0, 1.0].
  final double progress;

  /// Begin color for the animation of the circular progress indicator.
  final Color begin;

  /// End color for the animation of the circular progress indicator.
  final Color end;

  /// Duration of the animation.
  final Duration duration;

  /// Curve to use for the animation.
  final Curve curve;

  /// Size of the indicator in logical pixels.
  final double size;

  /// Stroke width of the indicator.
  final double strokeWidth;

  /// Create indicator.
  NumberedCircularProgressIndicator({
    @required this.progress,
    this.duration = _defaultDuration,
    this.begin = _defaultBeginColor,
    this.end = _defaultEndColor,
    this.curve = _defaultCurve,
    this.size = _defaultSize,
    this.strokeWidth = _defaultStrokeWidth,
  });

  @override
  State<StatefulWidget> createState() => _NumberedCircularProgressIndicatorState();
}

/// State of the numbered circular progress indicator widget.
class _NumberedCircularProgressIndicatorState extends State<NumberedCircularProgressIndicator> with SingleTickerProviderStateMixin {
  /// Animation controller to control the entry validity progress.
  AnimationController _animationController;

  /// Current state of the entry validity progress animation.
  Animation<double> _valueAnimation;

  /// Current state of the entry validity progress color animation.
  Animation<Color> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _initAnimation();
  }

  void _initAnimation() {
    _animationController = AnimationController(duration: widget.duration, vsync: this);
    _valueAnimation = Tween<double>(begin: 0.0, end: widget.progress)
        .chain(
          CurveTween(
            curve: widget.curve,
          ),
        )
        .animate(_animationController);

    _colorAnimation = ColorTween(begin: widget.begin, end: widget.end).animate(_valueAnimation);

    _valueAnimation.addListener(() {
      setState(() {});
    });

    _animationController.forward(); // Start animation.
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: widget.size,
        width: widget.size,
        child: Stack(
          fit: StackFit.loose,
          children: <Widget>[
            Center(child: _buildProgressIndicator()),
            Center(child: _buildText()),
          ],
        ),
      );

  /// Build the progress indicator to show the animation value with.
  Widget _buildProgressIndicator() => CircularProgressIndicator(
        value: _valueAnimation.value,
        strokeWidth: widget.strokeWidth,
        valueColor: _colorAnimation,
      );

  /// Build the progress text to show.
  Text _buildText() => Text(
        _getProgressDisplayString(),
        style: TextStyle(
          color: _colorAnimation.value,
        ),
      );

  /// Get the progress string to display.
  String _getProgressDisplayString() => "${(_valueAnimation.value * 100).round()}%";
}
