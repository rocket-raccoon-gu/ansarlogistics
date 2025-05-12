import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:developer';
import 'dart:isolate';
import 'package:ansarlogistics/Driver/background_service/location_handler.dart';
import 'package:ansarlogistics/common_features/feature_login/bloc/login_cubit.dart';
import 'package:ansarlogistics/main.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toastification/toastification.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // Initialize foreground task
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

  // Configure the background service
  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: (service) async {
        return true; // Continue running in the background
      },
    ),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      initialNotificationContent: "Picker & Driver",
    ),
  );
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}

void _requestLocationPermission() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  // Check for location permission
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error('Location permissions are permanently denied.');
  }

  if (permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse) {
    // Start the foreground service
    await FlutterForegroundTask.startService(
      notificationTitle: 'Tracking Location',
      notificationText: 'Your location is being tracked in the background.',
      callback: startCallback,
    );
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    // Immediately set the service as a foreground service
    service.setAsForegroundService();
  }

  // Listen for stop service events
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Perform periodic tasks
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    fetchcurrentaddress();
    // log("Background service started.${DateTime.now()}");
  });

  // Notify the UI or perform background tasks
  service.invoke('update');
  log("Background service started.");
}

void fetchcurrentaddress() async {
  await Permission.location.isGranted.then((value) async {
    if (value) {
      try {
        //         // LocationData locationData = await location.getLocation();

        late OverlaySupportEntry entry; // Declare the entry variable

        //         // Initialize service locator
        final locator = ServiceLocator(
          UserController().base,
          UserController.userController.producturl,
          // UserController.userController.applicationpath,
          debuggable: loggable,
        )..config();

        // log(UserController.userController.profile.empId);

        Position? position1;

        final locationStream = Geolocator.getPositionStream(
          locationSettings: LocationSettings(
            distanceFilter: 10,
            accuracy: LocationAccuracy.high,
          ),
        ).listen((position) {
          // Handle updates here
          position1 = position;
        });

        // Position position = await Geolocator.getCurrentPosition();

        log(
          "granted ${position1!.latitude},${position1!.longitude} ...${DateTime.now()}",
        );

        await PreferenceUtils.storeDataToShared(
          "userlat",
          position1!.latitude.toString(),
        );

        await PreferenceUtils.storeDataToShared(
          "userlong",
          position1!.longitude.toString(),
        );

        UserController.userController.locationlatitude =
            position1!.latitude.toString();

        UserController.userController.locationlongitude =
            position1!.longitude.toString();

        if (await PreferenceUtils.preferenceHasKey("userCode")) {
          String id =
              UserController().userName =
                  (await PreferenceUtils.getDataFromShared("userCode")) ?? "";
          String passval =
              await PreferenceUtils.getDataFromShared("password") ?? "";

          String? val = await PreferenceUtils.getDataFromShared("userid");

          String useridsplitted = id.replaceFirst(RegExp(r'^0+'), '');
          // if (val != "" && id != "") {}

          // ignore: unnecessary_null_comparison
          if (passval == "" && id == "") {
            // show overlay notification

            if (Firebase.apps.isEmpty) {
              try {
                await Firebase.initializeApp();
                print("Firebase initialized.");

                await FirebaseMessaging.instance.getToken().then((fval) async {
                  UserController.userController.devicetoken = fval!;

                  // log(fval);
                });
              } catch (e) {
                print("Firebase initialization failed: $e");
              }
            } else {
              await FirebaseMessaging.instance.getToken().then((fval) async {
                UserController.userController.devicetoken = fval!;

                // log(fval);

                final String serverkey = await getAccessToken();

                log("token = " + serverkey.toString());

                final response = await locator.tradingApi.sendNotificationRequest(
                  bearertoken: serverkey,
                  devicetoken: fval,
                  title: "Alert Relogin Needed",
                  body:
                      "Please Relogin From Your Application For Fetch Location",
                );

                if (response.statusCode == 200) {
                  log("Notification Send");
                } else {
                  log("Notification Not Send");
                }
              });
            }

            //           // flutterLocalNotificationsPlugin.show(
            //           //     1,
            //           //     "Alert",
            //           //     "Your Location Not Getting Updated Please Login And Try Again...!",
            //           //     NotificationDetails(
            //           //         android: AndroidNotificationDetails(
            //           //             'channel_id_6', 'channelname',
            //           //             icon: '@mipmap/ic_launcher',
            //           //             importance: Importance.high,
            //           //             playSound: true,
            //           //             enableVibration: true,
            //           //             sound: const RawResourceAndroidNotificationSound('alert'),
            //           //             vibrationPattern:
            //           //                 Int64List.fromList([0, 1000, 5000, 2000]))));
          } else {
            final resp = await locator.tradingApi.updateDriverLocationdetails(
              // ignore: unnecessary_null_comparison
              userId: int.parse(val!),
              latitude: position1!.latitude.toString(),
              longitude: position1!.longitude.toString(),
            );

            if (resp.statusCode == 200) {
              PreferenceUtils.storeDataToShared(
                "driverlat",
                position1!.latitude.toString(),
              );

              PreferenceUtils.storeDataToShared(
                "driverlong",
                position1!.longitude.toString(),
              );

              log("location updated");
            } else {
              log("location not updated");
            }
          }
        }
      } catch (e) {
        log("Error getting location: $e");
      }
      //     } else {
      //       Permission.location.request();
    }

    // service.invoke('update');

    /////perform some operation on background which in noticable to the used every time
    log("background service running..");
  });
}

// Initialize the background service and foreground task
// Future<void> initializeService() async {
//   FlutterForegroundTask.init(
//     androidNotificationOptions: AndroidNotificationOptions(
//       channelId: 'location_tracking_channel',
//       channelName: 'Location Tracking',
//       channelDescription: 'Tracks your location in the background.',
//       channelImportance: NotificationChannelImportance.HIGH,
//       priority: NotificationPriority.HIGH,
//       visibility: NotificationVisibility.VISIBILITY_PUBLIC,
//     ),
//     iosNotificationOptions: const IOSNotificationOptions(
//       showNotification: true,
//       playSound: false,
//     ),
//     foregroundTaskOptions: ForegroundTaskOptions(
//       eventAction: ForegroundTaskEventAction.repeat(1),
//       autoRunOnBoot: true,
//       allowWakeLock: true,
//       allowWifiLock: true,
//     ),
//   );
// }

// // Background service start callback
// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) {
//   DartPluginRegistrant.ensureInitialized();

//   if (service is AndroidServiceInstance) {
//     service.setAsForegroundService();
//   }

//   service.on('stopService').listen((event) {
//     stopLocationStream();
//     service.stopSelf();
//   });

//   log("Background service started.");
//   startPeriodicLocationTracking();
// }

// // Stream subscription and throttling variables
// StreamSubscription<Position>? locationSubscription;
// Timer? periodicTimer;

// // Start the location tracking every 1 minute
// void startPeriodicLocationTracking() async {
//   final hasPermission = await _checkAndRequestLocationPermission();
//   if (!hasPermission) {
//     log("Location permission denied. Stopping service.");
//     FlutterForegroundTask.stopService();
//     return;
//   }

//   // Create a stream to get real-time location updates
//   locationSubscription = Geolocator.getPositionStream(
//     locationSettings: const LocationSettings(
//       accuracy: LocationAccuracy.high,
//       distanceFilter: 10, // Update only when the user moves 10 meters
//     ),
//   ).listen((position) {
//     log("Received location update: ${position.latitude}, ${position.longitude}");
//   });

//   // Periodically fetch the last known position every 1 minute
//   periodicTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
//     final position = await Geolocator.getCurrentPosition();
//     log("Fetching location every 1 minute: ${position.latitude}, ${position.longitude}");

//     String? userId = await PreferenceUtils.getDataFromShared('userid');

//     await sendLocationToServer(position, userId!);
//     // if (success) {
//     //   log("Location successfully sent to server.");
//     // } else {
//     //   log("Failed to send location to server.");
//     // }
//     // }
//   });
// }

// // Stop the location stream and timer when the service is stopped
// void stopLocationStream() {
//   locationSubscription?.cancel();
//   periodicTimer?.cancel();
//   log("Location stream and periodic timer stopped.");
// }

// // Send location to the server
// Future<bool> sendLocationToServer(Position position, String userId) async {
//   try {
//     final locator =
//         ServiceLocator(baseUrl, applicationPath, debuggable: loggable)
//           ..config();

//     log("Sending location to server: ${position.latitude}, ${position.longitude}");

//     final resp = await locator.tradingApi.updateDriverLocationdetails(
//       userId: int.parse(userId),
//       latitude: position.latitude.toString(),
//       longitude: position.longitude.toString(),
//     );

//     if (resp.statusCode == 200) {
//       PreferenceUtils.storeDataToShared(
//           "driverlat", position.latitude.toString());
//       PreferenceUtils.storeDataToShared(
//           "driverlong", position.longitude.toString());
//       log("Location updated successfully.");
//       return true;
//     } else {
//       log("Failed to update location. Server response code: ${resp.statusCode}");
//       return false;
//     }
//   } catch (e) {
//     log("Error sending location: $e");
//     return false;
//   }
// }

// // Check and request location permissions
// Future<bool> _checkAndRequestLocationPermission() async {
//   final isEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!isEnabled) {
//     log("Location services are disabled.");
//     return false;
//   }

//   var permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.denied ||
//       permission == LocationPermission.deniedForever) {
//     permission = await Geolocator.requestPermission();
//     if (permission == LocationPermission.denied ||
//         permission == LocationPermission.deniedForever) {
//       log("Location permissions are denied.");
//       return false;
//     }
//   }
//   return true;
// }

// // Start the service with foreground task
// Future<void> startLocationTracking() async {
//   await FlutterForegroundTask.startService(
//     notificationTitle: 'Tracking Location',
//     notificationText: 'Your location is being tracked.',
//     callback: onStart,
//   );
// }
