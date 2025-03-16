import 'package:ansarlogistics/Picker/presentation_layer/bloc_navigation/navigation_cubit.dart'
    show NavigationCubit;
import 'package:ansarlogistics/app_routes_factory.dart' show AppRoutesFactory;
import 'package:ansarlogistics/app_theme.dart';
import 'package:ansarlogistics/navigations/navigation.dart'
    show onGenerateAppRoute;
import 'package:ansarlogistics/services/service_locator.dart';
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
import 'package:toastification/toastification.dart';

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

class _PDAppState extends State<PDApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();

  CustomMode themeMode = CustomMode.Light;

  @override
  void initState() {
    if (applyTheme) SystemChrome.setSystemUIOverlayStyle(lightTheme);
    getUserCredentials();
    getTheme();
    // TODO: implement initState
    super.initState();
    NetworkStatusService();
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
    await Provider.of<CustomTheme>(
      context,
      listen: false,
    ).toggleTheme(themeMode);
  }

  getUserCredentials() async {
    String? userCode = await PreferenceUtils.getDataFromShared("userCode");
    if (userCode != null && userCode != "") {
      String? userData = await PreferenceUtils.getDataFromShared(userCode);
      UserSettings.userSettings.fromJsonString(userData!);
      UserController().userName = UserSettings().userPersonalSettings.username;
      UserController.userController.userName = userCode;
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
              navigatorKey: _navigatorKey,
              initialRoute: widget.initialRoute,
              onGenerateRoute: onGenerateAppRoute(
                AppRoutesFactory(widget.serviceLocator),
              ),
              debugShowCheckedModeBanner: kDebugMode,
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
