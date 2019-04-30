import 'dart:async';

import 'package:guide7/connect/meal_plan/meal_plan_repository.dart';
import 'package:guide7/model/meal_plan/canteen.dart';
import 'package:guide7/model/meal_plan/meal.dart';
import 'package:guide7/model/meal_plan/meal_plan.dart';
import 'package:guide7/model/meal_plan/meal_prices.dart';

/// Mock meal plan repository providing fake meal plans.
class MockMealPlanRepository implements MealPlanRepository {
  static const List<Canteen> _mockCanteens = [
    Canteen(
      id: 1,
      name: "Test Canteen 1",
    ),
    Canteen(
      id: 2,
      name: "Test Canteen 2",
    ),
  ];

  static const MealPlan _mockMealPlan = MealPlan(
    canteenId: 1,
    date: null,
    meals: [
      Meal(
        id: 1,
        name: "Meal 1",
        category: "Daily meal",
        prices: MealPrices(
          students: 1.0,
          employees: 2.0,
          pupils: 3.0,
          others: 5.0,
        ),
        notes: [
          "Note 1",
          "Note 2",
        ],
      ),
      Meal(
        id: 2,
        name: "Meal 2",
        category: "Additional meals",
        prices: MealPrices(
          students: 0.5,
          employees: 1.25,
          pupils: 2.0,
          others: 3.4,
        ),
        notes: [
          "Milk",
        ],
      ),
    ],
  );

  @override
  Future<List<Canteen>> loadCanteens() async => _mockCanteens;

  @override
  Future<MealPlan> loadMealPlan(Canteen canteen, DateTime date) async => _mockMealPlan;
}
