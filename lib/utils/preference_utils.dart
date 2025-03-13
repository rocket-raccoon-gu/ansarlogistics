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
}
