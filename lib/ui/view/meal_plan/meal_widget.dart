import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/model/meal_plan/meal.dart';
import 'package:guide7/model/meal_plan/meal_plan_info.dart';
import 'package:guide7/util/custom_colors.dart';
import 'package:intl/intl.dart';

/// Widget displaying a meal of a meal plan.
class MealWidget extends StatelessWidget {
  /// Meal to display.
  final Meal meal;

  /// Category of the price to display.
  final int priceCategory;

  /// Create widget.
  MealWidget({
    @required this.meal,
    @required this.priceCategory,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [
      _buildMealHeader(context),
    ];

    if ((meal.notes != null && meal.notes.isNotEmpty) || (meal.prices != null && meal.prices.hasPrice && _getMealPrice() != null)) {
      rows.add(_buildMealNotes(context));
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Theme.of(context).dividerColor))),
      child: Column(
        children: rows,
      ),
    );
  }

  /// Build the header of a meal.
  Widget _buildMealHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Text(
            meal.name,
            style: TextStyle(fontFamily: "NotoSerifTC"),
          ),
        ),
        Text(
          meal.category,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: CustomColors.slateGrey,
          ),
        ),
      ],
    );
  }

  /// Build the notes for the meal.
  Widget _buildMealNotes(BuildContext context) {
    List<Widget> widgets = [];

    if (meal.notes != null && meal.notes.isNotEmpty) {
      widgets.add(Expanded(
        child: Text(
          meal.notes.join(", "),
          style: TextStyle(
            fontSize: 13.0,
            color: Colors.black38,
          ),
        ),
      ));
    }

    double mealPrice = _getMealPrice();
    if (meal.prices != null && meal.prices.hasPrice && mealPrice != null) {
      NumberFormat format = NumberFormat("0.00", Localizations.localeOf(context).languageCode);

      widgets.add(
        Container(
          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999999.0),
            color: CustomColors.lightCoral,
          ),
          child: Text(
            "${format.format(mealPrice)} €",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: widgets,
      ),
    );
  }

  /// Get the meal price.
  double _getMealPrice() {
    switch (priceCategory) {
      case MealPlanInfo.student:
        return meal.prices.students;
      case MealPlanInfo.employee:
        return meal.prices.employees;
      case MealPlanInfo.pupil:
        return meal.prices.pupils;
      default:
        return meal.prices.others;
    }
  }
}
