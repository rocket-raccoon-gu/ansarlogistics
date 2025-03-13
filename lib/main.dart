import 'dart:async';
import 'dart:developer';

import 'package:ansarlogistics/app.dart';
import 'package:ansarlogistics/components/restart_widget.dart';
import 'package:ansarlogistics/services/crash_analytics.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/custom_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

//################## DEVELOPMENT ###########################
const baseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: "https://admin-qatar.testuatah.com",
);
const applicationPath = String.fromEnvironment(
  'APPLICATION_PATH',
  defaultValue: "/custom-api/api/qatar/",
);
//################## DEVELOPMENT ###########################

const environment = String.fromEnvironment('FLAVOR', defaultValue: 'staging');
const debuggable = bool.fromEnvironment('DEBUGGABLE', defaultValue: true);
const loggable = bool.fromEnvironment('LOGGABLE', defaultValue: true);

bool unsolicitedResponse = false;

Future<void> main() async {
  runZonedGuarded<void>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await initializeFirebase(); // Initialize Firebase

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      const initialRoute = String.fromEnvironment(
        'INITIAL_ROUTE',
        defaultValue: '/login',
      );

      // if (kReleaseMode) {
      //   // Setup for release mode
      // } else if (kDebugMode) {
      //   // Disable crashlytics in debug mode
      //   disableCrashlytics();
      // }

      if (!kIsWeb) {
        // if (kDebugMode) {
        //   disableCrashlytics();
        // } else {
        enableCrashlytics();
        // }
      }

      // Initialize service locator
      final locator = ServiceLocator(
        baseUrl,
        applicationPath,
        debuggable: loggable,
      )..config();

      // Run the app
      runApp(
        RestartWidget(
          child: ChangeNotifierProvider<CustomTheme>(
            create:
                (BuildContext context) =>
                    CustomTheme(themeMode: CustomMode.Light),
            child: PDApp(serviceLocator: locator, initialRoute: initialRoute),
          ),
        ),
      );
    },
    (error, stackTrace) {
      if (kReleaseMode) {
        // Log errors to Firebase in release mode
        firebaseLog(
          msg: "ROOT : " + error.toString(),
          trace: StackTrace.current.toString(),
        );
      } else {
        // Log errors in debug mode
        log('TradingAppError', error: error, stackTrace: stackTrace);
        if (error.toString().contains("unsolicited response without request")) {
          unsolicitedResponse = true;
        }
      }
    },
  );
}
