import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ansarlogistics/Picker/presentation_layer/bloc_navigation/navigation_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

logout(BuildContext context) async {
  debugPrint('Logout function called');
  try {
    // Reset navigation index to 0 before logout
    try {
      BlocProvider.of<NavigationCubit>(context).resetToIndexZero();
      debugPrint('Navigation index reset to 0');
    } catch (e) {
      debugPrint('Failed to reset navigation: $e');
    }

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
  debugPrint('Clearing all routes and navigating to splash...');
  try {
    // Clear all routes and navigate to splash
    Navigator.of(context).pushNamedAndRemoveUntil('/splash', (route) => false);
    debugPrint('Successfully navigated to splash');
  } catch (e) {
    debugPrint('Navigation to splash failed: $e');
    // Fallback: try root navigator
    try {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamedAndRemoveUntil('/splash', (route) => false);
      debugPrint('Root navigator to splash succeeded');
    } catch (e2) {
      debugPrint('Root navigator also failed: $e2');
    }
  }
}
