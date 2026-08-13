import 'dart:developer';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class LocationTaskHandler extends TaskHandler {
  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    log("Foreground Service Stopped");
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    log("Foreground Service tick ${DateTime.now()}");
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    log("Foreground Service Started");
  }
}
