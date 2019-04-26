import 'dart:async';

import 'package:guide7/model/meal_plan/canteen.dart';
import 'package:guide7/model/meal_plan/meal_plan.dart';

/// Repository providing meal plans.
abstract class MealPlanRepository {
  /// Load all available canteens.
  Future<List<Canteen>> loadCanteens();

  /// Load meal plan for the passed [canteen] and [date].
  Future<MealPlan> loadMealPlan(Canteen canteen, DateTime date);
}
