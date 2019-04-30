import 'dart:async';

import 'package:guide7/model/meal_plan/meal.dart';
import 'package:guide7/model/meal_plan/meal_plan.dart';
import 'package:guide7/model/meal_plan/meal_prices.dart';
import 'package:guide7/storage/database/app_database.dart';
import 'package:guide7/storage/storage.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';

/// Storage caching meal plans.
class MealPlanStorage implements Storage<List<MealPlan>> {
  /// Meal plan table name.
  static const String _mealTableName = "MEAL_PLAN";

  /// Name of table holding meal prices.
  static const String _mealPriceTableName = "MEAL_PLAN_PRICE";

  /// Name of the table holding meal notes.
  static const String _mealNotesTableName = "MEAL_PLAN_NOTE";

  /// Storage instance.
  static const MealPlanStorage _instance = MealPlanStorage._internal();

  /// Get the storage instance.
  factory MealPlanStorage() => _instance;

  /// Internal singleton constructor.
  const MealPlanStorage._internal();

  @override
  Future<void> clear() async {
    var database = await AppDatabase().getDatabase();

    await database.transaction((transaction) async {
      await transaction.delete(_mealTableName);
      await transaction.delete(_mealPriceTableName);
      await transaction.delete(_mealNotesTableName);
    });
  }

  @override
  Future<bool> isEmpty() async {
    var database = await AppDatabase().getDatabase();

    List<Map<String, dynamic>> result = await database.rawQuery("""
    SELECT COUNT(*) FROM $_mealTableName
    """);

    assert(result.length == 1);
    assert(result[0].values.length == 1);

    var value = result[0].values.first;

    assert(value is int);

    return (value as int) == 0;
  }

  @override
  Future<List<MealPlan>> read() async {
    throw Exception("This operation is not supported. Use readMealPlan(...) instead.");
  }

  @override
  Future<void> write(List<MealPlan> data) async {
    throw Exception("This operation is not supported. Use writeMealPlan(...) instead.");
  }

  /// Read meal plan for the passed [canteenId] and [date].
  Future<MealPlan> readMealPlan(int canteenId, DateTime date) async {
    var database = await AppDatabase().getDatabase();

    List<Map<String, dynamic>> mealResults = await database.transaction((transaction) async {
      return await transaction.rawQuery("""
      SELECT * FROM $_mealTableName
      WHERE canteenId = $canteenId
        AND date = ${date.millisecondsSinceEpoch}
      """);
    });

    List<Map<String, dynamic>> priceResults = await database.transaction((transaction) async {
      return await transaction.rawQuery("""
      SELECT * FROM $_mealPriceTableName
      WHERE canteenId = $canteenId
        AND date = ${date.millisecondsSinceEpoch}
      """);
    });

    List<Map<String, dynamic>> noteResults = await database.transaction((transaction) async {
      return await transaction.rawQuery("""
      SELECT * FROM $_mealNotesTableName
      WHERE canteenId = $canteenId
        AND date = ${date.millisecondsSinceEpoch}
      """);
    });

    return _convertDataSetsToMealPlan(
      canteenId,
      date,
      mealResults,
      priceResults,
      noteResults,
    );
  }

  /// Convert the passed data sets to a meal plan.
  MealPlan _convertDataSetsToMealPlan(
    int canteenId,
    DateTime date,
    List<Map<String, dynamic>> mealResults,
    List<Map<String, dynamic>> priceResults,
    List<Map<String, dynamic>> noteResults,
  ) {
    // Prepare lookups
    Map<_MealKey, List<String>> notesLookup = Map<_MealKey, List<String>>();
    for (Map<String, dynamic> dataSet in noteResults) {
      final key = _MealKey(canteenId: dataSet["canteenId"], date: dataSet["date"], mealId: dataSet["mealId"]);

      List<String> notes = notesLookup.putIfAbsent(key, () => List<String>());
      notes.add(dataSet["note"]);
    }
    Map<_MealKey, MealPrices> pricesLookup = Map<_MealKey, MealPrices>();
    for (Map<String, dynamic> dataSet in priceResults) {
      final key = _MealKey(canteenId: dataSet["canteenId"], date: dataSet["date"], mealId: dataSet["mealId"]);

      pricesLookup[key] = MealPrices(
        students: dataSet["students"],
        employees: dataSet["employees"],
        pupils: dataSet["pupils"],
        others: dataSet["others"],
      );
    }

    List<Meal> meals = List<Meal>();
    for (Map<String, dynamic> dataSet in mealResults) {
      final key = _MealKey(canteenId: dataSet["canteenId"], date: dataSet["date"], mealId: dataSet["mealId"]);

      String name = dataSet["name"];
      String category = dataSet["category"];

      meals.add(Meal(
        id: key.mealId,
        name: name,
        category: category,
        prices: pricesLookup[key],
        notes: notesLookup[key],
      ));
    }

    if (meals.isEmpty) {
      return null;
    } else {
      return MealPlan(
        canteenId: canteenId,
        date: date,
        meals: meals,
      );
    }
  }

  /// Clear meal plan for the passed [canteenId] and [date].
  Future<void> _clearMealPlan(int canteenId, DateTime date, Batch batch) async {
    String where = "canteenId = $canteenId AND date = ${date.millisecondsSinceEpoch}";

    batch.delete(_mealTableName, where: where);
    batch.delete(_mealPriceTableName, where: where);
    batch.delete(_mealNotesTableName, where: where);
  }

  /// Write the passed [mealPlan].
  Future<void> writeMealPlan(MealPlan mealPlan) async {
    var database = await AppDatabase().getDatabase();

    await database.transaction((transaction) async {
      Batch batch = transaction.batch();

      /// First and foremost clear meal plan for the same canteen id and date (if any).
      _clearMealPlan(mealPlan.canteenId, mealPlan.date, batch);

      for (Meal meal in mealPlan.meals) {
        _storeMeal(batch, meal, mealPlan.canteenId, mealPlan.date);
      }

      return await batch.commit(noResult: true);
    });
  }

  /// Store the passed [meal] in the [batch].
  void _storeMeal(Batch batch, Meal meal, int canteenId, DateTime date) {
    batch.insert(_mealTableName, {
      "canteenId": canteenId,
      "date": date.millisecondsSinceEpoch,
      "mealId": meal.id,
      "name": meal.name,
      "category": meal.category,
    });

    batch.insert(_mealPriceTableName, {
      "canteenId": canteenId,
      "date": date.millisecondsSinceEpoch,
      "mealId": meal.id,
      "students": meal.prices.students,
      "employees": meal.prices.employees,
      "pupils": meal.prices.pupils,
      "others": meal.prices.others,
    });

    if (meal.notes != null) {
      for (String note in meal.notes) {
        batch.insert(_mealNotesTableName, {
          "canteenId": canteenId,
          "date": date.millisecondsSinceEpoch,
          "mealId": meal.id,
          "note": note,
        });
      }
    }
  }
}

/// Key used to uniquely identify a meal in the database.
class _MealKey {
  /// Id of the canteen.
  final int canteenId;

  /// Date of the meal plan.
  final int date;

  /// Id of the meal.
  final int mealId;

  /// Create key.
  _MealKey({
    @required this.canteenId,
    @required this.date,
    @required this.mealId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _MealKey && runtimeType == other.runtimeType && canteenId == other.canteenId && date == other.date && mealId == other.mealId;

  @override
  int get hashCode => canteenId.hashCode ^ date.hashCode ^ mealId.hashCode;
}
