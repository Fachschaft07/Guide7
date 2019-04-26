import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:guide7/connect/meal_plan/meal_plan_repository.dart';
import 'package:guide7/model/meal_plan/canteen.dart';
import 'package:guide7/model/meal_plan/meal.dart';
import 'package:guide7/model/meal_plan/meal_plan.dart';
import 'package:guide7/model/meal_plan/meal_prices.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// Repository providing meal plans from the openmensa API.
class OpenMensaRepository implements MealPlanRepository {
  // Url to the openmensa API.
  static const String _openMensaAPIUrl = "https://openmensa.org/api/v2";

  /// Coordinates of the Lothstr. 64.
  static const Point<double> _lothStr64Coordinates = Point<double>(
    48.1549087, // Latitude
    11.5535108, // Longitude
  );

  /// Date format used to call the web service with a correctly formatted date.
  static DateFormat _dateFormat = DateFormat("yyyy-MM-dd");

  @override
  Future<List<Canteen>> loadCanteens() async {
    http.Response response = await http.get("$_openMensaAPIUrl/canteens?near[lat]=${_lothStr64Coordinates.x}&near[lng]=${_lothStr64Coordinates.y}");

    if (response.statusCode != HttpStatus.ok) {
      throw Exception("Bad status code ${response.statusCode}");
    }

    List<Canteen> canteens = List<Canteen>();

    List<dynamic> jsonCanteens = json.decode(response.body);
    for (final jsonCanteen in jsonCanteens) {
      canteens.add(Canteen(
        id: jsonCanteen["id"],
        name: jsonCanteen["name"],
      ));
    }

    return canteens;
  }

  @override
  Future<MealPlan> loadMealPlan(Canteen canteen, DateTime date) async {
    http.Response response = await http.get("$_openMensaAPIUrl/canteens/${canteen.id}/days/${_dateFormat.format(date)}/meals");

    if (response.statusCode != HttpStatus.ok) {
      throw Exception("Bad status code ${response.statusCode}");
    }

    List<dynamic> jsonMeals = json.decode(response.body);

    List<Meal> meals = List<Meal>();

    for (final jsonMeal in jsonMeals) {
      int id = jsonMeal["id"];
      String name = jsonMeal["name"];
      String category = jsonMeal["category"];

      MealPrices prices;
      final jsonPrices = jsonMeal["prices"];
      if (jsonPrices != null) {
        double students = jsonPrices["students"];
        double employees = jsonPrices["employees"];
        double pupils = jsonPrices["pupils"];
        double others = jsonPrices["others"];

        prices = MealPrices(
          students: students,
          employees: employees,
          pupils: pupils,
          others: others,
        );
      } else {
        prices = MealPrices.empty();
      }

      List<String> notes = List<String>();
      final jsonNotes = jsonMeal["notes"];
      if (jsonNotes != null) {
        for (final note in jsonNotes) {
          notes.add(note);
        }
      }

      meals.add(Meal(
        id: id,
        name: name,
        category: category,
        prices: prices,
        notes: notes,
      ));
    }

    return MealPlan(
      meals: meals,
    );
  }
}
