import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/model/notice_board/notice_board_entry.dart';
import 'package:flutter_html_view/flutter_html_view.dart';

/// Widget displaying a notice board entry.
class NoticeBoardEntryWidget extends StatelessWidget {
  /// Notice board entry to show.
  final NoticeBoardEntry entry;

  /// Whether it is the last entry in the list.
  final bool isLast;

  /// Create new entry widget.
  NoticeBoardEntryWidget({@required this.entry, @required this.isLast});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.only(
          left: 30.0,
          right: 30.0,
          top: 20.0,
          bottom: 20.0,
        ),
        decoration: isLast ? null : BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))), // Divider between entries
        child: Column(
          children: <Widget>[
            Text(
              entry.title,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              entry.author,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            HtmlView(
              data: entry.content,
              padding: EdgeInsets.all(0),
            )
          ],
        ),
      );
}
