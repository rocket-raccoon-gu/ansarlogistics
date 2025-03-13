import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';

ThemeData light() {
  const backgroundPrimary = Color(0xFFFFFFFF);
  const backgroundSecondary = Color(0xFFF5F8FA);
  const backgroundTertiary = Color(0xFFE8EBED);

  const fontPrimary = Color(0xFF292C33);
  const fontSecondary = Color(0xFF6B7483);
  const fontTertiary = Color(0xFFA1A7B0);

  const primary = Color(0xFF07877B);
  const accent = Color(0xFFFFC160);

  const success = Color(0xFF0BAA60);
  const danger = Color(0xFFF64E4B);
  const warning = Color(0xFFE7C160);
  const info = Color(0xFF3B7CF3);

  const green1 = Color(0xFF00674B);
  const green2 = Color(0xFF367C2B);
  const green3 = Color(0xFF88A762);

  const red1 = Color(0xFFA42525);
  const red2 = Color(0xFFDC2626);
  const red3 = Color(0xFFF85F5F);

  const adBackground = Color(0xFFFFF3DF);

  const mattPurple = Color(0xFFB68DEC);
  const ultraviolet = Color(0xFFBF3ECF);
  const dodgerBlue = Color(0xFF3B7CF3);
  const crisps = Color(0xFFE7A640);
  const secretGarden = Color(0xFF0BAA60);
  const carnationRed = Color(0xFFF64E4B);
  const islandAqua = Color(0xFF2DB9B9);
  const pacificBlue = Color(0xFF0395BE);
  const silverDust = Color(0xFFBEC3CA);
  const borderLine = Color(0xFFE3E6E8);
  const wTokenBackground = Color(0xFFFFDAA0);
  const wTokenFont = Color(0xFFB38743);

  final light = ThemeData.light().copyWith(
    brightness: Brightness.light,
    primaryColor: backgroundPrimary,
    hintColor: fontTertiary,
    cardColor: backgroundSecondary,
    hoverColor: fontTertiary,
    focusColor: transparent,
    canvasColor: backgroundPrimary,
    dividerColor: backgroundTertiary,
    indicatorColor: backgroundTertiary,
    disabledColor: fontTertiary,
  );

  return light;
}

ThemeData mid() {
  const backgroundPrimary = Color(0xFF262A33);
  const backgroundSecondary = Color(0xFF323742);
  const backgroundTertiary = Color(0xFF404754);
  const fontPrimary = Color(0xFFF1F1F1);
  const fontSecondary = Color(0xFFB3B6BD);
  const fontTertiary = Color(0xFF8B9099);
  const primary = Color(0xFF399F95);
  const accent = Color(0xFFFFCD80);
  const success = Color(0xFF3CCC7B);
  const danger = Color(0xFFF98477);
  const warning = Color(0xFFF0D587);
  const info = Color(0xFF6BA1F7);
  const green1 = Color(0xFF28A376);
  const green2 = Color(0xFF6CB059);
  const green3 = Color(0xFFB0CA8B);
  const red1 = Color(0xFFC85E54);
  const red2 = Color(0xFFEA6558);
  const red3 = Color(0xFFFA9086);
  const mattPurple = Color(0xFFB68DEC);
  const ultraviolet = Color(0xFFDE6BE2);
  const dodgerBlue = Color(0xFF6BA1F7);
  const crisps = Color(0xFFF0C26E);
  const secretGarden = Color(0xFF3CCC7B);
  const carnationRed = Color(0xFFF98477);
  const islandAqua = Color(0xFF5CD5CA);
  const pacificBlue = Color(0xFF38C0D8);
  const silverDust = Color(0xFFD5D9DF);
  const borderLine = Color(0xFF404754);
  const wTokenBackground = Color(0xFFFFDAA0);
  const wTokenFont = Color(0xFFB38743);
  const adBackground = Color(0xFF804f00);

  ThemeData mid = ThemeData.dark().copyWith(
    brightness: Brightness.dark,
    primaryColor: backgroundPrimary,
    hintColor: fontTertiary,
    cardColor: backgroundSecondary,
    hoverColor: fontTertiary,
    focusColor: transparent,
    canvasColor: backgroundPrimary,
    dividerColor: backgroundTertiary,
    indicatorColor: backgroundTertiary,
    disabledColor: fontTertiary,
    scaffoldBackgroundColor: backgroundPrimary,
    dialogBackgroundColor: backgroundPrimary,
    secondaryHeaderColor: backgroundPrimary,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: fontPrimary,
      selectionColor: primary.withOpacity(0.15),
      selectionHandleColor: primary,
    ),
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: backgroundPrimary,
      onPrimary: fontPrimary,
      secondary: backgroundSecondary,
      onSecondary: fontSecondary,
      error: danger,
      onError: danger,
      background: backgroundPrimary,
      onBackground: fontPrimary,
      surface: backgroundSecondary,
      onSurface: fontSecondary,
    ),
  );

  return mid;
}

ThemeData dark() {
  const backgroundPrimary = Color(0xFF0E0F12);
  const backgroundSecondary = Color(0xFF1D1E24);
  const backgroundTertiary = Color(0xFF31353E);
  const fontPrimary = Color(0xFFF1F1F1);
  const fontSecondary = Color(0xFF9EA4AF);
  const fontTertiary = Color(0xFF5B616B);
  const primary = Color(0xFF399F95);
  const accent = Color(0xFFFFCD80);
  const success = Color(0xFF3CCC7B);
  const danger = Color(0xFFF98477);
  const warning = Color(0xFFF0D587);
  const info = Color(0xFF6BA1F7);
  const green1 = Color(0xFF28A376);
  const green2 = Color(0xFF6CB059);
  const green3 = Color(0xFFB0CA8B);
  const red1 = Color(0xFFC85E54);
  const red2 = Color(0xFFEA6558);
  const red3 = Color(0xFFFA9086);
  const mattPurple = Color(0xFFB68DEC);
  const ultraviolet = Color(0xFFDE6BE2);
  const dodgerBlue = Color(0xFF6BA1F7);
  const crisps = Color(0xFFF0C26E);
  const secretGarden = Color(0xFF3CCC7B);
  const carnationRed = Color(0xFFF98477);
  const islandAqua = Color(0xFF5CD5CA);
  const pacificBlue = Color(0xFF38C0D8);
  const silverDust = Color(0xFFD5D9DF);
  const borderLine = Color(0xFF262B33);
  const wTokenBackground = Color(0xFFFFDAA0);
  const wTokenFont = Color(0xFFB38743);
  const adBackground = Color(0xFF804f00);

  ThemeData dark = ThemeData.dark().copyWith(
    brightness: Brightness.dark,
    primaryColor: backgroundPrimary,
    hintColor: fontTertiary,
    cardColor: backgroundSecondary,
    hoverColor: fontTertiary,
    focusColor: transparent,
    canvasColor: backgroundPrimary,
    dividerColor: backgroundTertiary,
    indicatorColor: backgroundTertiary,
    disabledColor: fontTertiary,
    scaffoldBackgroundColor: backgroundPrimary,
    dialogBackgroundColor: backgroundPrimary,
    secondaryHeaderColor: backgroundPrimary,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: fontPrimary,
      selectionColor: primary.withOpacity(0.15),
      selectionHandleColor: primary,
    ),
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: backgroundPrimary,
      onPrimary: fontPrimary,
      secondary: backgroundSecondary,
      onSecondary: fontSecondary,
      error: danger,
      onError: danger,
      background: backgroundPrimary,
      onBackground: fontPrimary,
      surface: backgroundSecondary,
      onSurface: fontSecondary,
    ),
  );
  return dark;
}
