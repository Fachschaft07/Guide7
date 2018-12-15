import 'package:guide7/util/parser/parser.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:intl/intl.dart' show DateFormat;

import 'package:guide7/model/notice_board/notice_board_entry.dart';

/// Parser parsing notice board entries from HTML.
class NoticeBoardHtmlParser implements Parser<String, List<NoticeBoardEntry>> {
  /// Date format used to parse notice board entry dates.
  static DateFormat _dateFormat = DateFormat("dd.MM.yyyy");

  /// Create new notice board HTML parser.
  const NoticeBoardHtmlParser();

  @override
  List<NoticeBoardEntry> parse(String source) {
    List<NoticeBoardEntry> entries = new List<NoticeBoardEntry>();

    Document document = htmlParser.parse(source);

    List<Element> tableBodies = document.getElementsByTagName("tbody");
    for (Element tableBody in tableBodies) {
      _parseTableBody(tableBody, entries);
    }

    return entries;
  }

  /// Parse a table body element which might contain notice board entries.
  void _parseTableBody(Element tableBody, List<NoticeBoardEntry> result) {
    if (!tableBody.hasChildNodes()) {
      return;
    }

    for (Element htmlEntry in tableBody.children) {
      if (htmlEntry == null || !htmlEntry.hasChildNodes()) {
        continue;
      }

      _parseEntry(htmlEntry, result);
    }
  }

  /// Parse a notice board entry in HTML format.
  void _parseEntry(Element htmlEntry, List<NoticeBoardEntry> result) {
    List<Element> entryItems = htmlEntry.children;

    if (entryItems.length < 5) {
      return;
    }

    String author = entryItems[0].text;
    String title = entryItems[1].text;
    String content = entryItems[2].innerHtml;
    DateTime validFrom = _parseDate(entryItems[3].text);
    DateTime validTo = _parseDate(entryItems[4].text);

    result.add(NoticeBoardEntry(author: author, title: title, content: content, validFrom: validFrom, validTo: validTo));
  }

  /// Parse a date for a notice board entry.
  DateTime _parseDate(String toParse) {
    return _dateFormat.parse(toParse);
  }
}
