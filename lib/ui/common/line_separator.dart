import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Line separator UI widget.
class LineSeparator extends StatelessWidget {
  /// Default color of the separator.
  static const Color DEFAULT_COLOR = const Color(0xFFDDDDDD);

  /// Default color of the text.
  static const Color DEFAULT_TEXT_COLOR = const Color(0xFF707070);

  /// Default thickness of the line.
  static const double DEFAULT_THICKNESS = 1.0;

  /// Default padding of the separator.
  static const double DEFAULT_PADDING = 0.0;

  /// Title to display in the widget.
  final String title;

  /// Color of the line.
  final Color color;

  /// Color of the title.
  final Color textColor;

  /// Thickness of the line.
  final double thickness;

  /// Padding of the line.
  final double padding;

  /// Whether the text is shown in bold or not.
  final bool isBold;

  /// Create line separator.
  LineSeparator({
    @required this.title,
    this.color = DEFAULT_COLOR,
    this.textColor = DEFAULT_TEXT_COLOR,
    this.thickness = DEFAULT_THICKNESS,
    this.padding = DEFAULT_PADDING,
    this.isBold = false,
  });

  @override
  build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    TextSpan span = new TextSpan(
      style: new TextStyle(
        color: isBold ? Colors.grey[600] : textColor,
        fontSize: isBold ? 23.0 : 20.0,
        fontWeight: isBold ? FontWeight.w600 : FontWeight.w300,
        letterSpacing: isBold ? 2.5 : 3.0,
      ),
      text: title,
    );
    TextPainter tp = new TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    return new Container(
      child: new CustomPaint(
        painter: new _LineSeparatorPainter(
          tp: tp,
          thickness: thickness,
          color: color,
          textColor: textColor,
          padding: padding,
        ),
      ),
      height: tp.height,
      width: size.width,
    );
  }
}

/// Painter for the separator line.
class _LineSeparatorPainter extends CustomPainter {
  final TextPainter tp;
  final Color color;
  final Color textColor;
  final double thickness;
  final double padding;

  /// Create line separator painter.
  _LineSeparatorPainter({
    @required this.tp,
    @required this.thickness,
    @required this.color,
    @required this.textColor,
    @required this.padding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Offset.zero & size;

    Paint paint = new Paint()..color = color;

    double padding = this.padding;
    double yOffset = rect.height / 2 - thickness / 2;
    double insets = rect.width * 0.02;

    if ((tp.text as TextSpan).text == null || (tp.text as TextSpan).text.isEmpty) {
      insets = 0.0;
    }

    double textXOffset = rect.width / 2 - tp.width / 2;
    double textYOffset = rect.height / 2 - tp.height / 2;

    Rect leftRect = new Rect.fromPoints(
      new Offset(
        padding,
        yOffset,
      ),
      new Offset(
        textXOffset - insets,
        yOffset + thickness,
      ),
    );
    Rect rightRect = new Rect.fromPoints(
      new Offset(
        rect.width / 2 + tp.width / 2 + insets,
        yOffset,
      ),
      new Offset(
        rect.width - padding,
        yOffset + thickness,
      ),
    );

    canvas.drawRect(leftRect, paint);
    canvas.drawRect(rightRect, paint);

    tp.paint(canvas, new Offset(textXOffset, textYOffset));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
