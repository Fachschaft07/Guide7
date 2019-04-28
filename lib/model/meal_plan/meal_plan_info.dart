import 'package:meta/meta.dart';

/// Info used to display a meal plan.
class MealPlanInfo {
  /// Student price category.
  static const int student = 0;

  /// Employee price category.
  static const int employee = 1;

  /// Pupil price category.
  static const int pupil = 2;

  /// Others price category.
  static const int other = 3;

  /// Canteen to display a meal plan for.
  final int canteenId;

  /// Category of the price (e. g. student, employee, ...).
  final int priceCategory;

  /// Create info.
  MealPlanInfo({
    @required this.canteenId,
    @required this.priceCategory,
  });
}
