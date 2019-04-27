import 'dart:async';

import 'package:guide7/model/meal_plan/canteen.dart';
import 'package:guide7/model/meal_plan/meal_plan_info.dart';
import 'package:guide7/storage/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage storing the meal plan info.
class MealPlanInfoStorage implements Storage<MealPlanInfo> {
  /// Base key in the shared preferences.
  static const String _baseKey = "meal_plan_info";

  /// Key of the key-value pair of a price category.
  static const String _priceCategoryKey = "price_category";

  /// Key of the key-value pair of a canteen.
  static const String _canteenKey = "canteen";

  /// Key of the key-value pair of a canteens id.
  static const String _canteenIdKey = "id";

  /// Key of the key-value pair of a canteens name.
  static const String _canteenNameKey = "name";

  /// Instance of the singleton.
  static const MealPlanInfoStorage _instance = MealPlanInfoStorage._internal();

  /// Factory constructor for the singleton.
  factory MealPlanInfoStorage() => _instance;

  /// Internal constructor.
  const MealPlanInfoStorage._internal();

  @override
  Future<void> clear() async {
    SharedPreferences prefs = await _getPrefs();

    for (final key in prefs.getKeys().where((key) => key.startsWith(_baseKey)).toList(growable: false)) {
      await prefs.remove(key);
    }
  }

  @override
  Future<bool> isEmpty() async {
    SharedPreferences prefs = await _getPrefs();

    return prefs.getKeys().where((key) => key.contains(_baseKey)).isEmpty;
  }

  @override
  Future<MealPlanInfo> read() async {
    SharedPreferences prefs = await _getPrefs();

    int canteenId = prefs.getInt("$_baseKey.$_canteenKey.$_canteenIdKey");
    String canteenName = prefs.getString("$_baseKey.$_canteenKey.$_canteenNameKey");

    int priceCategory = prefs.getInt("$_baseKey.$_priceCategoryKey");

    return MealPlanInfo(
      canteen: Canteen(
        id: canteenId,
        name: canteenName,
      ),
      priceCategory: priceCategory,
    );
  }

  @override
  Future<void> write(MealPlanInfo data) async {
    SharedPreferences prefs = await _getPrefs();

    await prefs.setInt("$_baseKey.$_canteenKey.$_canteenIdKey", data.canteen.id);
    await prefs.setString("$_baseKey.$_canteenKey.$_canteenNameKey", data.canteen.name);

    await prefs.setInt("$_baseKey.$_priceCategoryKey", data.priceCategory);
  }

  /// Get shared preferences.
  Future<SharedPreferences> _getPrefs() async => await SharedPreferences.getInstance();
}
