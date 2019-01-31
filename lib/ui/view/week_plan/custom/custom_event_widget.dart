import 'package:flutter/widgets.dart';
import 'package:guide7/model/weekplan/custom/custom_event.dart';

/// Widget used to display a custom event.
class CustomEventWidget extends StatelessWidget {
  /// Custom event to display.
  final CustomEvent event;

  /// Create widget.
  CustomEventWidget({
    @required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(event.title),
    );
  }
}
