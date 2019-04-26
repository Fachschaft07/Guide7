import 'package:guide7/model/meal_plan/meal_prices.dart';
import 'package:meta/meta.dart';

/// Meal representation.
class Meal {
  /// Id of the meal.
  final int id;

  /// Name of the meal.
  final String name;

  /// Category of the meal.
  final String category;

  /// The prices for all people categories.
  final MealPrices prices;

  /// Notes of the meal (allergens, etc.).
  final List<String> notes;

  /// Create meal.
  const Meal({
    @required this.id,
    @required this.name,
    @required this.category,
    @required this.prices,
    @required this.notes,
  });
}
