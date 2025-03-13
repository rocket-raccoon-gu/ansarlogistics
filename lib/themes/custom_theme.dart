import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/model_themes.dart';
import 'package:ansarlogistics/themes/themes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CustomMode { Light, Dark, Mid }

String getThemeModeString(CustomMode mode) {
  switch (mode) {
    case CustomMode.Dark:
      return "Dark";
    case CustomMode.Mid:
      return "Mid";
    case CustomMode.Light:
      return "Light";
    default:
      return "Light";
  }
}

CustomMode getThemeMode(String mode) {
  switch (mode) {
    case "Dark":
      return CustomMode.Dark;
    case "Mid":
      return CustomMode.Mid;
    case "Light":
      return CustomMode.Light;
    default:
      return CustomMode.Light;
  }
}

SystemUiOverlayStyle lightTheme = SystemUiOverlayStyle.light.copyWith(
  systemNavigationBarColor: lightModel.backgroundPrimary,
  systemNavigationBarDividerColor: lightModel.backgroundPrimary,
  statusBarColor: HexColor('#F9FBFF'),
  statusBarBrightness: Brightness.dark,
  statusBarIconBrightness: Brightness.dark,
  systemNavigationBarIconBrightness: Brightness.dark,
  systemNavigationBarContrastEnforced: true,
  systemStatusBarContrastEnforced: true,
);

SystemUiOverlayStyle darkTheme = SystemUiOverlayStyle.dark.copyWith(
  systemNavigationBarColor: darkModel.backgroundPrimary,
  systemNavigationBarDividerColor: darkModel.backgroundPrimary,
  statusBarColor: HexColor('#F8F8F8'),
  statusBarBrightness: Brightness.dark,
  statusBarIconBrightness: Brightness.light,
  systemNavigationBarIconBrightness: Brightness.light,
  systemNavigationBarContrastEnforced: true,
  systemStatusBarContrastEnforced: true,
);

SystemUiOverlayStyle midTheme = SystemUiOverlayStyle.dark.copyWith(
  systemNavigationBarColor: midModel.backgroundPrimary,
  systemNavigationBarDividerColor: midModel.backgroundPrimary,
  statusBarColor: HexColor('#F8F8F8'),
  statusBarBrightness: Brightness.dark,
  statusBarIconBrightness: Brightness.light,
  systemNavigationBarIconBrightness: Brightness.light,
  systemNavigationBarContrastEnforced: true,
  systemStatusBarContrastEnforced: true,
);

class CustomTheme extends ChangeNotifier {
  CustomMode themeMode = CustomMode.Dark;
  ThemeData currentTheme = light();
  static ModelTheme modelTheme = lightModel;

  CustomTheme({required this.themeMode}) {
    toggleTheme(themeMode);
  }

  toggleTheme(CustomMode themeType) {
    switch (themeType) {
      case CustomMode.Dark:
        {
          currentTheme = dark();
          themeType = themeType;
          modelTheme = darkModel;
          return notifyListeners();
        }
      case CustomMode.Light:
        {
          currentTheme = light();
          themeType = themeType;
          modelTheme = lightModel;
          return notifyListeners();
        }
      case CustomMode.Mid:
        {
          currentTheme = mid();
          themeType = themeType;
          modelTheme = midModel;
          return notifyListeners();
        }
      default:
        {
          currentTheme = light();
          themeType = CustomMode.Light;
          modelTheme = lightModel;
          return notifyListeners();
        }
    }
  }
}
