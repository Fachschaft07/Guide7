import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/model/notice_board/notice_board_entry.dart';
import 'package:guide7/util/custom_colors.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Widget displaying a notice board entry.
class NoticeBoardEntryWidget extends StatefulWidget {
  /// Notice board entry to show.
  final NoticeBoardEntry entry;

  /// Whether it is the last entry in the list.
  final bool isLast;

  /// Avatar image of the author.
  final Uint8List avatarImage;

  /// Create new entry widget.
  NoticeBoardEntryWidget({
    @required this.entry,
    @required this.isLast,
    this.avatarImage,
  });

  @override
  State<StatefulWidget> createState() => _NoticeBoardEntryWidgetState();
}

/// State of the notice board entry widget.
class _NoticeBoardEntryWidgetState extends State<NoticeBoardEntryWidget> with SingleTickerProviderStateMixin {
  /// Duration of the entry validity progress animation.
  static const Duration _validityProgressAnimationDuration = Duration(seconds: 3);

  /// Animation controller to control the entry validity progress.
  AnimationController _validityProgressAnimationController;

  /// Current state of the entry validity progress animation.
  Animation<double> _validityProgressAnimation;

  /// Current state of the entry validity progress color animation.
  Animation<Color> _validityProgressColorAnimation;

  @override
  void initState() {
    super.initState();

    _initValidityProgressAnimation();
  }

  /// Initialize the entries validity progress animation.
  void _initValidityProgressAnimation() {
    _validityProgressAnimationController = AnimationController(duration: _validityProgressAnimationDuration, vsync: this);
    _validityProgressAnimation = Tween<double>(begin: 0.0, end: _getEntryProgress(widget.entry))
        .chain(
          CurveTween(
            curve: Curves.easeOut,
          ),
        )
        .animate(_validityProgressAnimationController);

    _validityProgressColorAnimation = ColorTween(begin: Colors.black12, end: CustomColors.lightCoral).animate(_validityProgressAnimation);

    _validityProgressAnimation.addListener(() {
      setState(() {});
    });

    _validityProgressAnimationController.forward(); // Start animation.
  }

  @override
  void dispose() {
    _validityProgressAnimationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat.yMd(Localizations.localeOf(context).languageCode);

    return Container(
      padding: EdgeInsets.only(
        left: 30.0,
        right: 30.0,
        top: 20.0,
        bottom: 20.0,
      ),
      decoration: widget.isLast
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ), // Divider between entries
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.entry.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: "Raleway",
                  ),
                  textAlign: TextAlign.left,
                  textScaleFactor: 1.2,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: _getCircleAvatar(),
              )
            ],
          ),
          Container(
            padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
            child: MarkdownBody(
              data: widget.entry.content,
              styleSheet: _getMarkdownStylesheet(context),
            ),
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: Icon(
                  Icons.person,
                  color: CustomColors.slateGrey,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  widget.entry.author,
                  style: TextStyle(fontFamily: "Raleway"),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: Text(
                    "${dateFormat.format(widget.entry.validFrom)} - ${dateFormat.format(widget.entry.validTo)}",
                    style: TextStyle(fontFamily: "Raleway"),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 5),
                child: SizedBox(
                  height: 50.0,
                  width: 50.0,
                  child: Stack(
                    fit: StackFit.loose,
                    children: <Widget>[
                      Center(
                        child: CircularProgressIndicator(
                          value: _validityProgressAnimation.value,
                          strokeWidth: 2.0,
                          valueColor: _validityProgressColorAnimation,
                        ),
                      ),
                      Center(
                        child: Text(
                          "${(_validityProgressAnimation.value * 100).round()}%",
                          style: TextStyle(
                            color: _validityProgressColorAnimation.value,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Get validity progress of the entry.
  double _getEntryProgress(NoticeBoardEntry entry) {
    DateTime now = DateTime.now();

    int progress = max(now.difference(entry.validFrom).inMinutes, 0);
    int total = entry.validTo.difference(entry.validFrom).inMinutes;

    return progress / total;
  }

  /// Get the stylesheet to style the markdown content of the entry.
  MarkdownStyleSheet _getMarkdownStylesheet(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return MarkdownStyleSheet.fromTheme(themeData).copyWith(p: themeData.textTheme.body1.copyWith(fontFamily: "NotoSerifTC"));
  }

  /// Get initials of the passed author.
  String _getAuthorInitials(String authorName) {
    List<String> nameParts = authorName.split(" ");

    if (nameParts.length != 2) {
      // Return just the first initial character.
      return authorName.substring(0, 1);
    }

    return nameParts.map((part) => part.substring(0, 1)).join();
  }

  /// Get circle avatar image or initials of the author.
  Widget _getCircleAvatar() {
    if (widget.avatarImage == null) {
      return CircleAvatar(
        child: Text(
          _getAuthorInitials(widget.entry.author),
          style: TextStyle(fontFamily: "Roboto"),
        ),
        radius: 25.0,
        backgroundColor: CustomColors.slateGrey,
        foregroundColor: Colors.white,
      );
    } else {
      return CircleAvatar(
        backgroundImage: MemoryImage(widget.avatarImage),
        radius: 25.0,
      );
    }
  }
}
