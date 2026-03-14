import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/city.dart';

class StorageService {
  static const _lastCityKey = 'last_city';
  static const _favoritesKey = 'favorite_cities';
  static const _unitKey = 'temp_unit';

  Future<void> saveLastCity(City city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCityKey, jsonEncode(city.toJson()));
  }

  Future<City?> getLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_lastCityKey);
    if (json == null) return null;
    return City.fromJson(jsonDecode(json));
  }

  Future<List<City>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_favoritesKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => City.fromJson(e)).toList();
  }

  Future<void> saveFavorites(List<City> cities) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _favoritesKey,
      jsonEncode(cities.map((c) => c.toJson()).toList()),
    );
  }

  Future<bool> isCelsius() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_unitKey) ?? true;
  }

  Future<void> setUseCelsius(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_unitKey, value);
  }
}
