import 'dart:developer';
import 'dart:isolate';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class ForgroundTaskService {
  static init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(10),
      ),
    );
  }
}

@pragma(
  'vm:entry-point',
) // This decorator means that this function calls native code
void startCallback() {
  FlutterForegroundTask.setTaskHandler(FirstTaskHandler());
}

class FirstTaskHandler extends TaskHandler {
  SendPort? _sendPort;

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    log("Foreground Service Stopped");
    return Future.value(true);
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // TODO: implement onRepeatEvent
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) {
    // TODO: implement onStart
    throw UnimplementedError();
  }
}
