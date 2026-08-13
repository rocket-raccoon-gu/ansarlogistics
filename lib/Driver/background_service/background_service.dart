import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:ansarlogistics/Driver/background_service/location_handler.dart';
import 'package:ansarlogistics/main.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Configure + start background location tracking for drivers.
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'location_tracking_channel',
      channelName: 'Location Tracking',
      channelDescription: 'Tracks your location in the background.',
      channelImportance: NotificationChannelImportance.HIGH,
      priority: NotificationPriority.HIGH,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(1),
      autoRunOnBoot: true,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: (service) async {
        return true;
      },
    ),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      autoStartOnBoot: true,
      initialNotificationContent: "Driver location tracking",
      initialNotificationTitle: "Ansar Logistics",
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
  );

  final isRunning = await service.isRunning();
  if (!isRunning) {
    await service.startService();
    log("Driver background service started.");
  } else {
    log("Driver background service already running.");
  }
}

/// Ask location permission, start background service, and push one immediate update.
Future<void> startDriverLocationTracking() async {
  try {
    final hasPermission = await _ensureLocationPermission();
    if (!hasPermission) {
      log("Driver location tracking skipped: permission not granted.");
      return;
    }

    await initializeService();

    // Immediate update right after login / dashboard open
    await updateDriverLocationFromGps();
  } catch (e, st) {
    log("startDriverLocationTracking error: $e", stackTrace: st);
  }
}

Future<bool> _ensureLocationPermission() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    log("Location services are disabled.");
    return false;
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    // Also try permission_handler for Android "always" prompt flow
    final status = await Permission.location.request();
    if (!status.isGranted) {
      await Permission.locationWhenInUse.request();
    }
    permission = await Geolocator.checkPermission();
  }

  return permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse;
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Push location immediately, then every minute
  updateDriverLocationFromGps();

  Timer.periodic(const Duration(minutes: 1), (timer) async {
    await updateDriverLocationFromGps();
  });

  service.invoke('update');
  log("Background service started.");
}

/// Fetch current GPS and PATCH driver location to API.
Future<void> updateDriverLocationFromGps() async {
  try {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      log("background service running.. (no location permission)");
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );

    final lat = position.latitude.toString();
    final lng = position.longitude.toString();

    log("granted $lat,$lng ...${DateTime.now()}");

    await PreferenceUtils.storeDataToShared("userlat", lat);
    await PreferenceUtils.storeDataToShared("userlong", lng);
    await PreferenceUtils.storeDataToShared("driverlat", lat);
    await PreferenceUtils.storeDataToShared("driverlong", lng);

    UserController.userController.locationlatitude = lat;
    UserController.userController.locationlongitude = lng;

    final userId = await PreferenceUtils.getDataFromShared("userid");
    final token = await PreferenceUtils.getDataFromShared("usertoken");

    if (userId == null ||
        userId.isEmpty ||
        token == null ||
        token.isEmpty) {
      log("background service running.. (missing userid/token)");
      return;
    }

    final baseUrl =
        (UserController.userController.base.isNotEmpty)
            ? UserController.userController.base
            : defaultBaseUrl;
    final appPath =
        (UserController.userController.applicationpath.isNotEmpty)
            ? UserController.userController.applicationpath
            : defaultApplicationPath;

    final locator = ServiceLocator(baseUrl, appPath, debuggable: loggable)
      ..config();

    final resp = await locator.tradingApi.updateDriverLocationdetails(
      userId: int.parse(userId),
      latitude: lat,
      longitude: lng,
      token: token,
    );

    if (resp.statusCode == 200) {
      log("location updated");
    } else {
      log("location not updated: ${resp.statusCode}");
    }

    log("background service running..");
  } catch (e, st) {
    log("Error getting/updating location: $e", stackTrace: st);
    log("background service running..");
  }
}

/// Kept for existing call sites that still use this name.
void fetchcurrentaddress() {
  updateDriverLocationFromGps();
}
