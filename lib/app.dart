import 'dart:developer';

import 'package:ansarlogistics/Picker/presentation_layer/bloc_navigation/navigation_cubit.dart'
    show NavigationCubit;
import 'package:ansarlogistics/app_routes_factory.dart' show AppRoutesFactory;
import 'package:ansarlogistics/app_theme.dart';
import 'package:ansarlogistics/firebase_configs/init_notification.dart'
    show navigatorKey;
import 'package:ansarlogistics/navigations/navigation.dart'
    show onGenerateAppRoute;
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/services/scandit_manager.dart';
import 'package:ansarlogistics/themes/custom_theme.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/network/network_service_status.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/user_settings.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class PDApp extends StatefulWidget {
  final String initialRoute;
  final ServiceLocator serviceLocator;
  const PDApp({
    super.key,
    required this.initialRoute,
    required this.serviceLocator,
  });

  @override
  State<PDApp> createState() => _PDAppState();
}

class _PDAppState extends State<PDApp> with WidgetsBindingObserver {
  CustomMode themeMode = CustomMode.Light;

  @override
  void initState() {
    if (applyTheme) SystemChrome.setSystemUIOverlayStyle(lightTheme);
    getUserCredentials();
    getTheme();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    NetworkStatusService();
  }

  Future<void> _initScandit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print("✅ SharedPreferences working");
    } catch (e) {
      print("❌ SharedPreferences error: $e");
    }

    try {
      await ScanditFlutterDataCaptureBarcode.initialize();
      log("✅ Scandit initialized successfully");
    } catch (e) {
      log("❌ Scandit initialization failed: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Clean up Scandit resources when app is disposed
    ScanditManager.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      // Clean up Scandit resources when app is completely closed
      ScanditManager.dispose();
    }
  }

  getTheme() async {
    bool? storedThemeStatus = await PreferenceUtils.preferenceHasKey("theme");

    if (storedThemeStatus == false) {
      await PreferenceUtils.storeDataToShared(
        "theme",
        getThemeModeString(CustomMode.Light).toString(),
      );
      ;
    } else {
      String? storedTheme = await PreferenceUtils.getDataFromShared("theme");
      if (storedTheme == "") {
        await PreferenceUtils.storeDataToShared(
          "theme",
          getThemeModeString(CustomMode.Light).toString(),
        );
      }
    }
    String? storedTheme = await PreferenceUtils.getDataFromShared("theme");
    UserController().currentTheme = storedTheme ?? "";

    themeMode = getThemeMode(storedTheme!);
    if (applyTheme) {
      switch (themeMode) {
        case CustomMode.Light:
          {
            SystemChrome.setSystemUIOverlayStyle(lightTheme);
            break;
          }
        case CustomMode.Mid:
          {
            SystemChrome.setSystemUIOverlayStyle(midTheme);
            break;
          }
        case CustomMode.Dark:
          {
            SystemChrome.setSystemUIOverlayStyle(darkTheme);
            break;
          }
      }
    }
    if (mounted) {
      await Provider.of<CustomTheme>(
        context,
        listen: false,
      ).toggleTheme(themeMode);
    }
  }

  getUserCredentials() async {
    String? userCode = await PreferenceUtils.getDataFromShared("userCode");
    if (userCode != null && userCode != "" && mounted) {
      String? userData = await PreferenceUtils.getDataFromShared(userCode);
      if (userData != null && mounted) {
        UserSettings.userSettings.fromJsonString(userData);
        UserController().userName =
            UserSettings().userPersonalSettings.username;
        UserController.userController.userName = userCode;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [RepositoryProvider.value(value: widget.serviceLocator)],
      child: AppTheme(
        child: BlocProvider(
          create: (context) => NavigationCubit(),
          child: ToastificationWrapper(
            child: MaterialApp(
              navigatorKey: navigatorKey,
              initialRoute: widget.initialRoute,
              onGenerateRoute: onGenerateAppRoute(
                AppRoutesFactory(widget.serviceLocator),
              ),
              debugShowCheckedModeBanner: kDebugMode,
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en', 'US'), Locale('ar', 'AE')],

              themeMode:
                  CustomTheme.modelTheme == CustomMode.Light
                      ? ThemeMode.light
                      : ThemeMode.dark,
              theme: Provider.of<CustomTheme>(context).currentTheme,
            ),
          ),
        ),
      ),
    );
  }
}
