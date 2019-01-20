/// Class providing utility methods when handling with dates.
class DateUtil {
  /// Get calendar week for the passed date.
  static int getWeekOfYear(DateTime date) {
    DateTime weekYearStartDate = _getWeekYearStartDateForDate(date);
    int dayDiff = date.difference(weekYearStartDate).inDays;

    return ((dayDiff + 1) / 7).ceil();
  }

  static DateTime _getWeekYearStartDateForDate(DateTime date) {
    return _getWeekYearStartDate(getWeekYear(date));
  }

  /// Get year for week.
  static int getWeekYear(DateTime date) {
    assert(date.isUtc);

    DateTime weekYearStartDate = _getWeekYearStartDate(date.year);

    // Is in previous week year?
    if (weekYearStartDate.isAfter(date)) {
      return date.year - 1;
    }

    // Is in next week year?
    final nextWeekYearStartDate = _getWeekYearStartDate(date.year + 1);
    if (_isBeforeOrEqual(nextWeekYearStartDate, date)) {
      return date.year + 1;
    }

    return date.year;
  }

  /// Whether [first] is before or equal to [second].
  static _isBeforeOrEqual(DateTime first, DateTime second) {
    return first.isBefore(second) || first.isAtSameMomentAs(second);
  }

  /// Get start date for the passed [year].
  static DateTime _getWeekYearStartDate(int year) {
    DateTime firstDayOfYear = DateTime.utc(year, 1, 1);
    int dayOfWeek = firstDayOfYear.weekday;

    if (dayOfWeek <= DateTime.thursday) {
      return firstDayOfYear.subtract(Duration(days: dayOfWeek - 1));
    } else {
      return firstDayOfYear.add(Duration(days: 8 - dayOfWeek));
    }
  }
}
