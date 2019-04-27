import 'package:flutter/widgets.dart';
import 'package:guide7/model/meal_plan/meal_plan.dart';
import 'package:guide7/ui/view/meal_plan/meal_widget.dart';

/// Widget displaying a meal plan.
class MealPlanWidget extends StatelessWidget {
  /// Meal plan to display.
  final MealPlan mealPlan;

  /// The price category to display prices for.
  final int priceCategory;

  /// Create widget.
  MealPlanWidget({
    @required this.mealPlan,
    @required this.priceCategory,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = List<Widget>();

    for (final meal in mealPlan.meals) {
      rows.add(MealWidget(
        meal: meal,
        priceCategory: priceCategory,
      ));
    }

    return Column(
      children: rows,
    );
  }
}
