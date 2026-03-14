import 'package:ansarlogistics/components/restart_widget.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

logout(BuildContext context) async {
  debugPrint('Logout function called');
  try {
    // Store user role before clearing UserController
    debugPrint('Storing user role...');
    final int userRole = UserController.userController.profile.role;
    debugPrint('User role: $userRole');

    // Clear UserController data first
    debugPrint('Clearing UserController data...');
    UserController.userController.translationCache.clear();
    UserController.userController.dispose();
    debugPrint('UserController cleared');

    // 1. Get the SharedPreferences instance
    debugPrint('Getting SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();

    // 2. Save the updates_history value
    debugPrint('Saving updates_history...');
    final String? updatesHistory = prefs.getString('updates_history');

    // 3. Clear all keys except updates_history
    debugPrint('Clearing SharedPreferences...');
    final keys = prefs.getKeys();
    for (String key in keys) {
      if (key != 'updates_history') {
        await prefs.remove(key);
      }
    }
    debugPrint('SharedPreferences cleared');

    // Additional clear for role "1" users (using stored role)
    if (userRole == 1) {
      debugPrint('Clearing PreferenceUtils for role 1 user...');
      await PreferenceUtils.clear();
      debugPrint('PreferenceUtils cleared');
    }

    // Restart app last - try multiple approaches
    debugPrint('Starting app restart...');
    _restartApp(context);
  } catch (e) {
    debugPrint('Logout error: $e');
    // Still try to restart even if there's an error
    _restartApp(context);
  }
}

void _restartApp(BuildContext context) {
  debugPrint('Attempting to restart app...');
  try {
    // Method 1: Try direct RestartWidget
    debugPrint('Trying RestartWidget.restartApp(context)');
    // RestartWidget.restartApp(context);
    Navigator.of(context).pushNamedAndRemoveUntil('/splash', (route) => false);
    debugPrint('RestartWidget.restartApp(context) succeeded');
  } catch (e) {
    debugPrint('RestartWidget failed: $e');
    try {
      // Method 2: Navigate to splash screen
      debugPrint('Trying navigation to splash');
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/splash', (route) => false);
      debugPrint('Navigation to splash succeeded');
    } catch (e2) {
      debugPrint('Navigation failed: $e2');
      // Method 3: Last resort - try to find RestartWidget through navigator key
      try {
        debugPrint('Trying navigator context approach');
        final navigatorContext = Navigator.of(context).context;
        RestartWidget.restartApp(navigatorContext);
        debugPrint('Navigator context approach succeeded');
      } catch (e3) {
        debugPrint('All restart methods failed: $e3');
        // Method 4: Final fallback - try to use root navigator
        try {
          debugPrint('Trying root navigator');
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamedAndRemoveUntil('/splash', (route) => false);
          debugPrint('Root navigator succeeded');
        } catch (e4) {
          debugPrint('Even root navigator failed: $e4');
        }
      }
    }
  }
}
