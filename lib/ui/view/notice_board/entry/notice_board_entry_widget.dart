import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/model/notice_board/notice_board_entry.dart';
import 'package:guide7/ui/common/progress/numbered_circle_progress_indicator.dart';
import 'package:guide7/util/custom_colors.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

/// Widget displaying a notice board entry.
class NoticeBoardEntryWidget extends StatelessWidget {
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

  /// Duration of the entry validity progress animation.
  static const Duration _validityProgressAnimationDuration = Duration(seconds: 3);

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
      decoration: isLast
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
                  entry.title,
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
              data: entry.content,
              styleSheet: _getMarkdownStylesheet(context),
              onTapLink: _openLink,
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
                  entry.author,
                  style: TextStyle(fontFamily: "Raleway"),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: Text(
                    "${dateFormat.format(entry.validFrom)} - ${dateFormat.format(entry.validTo)}",
                    style: TextStyle(fontFamily: "Raleway"),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 5),
                child: NumberedCircularProgressIndicator(
                  progress: _getEntryProgress(entry),
                  size: 50.0,
                  strokeWidth: 2.0,
                  begin: Colors.black12,
                  end: CustomColors.lightCoral,
                  curve: Curves.easeOut,
                  duration: _validityProgressAnimationDuration,
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

    if (now.isBefore(entry.validFrom)) {
      return 0.0;
    }

    int progress = max(now.difference(entry.validFrom).inMinutes, 0);
    int total = entry.validTo.difference(entry.validFrom).inMinutes;

    if (total == 0) {
      return 1.0;
    }

    return min(progress / total, 1.0);
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
    if (avatarImage == null) {
      return CircleAvatar(
        child: Text(
          _getAuthorInitials(entry.author),
          style: TextStyle(fontFamily: "Roboto"),
        ),
        radius: 25.0,
        backgroundColor: CustomColors.slateGrey,
        foregroundColor: Colors.white,
      );
    } else {
      return CircleAvatar(
        backgroundImage: MemoryImage(avatarImage),
        radius: 25.0,
      );
    }
  }

  /// Open the passed [link].
  Future<void> _openLink(String link) async {
    String url = Uri.encodeFull(link);

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw Exception("Could not launch $url");
    }
  }
}
