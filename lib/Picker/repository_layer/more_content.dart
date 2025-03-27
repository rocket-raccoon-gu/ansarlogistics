import 'package:ansarlogistics/components/restart_widget.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:flutter/widgets.dart';

logout(BuildContext context) async {
  RestartWidget.restartApp(context);

  await PreferenceUtils.clear();

  UserController().dispose();
}
