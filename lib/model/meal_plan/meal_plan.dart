import 'package:guide7/model/meal_plan/meal.dart';
import 'package:meta/meta.dart';

/// Meal plan representation.
class MealPlan {
  /// Id of the canteen of the meal plan.
  final int canteenId;

  /// Date of the meal plan.
  final DateTime date;

  /// List of meals.
  final List<Meal> meals;

  /// Create meal plan.
  const MealPlan({
    @required this.canteenId,
    @required this.date,
    @required this.meals,
  });
}
