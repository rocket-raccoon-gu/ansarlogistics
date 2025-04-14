import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PreferenceUtils {
  static Future<bool> preferenceHasKey(String key) async {
    SharedPreferences _prefsInstance = await SharedPreferences.getInstance();
    return _prefsInstance.containsKey(key);
  }

  static storeDataToShared(String key, String data) async {
    SharedPreferences _prefsInstance = await SharedPreferences.getInstance();
    _prefsInstance.remove(key);
    _prefsInstance.setString(key, data);
  }

  static removeDataFromShared(String key) async {
    SharedPreferences _prefsInstance = await SharedPreferences.getInstance();
    _prefsInstance.remove(key);
  }

  static clear() async {
    SharedPreferences _prefsInstance = await SharedPreferences.getInstance();
    _prefsInstance.clear();
  }

  static Future<String?> getDataFromShared(String key) async {
    SharedPreferences _prefInstance = await SharedPreferences.getInstance();
    return _prefInstance.getString(key);
  }

  static Future<List<dynamic>> getstoremap(String key) async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();

    final String? list = _preferences.getString(key);

    if (list != null) {
      final List<dynamic> dataList = jsonDecode(list);
      return dataList;
    } else {
      return [];
    }
  }

  static storeListmap(String key, List<Map<String, dynamic>> listdata) async {
    SharedPreferences _prefInstance = await SharedPreferences.getInstance();

    final String encodelist = jsonEncode(listdata);

    _prefInstance.setString(key, encodelist);
  }

  Future<List<Map<String, dynamic>>> getSavedUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? updatesJsonList = prefs.getStringList('updates_list');

    if (updatesJsonList == null) return [];

    return updatesJsonList
        .map((jsonString) => jsonDecode(jsonString) as Map<String, dynamic>)
        .toList();
  }
}
