import 'dart:developer';
import 'dart:typed_data';

import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/restart_widget.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

initializeFirebasenotification() async {
  await createNotificationChannel();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen(
    (event) {
      log("notification hitted");

      showLocalNotification(event);
    },
    onDone: () {
      // FlutterAppBadger.removeBadge();
    },
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling a background message ${message.messageId}');
  log('${message.data}');

  //
  //

  flutterLocalNotificationsPlugin.show(
    message.data.hashCode,
    message.notification!.title,
    message.notification!.body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_id_5',
        'channelname',
        icon: '@mipmap/ic_launcher',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound('alert'),
        vibrationPattern: Int64List.fromList([0, 1000, 5000, 2000]),
      ),
    ),
  );
}

// Add this channel creation function (call it during app initialization)
Future<void> createNotificationChannel() async {
  // AndroidNotificationChannel channel = AndroidNotificationChannel(
  //   'channel_id_5', // Must match your channel ID
  //   'Important Notifications', // User-visible name
  //   description: 'Important notifications channel', // User-visible description
  //   importance: Importance.high,
  //   playSound: true,
  //   enableVibration: true,
  //   vibrationPattern: Int64List.fromList([0, 1000, 5000, 2000]),
  //   sound: RawResourceAndroidNotificationSound('alert'),
  //   showBadge: true, // Uncomment if you have this sound file
  // );

  // First delete existing channel to ensure fresh creation
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.deleteNotificationChannel('channel_id_5');

  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'channel_id_5',
    'Important Notifications',
    description: 'Important notifications channel',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('alert'),
    enableVibration: true,
    vibrationPattern: Int64List.fromList([0, 1000, 5000, 2000]),
    showBadge: true,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
}

// Modified showLocalNotification function
void showLocalNotification(RemoteMessage message) {
  if (message.notification == null) return;

  late OverlaySupportEntry entry;

  // Show overlay notification
  entry = showSimpleNotification(
    Text(
      message.notification!.title ?? 'Notification Title',
      style: customTextStyle(
        fontStyle: FontStyle.BodyL_Bold,
        color: FontColor.FontPrimary,
      ),
    ),
    subtitle: Builder(
      builder: (context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Image.asset('assets/notification.png', height: 80.0),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                message.notification!.body ?? 'Notification Body',
                textAlign: TextAlign.center,
                style: customTextStyle(
                  fontStyle: FontStyle.BodyL_Bold,
                  color: FontColor.FontPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: BasketButton(
                      onpress: () {
                        entry.dismiss();
                        // RestartWidget.restartApp(context);
                      },
                      text: "OK",
                      bgcolor: customColors().dodgerBlue,
                      textStyle: customTextStyle(
                        fontStyle: FontStyle.BodyL_Bold,
                        color: FontColor.White,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
    background: customColors().backgroundPrimary,
    leading: const Icon(Icons.notifications_active),
    position: NotificationPosition.bottom,
    autoDismiss: false,
  );

  // Show system notification
  flutterLocalNotificationsPlugin.show(
    message.data.hashCode,
    message.notification?.title ?? 'Notification Title',
    message.notification?.body ?? 'Notification Body',
    NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_id_5', // Must match created channel
        'Important Notifications', // Should match channel name
        channelDescription: 'Important notifications channel',
        icon: '@mipmap/ic_launcher',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound(
          'alert',
        ), // Uncomment if you have this sound file
        vibrationPattern: Int64List.fromList([0, 1000, 5000, 2000]),
      ),
    ),
  );
}
