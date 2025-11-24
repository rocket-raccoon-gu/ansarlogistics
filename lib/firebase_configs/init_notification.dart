// Improved init_notification.dart
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final FirebaseMessaging messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    await _setupNotificationChannels();
    await _requestPermissions();
    await _getFCMToken();
    await _setupMessageHandlers();
  }

  static Future<void> _setupNotificationChannels() async {
    // For Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        _onNotificationTap(response.payload);
      },
    );

    // Create notification channel for Android 8.0+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'ansar_logistics_channel', // ID must match your FCM payload
      'Important Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alert'),
      enableVibration: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  static Future<void> _requestPermissions() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // For iOS/macOS specific settings
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display heads up notifications
      badge: true,
      sound: true,
    );
  }

  static Future<void> _getFCMToken() async {
    try {
      String? token = await messaging.getToken();
      print('FCM Token: $token');

      // Save token to shared preferences for later use
      // await PreferenceUtils.storeDataToShared("fcm_token", token ?? "");

      // Listen for token refresh
      messaging.onTokenRefresh.listen((newToken) {
        print('FCM Token refreshed: $newToken');
        // Update token on your server
        // await updateTokenOnServer(newToken);
      });
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  static Future<void> _setupMessageHandlers() async {
    // Handle messages when the app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received: ${message.messageId}');
      _showLocalNotification(message);
    });

    // Handle messages when the app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Background message opened: ${message.messageId}');
      _handleMessageNavigation(message);
    });

    // Handle background messages (app terminated)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Check if app was opened from terminated state via notification
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageNavigation(initialMessage);
    }
  }

  // Background message handler - must be top-level or static
  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    print('Handling a background message: ${message.messageId}');

    // Initialize Firebase if needed
    await Firebase.initializeApp();

    // Show notification
    await _showBackgroundNotification(message);
  }

  static Future<void> _showBackgroundNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'ansar_logistics_channel',
          'Important Notifications',
          channelDescription: 'Important notifications channel',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('alert'),
          enableVibration: true,
          // vibrationPattern: Int64List.fromList([0, 1000, 5000, 2000]),
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? 'New message',
      platformChannelSpecifics,
      payload: json.encode(message.data),
    );
  }

  static void _showLocalNotification(RemoteMessage message) {
    if (message.notification == null) return;

    // Show system notification
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'ansar_logistics_channel',
          'Important Notifications',
          channelDescription: 'Important notifications channel',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('alert'),
          enableVibration: true,
          // vibrationPattern: Int64List.fromList([0, 1000, 5000, 2000]),
          styleInformation: BigTextStyleInformation(''),
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? 'New message',
      platformChannelSpecifics,
      payload: json.encode(message.data),
    );
  }

  static void _onNotificationTap(String? payload) {
    if (payload != null) {
      try {
        Map<String, dynamic> data = json.decode(payload);
        _handleMessageData(data);
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  static void _handleMessageNavigation(RemoteMessage message) {
    _handleMessageData(message.data);
  }

  static void _handleMessageData(Map<String, dynamic> data) {
    // Handle navigation based on message data
    print('Notification data: $data');

    // Example: Navigate to specific screen based on data
    // if (data['type'] == 'order') {
    //   Navigator.push(context, MaterialPageRoute(builder: (_) => OrderScreen()));
    // }
  }
}
