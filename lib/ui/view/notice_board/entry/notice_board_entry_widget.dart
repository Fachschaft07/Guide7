import 'package:flutter/widgets.dart';
import 'package:guide7/model/notice_board/notice_board_entry.dart';
import 'package:flutter_html_view/flutter_html_view.dart';

/// Widget displaying a notice board entry.
class NoticeBoardEntryWidget extends StatelessWidget {
  /// Notice board entry to show.
  final NoticeBoardEntry entry;

  /// Create new entry widget.
  NoticeBoardEntryWidget({@required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
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
          ),
        ],
      ),
    );
  }
}
