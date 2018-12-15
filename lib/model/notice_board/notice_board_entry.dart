import 'package:meta/meta.dart';

/// Entry in the notice board.
class NoticeBoardEntry {
  /// Author of the notice board entry.
  final String author;

  /// Title of the notice board entry.
  final String title;

  /// Content of the notice board entry.
  /// May contain HTML.
  final String content;

  /// From which date the entry is valid.
  final DateTime validFrom;

  /// To which date the entry is valid.
  final DateTime validTo;

  /// Create new notice board entry.
  NoticeBoardEntry({@required this.author, @required this.title, @required this.content, @required this.validFrom, @required this.validTo});
}
