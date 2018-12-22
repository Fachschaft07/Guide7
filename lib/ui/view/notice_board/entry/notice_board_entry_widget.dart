import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/model/notice_board/notice_board_entry.dart';
import 'package:flutter_html_view/flutter_html_view.dart';
import 'package:guide7/util/custom_colors.dart';
import 'package:intl/intl.dart';

/// Widget displaying a notice board entry.
class NoticeBoardEntryWidget extends StatelessWidget {
  /// Date format to format the notice board entry dates.
  static DateFormat _dateFormat = DateFormat("dd.MM.yy");

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
            Text(
              entry.title,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              textScaleFactor: 1.1,
            ),
            HtmlView(
              data: entry.content,
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
            ),
            Row(
              children: <Widget>[
                Icon(
                  Icons.person,
                  color: CustomColors.slateGrey,
                ),
                Expanded(
                  child: Text(
                    entry.author,
                  ),
                ),
                Icon(Icons.timelapse, color: CustomColors.slateGrey),
                Expanded(
                  child: Text("${_dateFormat.format(entry.validFrom)} bis ${_dateFormat.format(entry.validTo)}"),
                )
              ],
            ),
          ],
        ),
      );
}
