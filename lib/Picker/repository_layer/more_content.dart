import 'package:ansarlogistics/components/restart_widget.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

logout(BuildContext context) async {
  // 1. Get the SharedPreferences instance
  final prefs = await SharedPreferences.getInstance();

  // 2. Save the updates_history value
  final String? updatesHistory = prefs.getString('updates_history');

  // 3. Clear all keys except updates_history
  final keys = prefs.getKeys();
  for (String key in keys) {
    if (key != 'updates_history') {
      await prefs.remove(key);
    }
  }

  if (UserController.userController.profile.role == "1") {
    await PreferenceUtils.clear();
  }

  RestartWidget.restartApp(context);

  UserController().translationCache.clear();
  UserController().dispose();
}
