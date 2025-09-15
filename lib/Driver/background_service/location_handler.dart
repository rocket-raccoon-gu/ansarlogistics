import 'dart:developer';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class LocationTaskHandler extends TaskHandler {
  @override
  Future<void> onDestroy(DateTime timestamp) {
    log("Foreground Service Stopped");
    return Future.value(true);
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // TODO: implement onRepeatEvent
    log("Forgroud Service Started ${DateTime.now()}");
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) {
    // TODO: implement onStart
    log("Forgroud Service Started");

    return Future.value(true);
  }
}
