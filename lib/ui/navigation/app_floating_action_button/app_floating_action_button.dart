import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/ui/navigation/app_floating_action_button/item/app_floating_action_button_item.dart';
import 'package:guide7/util/custom_colors.dart';

/// Floating action button (FAB) for the application.
class AppFloatingActionButton extends StatefulWidget {
  /// Items to show in the button menu.
  final List<AppFloatingActionButtonItem> items;

  /// Create button.
  AppFloatingActionButton({
    @required this.items,
  });

  @override
  State<StatefulWidget> createState() => _AppFloatingActionButtonState();
}

/// State of the applications floating action button (FAB).
class _AppFloatingActionButtonState extends State<AppFloatingActionButton> with SingleTickerProviderStateMixin {
  /// Duration of the open/close animation.
  static const Duration _animationDuration = Duration(milliseconds: 300);

  /// Curve of the open/close animation.
  static const Curve _animationCurve = Curves.easeOut;

  /// Height of the button.
  static const double _buttonHeight = 44.0;

  /// Controller of the open/close animation.
  AnimationController _animationController;

  /// Animation of the button color.
  Animation<Color> _animateColor;

  /// Animation of the button icon.
  Animation<double> _animateIcon;

  /// Animation translating the menu buttons.
  Animation<double> _translateButton;

  /// Whether the action button menu is opened.
  bool _isOpened = false;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: _animationDuration)
      ..addListener(() {
        setState(() {});
      });

    _animateIcon = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    _animateColor = ColorTween(
      begin: CustomColors.slateGrey,
      end: CustomColors.lightCoral,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.0,
          1.0,
          curve: _animationCurve,
        ),
      ),
    );

    _translateButton = Tween<double>(
      begin: _buttonHeight,
      end: -14.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.0,
          0.75,
          curve: _animationCurve,
        ),
      ),
    );

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Do the open/close animation based on the current state of [_isOpened].
  void _doAnimation() {
    if (!_isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    _isOpened = !_isOpened;
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _buildMenu(),
      );

  /// Build the menu.
  List<Widget> _buildMenu() {
    List<Widget> result = List<Widget>();
    for (int i = 0; i < widget.items.length; i++) {
      AppFloatingActionButtonItem item = widget.items[i];

      result.add(
        AnimatedOpacity(
          opacity: _isOpened ? 1.0 : 0.0,
          duration: _animationDuration,
          child: Transform(
            transform: Matrix4.translationValues(0.0, _translateButton.value * (widget.items.length - i), 0.0),
            child: GestureDetector(
              onTap: () {
                if (_isOpened) {
                  item.onPressed();
                }
              },
              child: item,
            ),
          ),
        ),
      );
    }

    result.add(_buildToggleButton());

    return result;
  }

  /// Build the menu toggle button.
  Widget _buildToggleButton() => Container(
        child: FloatingActionButton(
          backgroundColor: _animateColor.value,
          onPressed: _doAnimation,
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _animateIcon,
          ),
          elevation: 2.0,
        ),
      );
}
