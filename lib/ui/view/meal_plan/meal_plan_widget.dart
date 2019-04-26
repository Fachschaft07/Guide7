import 'package:flutter/widgets.dart';
import 'package:guide7/model/meal_plan/meal_plan.dart';

/// Widget displaying a meal plan.
class MealPlanWidget extends StatelessWidget {
  /// Meal plan to display.
  final MealPlan mealPlan;

  /// Create widget.
  MealPlanWidget({
    @required this.mealPlan,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = List<Widget>();

    for (int i = 0; i < 100; i++) {
      rows.add(Padding(
        padding: EdgeInsets.all(20.0),
        child: Text(mealPlan.meals.first.name),
      ));
    }

    return Column(
      children: rows,
    );
  }
}
