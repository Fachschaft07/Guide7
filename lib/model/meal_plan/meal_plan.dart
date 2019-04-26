import 'package:guide7/model/meal_plan/meal.dart';
import 'package:meta/meta.dart';

/// Meal plan representation.
class MealPlan {
  /// List of meals.
  final List<Meal> meals;

  /// Create meal plan.
  const MealPlan({
    @required this.meals,
  });
}
