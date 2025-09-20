import 'dart:async';
import 'dart:developer';
import 'package:ansarlogistics/app.dart';
import 'package:ansarlogistics/common_features/force_update_screen.dart';
import 'package:ansarlogistics/common_features/update_checker.dart';
import 'package:ansarlogistics/components/restart_widget.dart';
import 'package:ansarlogistics/firebase_configs/init_notification.dart';
import 'package:ansarlogistics/services/crash_analytics.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/custom_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

//################## DEVELOPMENT ###########################
// const baseUrl = String.fromEnvironment(
//   'BASE_URL',
//   defaultValue: "https://admin-qatar.testuatah.com",
// );
// const applicationPath = String.fromEnvironment(
//   'APPLICATION_PATH',
//   defaultValue: "/custom-api/api/qatar/",
// );
//################## DEVELOPMENT NEW ###########################

const baseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: "https://pickerdriver.testuatah.com",
);

const productUrl = String.fromEnvironment(
  'PRODUCT_URL',
  defaultValue: "https://www.ansargallery.com/rest/V1/",
);

const applicationPath = String.fromEnvironment(
  'APPLICATION_PATH',
  defaultValue: "/v1/api/qatar/",
);

// ################## DEVELOPMENT NEW ###########################

const environment = String.fromEnvironment('FLAVOR', defaultValue: 'staging');
const debuggable = bool.fromEnvironment('DEBUGGABLE', defaultValue: true);
const loggable = bool.fromEnvironment('LOGGABLE', defaultValue: true);

bool unsolicitedResponse = false;

Future<void> main() async {
  runZonedGuarded<void>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // First check if update is required

      // Continue with your existing initialization
      if (Firebase.apps.isEmpty) {
        await initializeFirebase();
      }

      // Initialize notifications plugin
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      await flutterLocalNotificationsPlugin.initialize(
        InitializationSettings(android: initializationSettingsAndroid),
      );

      // Create notification channel
      await createNotificationChannel();

      // Initialize Firebase messaging
      await initializeFirebasenotification();

      final needsUpdate = await UpdateChecker.isUpdateRequired();
      if (needsUpdate) {
        runApp(const MaterialApp(home: ForceUpdateScreen()));
        return; // Exit early if update is needed
      }

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      const initialRoute = String.fromEnvironment(
        'INITIAL_ROUTE',
        defaultValue: '/selectregionspageroutename',
      );

      if (!kIsWeb) {
        enableCrashlytics();
      }

      // Initialize service locator
      final locator = ServiceLocator(
        baseUrl,
        applicationPath,
        debuggable: loggable,
      )..config();

      // Run the app
      runApp(
        OverlaySupport.global(
          child: RestartWidget(
            child: ChangeNotifierProvider<CustomTheme>(
              create:
                  (BuildContext context) =>
                      CustomTheme(themeMode: CustomMode.Light),
              child: PDApp(serviceLocator: locator, initialRoute: initialRoute),
            ),
          ),
        ),
      );
    },
    (error, stackTrace) {
      if (kReleaseMode) {
        firebaseLog(
          msg: "ROOT : " + error.toString(),
          trace: StackTrace.current.toString(),
        );
      } else {
        log('TradingAppError', error: error, stackTrace: stackTrace);
        if (error.toString().contains("unsolicited response without request")) {
          unsolicitedResponse = true;
        }
      }
    },
  );
}
