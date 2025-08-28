import 'package:ansarlogistics/themes/custom_theme.dart';
import 'package:ansarlogistics/themes/model_themes.dart';
import 'package:flutter/painting.dart';

enum FontColor {
  White,
  FontPrimary,
  FontSecondary,
  FontTertiary,
  Primary,
  Accent,
  Success,
  Danger,
  Warning,
  Info,
  Purple,
  Ultraviolet,
  DodgerBlue,
  Dividentcolor,
  Crisps,
  SecretGarden,
  CarnationRed,
  IslandAqua,
  PacificBlue,
  SilverDust,
  wTokenFontColor,
  MattPurple,
}

enum FontStyle {
  HeaderL_Bold,
  HeaderL_SemiBold,
  HeaderL_Regular,
  HeaderM_Bold,
  HeaderM_SemiBold,
  HeaderM_Regular,
  HeaderS_Bold,
  HeaderS_SemiBold,
  HeaderS_Regular,
  HeaderXS_Bold,
  HeaderXS_SemiBold,
  HeaderXS_Regular,
  BodyL_Bold,
  BodyL_SemiBold,
  BodyL_SemiBold_lato,
  BodyL_Regular,
  BodyM_Bold,
  BodyM_SemiBold,
  BodyM_Regular,
  BodyS_Bold,
  BodyS_SemiBold,
  BodyS_Regular,
  TagNameL_Bold,
  TagNameL_SemiBold,
  TagNameS_Bold,
  TagNameS_SemiBold,
  BodyL_ItalicBold,
  Inter_Light,
  Inter_Medium,
  Lato_Bold,
  Inter_SemiBold,
}

ModelTheme customColors() {
  return CustomTheme.modelTheme;
}

TextStyle customTextStyle({required FontStyle fontStyle, FontColor? color}) {
  switch (fontStyle) {
    case FontStyle.HeaderL_Bold:
      return TextStyle(
        fontSize: 34,
        color: getFontColor(color),
        fontFamily: "OpenSansBold",
        letterSpacing: 0.5,
        fontWeight: FontWeight.w700,
      );
    case FontStyle.HeaderL_SemiBold:
      return TextStyle(
        fontSize: 34,
        color: getFontColor(color),
        letterSpacing: 0.5,
        fontFamily: "OpenSansSemiBold",
        fontWeight: FontWeight.w600,
      );
    case FontStyle.HeaderL_Regular:
      return TextStyle(
        fontSize: 34,
        color: getFontColor(color),
        letterSpacing: 0.5,
        fontFamily: "OpenSansRegular",
        fontWeight: FontWeight.w400,
      );
    case FontStyle.HeaderM_Bold:
      return TextStyle(
        fontSize: 24,
        color: getFontColor(color),
        letterSpacing: 0.5,
        fontFamily: "OpenSansBold",
        fontWeight: FontWeight.w700,
      );
    case FontStyle.HeaderM_SemiBold:
      return TextStyle(
        fontSize: 24,
        color: getFontColor(color),
        letterSpacing: 0.5,
        fontFamily: "OpenSansSemiBold",
        fontWeight: FontWeight.w600,
      );
    case FontStyle.HeaderM_Regular:
      return TextStyle(
        fontSize: 24,
        color: getFontColor(color),
        letterSpacing: 0.5,
        fontFamily: "OpenSansRegular",
        fontWeight: FontWeight.w400,
      );
    case FontStyle.HeaderS_Bold:
      return TextStyle(
        fontSize: 20,
        color: getFontColor(color),
        letterSpacing: 0.5,
        fontFamily: "OpenSansBold",
        fontWeight: FontWeight.w700,
      );
    case FontStyle.HeaderS_SemiBold:
      return TextStyle(
        fontSize: 20,
        color: getFontColor(color),
        letterSpacing: 0.5,
        fontFamily: "OpenSansSemiBold",
        fontWeight: FontWeight.w600,
      );
    case FontStyle.HeaderS_Regular:
      return TextStyle(
        fontSize: 20,
        color: getFontColor(color),
        letterSpacing: 0.5,
        fontFamily: "OpenSansRegular",
        fontWeight: FontWeight.w400,
      );
    case FontStyle.HeaderXS_Bold:
      return TextStyle(
        fontSize: 16,
        color: getFontColor(color),
        letterSpacing: 0.5,
        fontFamily: "OpenSansBold",
        fontWeight: FontWeight.w700,
      );
    case FontStyle.HeaderXS_SemiBold:
      return TextStyle(
        fontSize: 16,
        color: getFontColor(color),
        letterSpacing: 0.5,
        fontFamily: "OpenSansSemiBold",
        fontWeight: FontWeight.w600,
      );
    case FontStyle.HeaderXS_Regular:
      return TextStyle(
        fontSize: 16,
        color: getFontColor(color),
        letterSpacing: 0.5,
        fontFamily: "OpenSansRegular",
        fontWeight: FontWeight.w400,
      );
    case FontStyle.BodyL_Bold:
      return TextStyle(
        fontSize: 14,
        color: getFontColor(color),
        letterSpacing: 0.3,
        fontFamily: "OpenSansBold",
        fontWeight: FontWeight.w700,
      );
    case FontStyle.BodyL_SemiBold:
      return TextStyle(
        fontSize: 14,
        color: getFontColor(color),
        letterSpacing: 0.3,
        fontFamily: "OpenSansSemiBold",
        fontWeight: FontWeight.w600,
      );
    case FontStyle.BodyL_SemiBold_lato:
      return TextStyle(
        fontSize: 18,
        color: getFontColor(color),
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
        fontFamily: "Lato-Bold",
      );
    case FontStyle.BodyL_Regular:
      return TextStyle(
        fontSize: 14,
        color: getFontColor(color),
        letterSpacing: 0.3,
        fontFamily: "OpenSansRegular",
        fontWeight: FontWeight.w400,
      );
    case FontStyle.BodyM_Bold:
      return TextStyle(
        fontSize: 12,
        color: getFontColor(color),
        letterSpacing: 0.3,
        fontFamily: "OpenSansBold",
        fontWeight: FontWeight.w700,
      );
    case FontStyle.BodyM_SemiBold:
      return TextStyle(
        fontSize: 12,
        color: getFontColor(color),
        letterSpacing: 0.3,
        fontFamily: "OpenSansSemiBold",
        fontWeight: FontWeight.w600,
      );
    case FontStyle.BodyM_Regular:
      return TextStyle(
        fontSize: 12,
        color: getFontColor(color),
        letterSpacing: 0.3,
        fontFamily: "OpenSansRegular",
        fontWeight: FontWeight.w400,
      );
    case FontStyle.BodyS_Bold:
      return TextStyle(
        fontSize: 10,
        color: getFontColor(color),
        letterSpacing: 0.3,
        fontFamily: "OpenSansBold",
        fontWeight: FontWeight.w700,
      );
    case FontStyle.BodyS_SemiBold:
      return TextStyle(
        fontSize: 10,
        color: getFontColor(color),
        letterSpacing: 0.3,
        fontFamily: "OpenSansSemiBold",
        fontWeight: FontWeight.w600,
      );
    case FontStyle.BodyS_Regular:
      return TextStyle(
        fontSize: 10,
        color: getFontColor(color),
        letterSpacing: 0.3,
        fontFamily: "OpenSansRegular",
        fontWeight: FontWeight.w400,
      );
    case FontStyle.TagNameL_Bold:
      return TextStyle(
        fontSize: 10,
        color: getFontColor(color),
        letterSpacing: 0.2,
        fontFamily: "OpenSansBold",
        fontWeight: FontWeight.w700,
      );
    case FontStyle.TagNameL_SemiBold:
      return TextStyle(
        fontSize: 10,
        color: getFontColor(color),
        letterSpacing: 0.2,
        fontFamily: "OpenSansSemiBold",
        fontWeight: FontWeight.w600,
      );
    case FontStyle.TagNameS_Bold:
      return TextStyle(
        fontSize: 9,
        color: getFontColor(color),
        letterSpacing: 0.2,
        fontFamily: "OpenSansBold",
        fontWeight: FontWeight.w700,
      );
    case FontStyle.TagNameS_SemiBold:
      return TextStyle(
        fontSize: 9,
        color: getFontColor(color),
        letterSpacing: 0.2,
        fontFamily: "OpenSansSemiBold",
        fontWeight: FontWeight.w600,
      );
    case FontStyle.BodyL_ItalicBold:
      return TextStyle(
        fontSize: 14,
        color: getFontColor(color),
        letterSpacing: 0.3,
        fontFamily: "OpenSansItalicBold",
        fontWeight: FontWeight.w700,
      );
    case FontStyle.Inter_Light:
      return TextStyle(
        fontSize: 14,
        color: getFontColor(color),
        letterSpacing: 0.2,
        fontFamily: "Inter-Light",
        fontWeight: FontWeight.w400,
      );
    case FontStyle.Inter_Medium:
      return TextStyle(
        fontSize: 14,
        color: getFontColor(color),
        letterSpacing: 0.55,
        fontFamily: "Inter-Medium",
        fontWeight: FontWeight.w500,
      );
    case FontStyle.Lato_Bold:
      return TextStyle(
        fontSize: 17,
        color: getFontColor(color),
        letterSpacing: 0.2,
        fontFamily: "Lato-Bold",
        fontWeight: FontWeight.w600,
      );
    case FontStyle.Inter_SemiBold:
      return TextStyle(
        fontSize: 18,
        color: getFontColor(color),
        letterSpacing: 0.2,
        fontFamily: "Inter-SemiBold",
        fontWeight: FontWeight.w700,
      );
  }
}

getFontColor(FontColor? color) {
  switch (color) {
    case FontColor.White:
      return white;
    case FontColor.FontPrimary:
      return CustomTheme.modelTheme.fontPrimary;
    case FontColor.FontSecondary:
      return CustomTheme.modelTheme.fontSecondary;
    case FontColor.FontTertiary:
      return CustomTheme.modelTheme.fontTertiary;
    case FontColor.Primary:
      return CustomTheme.modelTheme.primary;
    case FontColor.Accent:
      return CustomTheme.modelTheme.accent;
    case FontColor.Success:
      return CustomTheme.modelTheme.success;
    case FontColor.Danger:
      return CustomTheme.modelTheme.danger;
    case FontColor.Warning:
      return CustomTheme.modelTheme.warning;
    case FontColor.Info:
      return CustomTheme.modelTheme.info;
    case FontColor.Purple:
      return CustomTheme.modelTheme.mattPurple;
    case FontColor.Ultraviolet:
      return CustomTheme.modelTheme.ultraviolet;
    case FontColor.DodgerBlue:
      return CustomTheme.modelTheme.dodgerBlue;
    case FontColor.Dividentcolor:
      return CustomTheme.modelTheme.dividentColor;
    case FontColor.Crisps:
      return CustomTheme.modelTheme.crisps;
    case FontColor.SecretGarden:
      return CustomTheme.modelTheme.secretGarden;
    case FontColor.CarnationRed:
      return CustomTheme.modelTheme.carnationRed;
    case FontColor.IslandAqua:
      return CustomTheme.modelTheme.islandAqua;
    case FontColor.PacificBlue:
      return CustomTheme.modelTheme.pacificBlue;
    case FontColor.SilverDust:
      return CustomTheme.modelTheme.silverDust;
    case FontColor.MattPurple:
      return CustomTheme.modelTheme.mattPurple;
    case FontColor.wTokenFontColor:
      return CustomTheme.modelTheme.pTokenBackground;
    default:
      return CustomTheme.modelTheme.fontSecondary;
  }
}

const Color white = Color(0xFFFFFFFF);
const Color peachBackground = Color(0xFFFFE6BF);

const Color peachText = Color(0xFF806130);
const Color black = Color(0xFF000000);
const Color lightBlue = Color(0xFF14ABD1);

const Color transparent = Color(0x00FFFFFF);
const Color green1000 = Color(0xFF014642);
const Color green900 = Color(0xFF02514C);
const Color green800 = Color(0xFF036252);
const Color green700 = Color(0xFF057A5B);
const Color green600 = Color(0xFF08925F);
const Color green500 = Color(0xFF0BAA60);
const Color green400 = Color(0xFF3CCC7B);
const Color green300 = Color(0xFF64E58F);
const Color green200 = Color(0xFF9AF6AF);
const Color green100 = Color(0xFFCBFAD2);

const Color red1000 = Color(0xFF530921);
const Color red900 = Color(0xFF760E30);
const Color red800 = Color(0xFF8E1734);
const Color red700 = Color(0xFFB1253B);
const Color red600 = Color(0xFFD33641);
const Color red500 = Color(0xFFF64E4B);
const Color red400 = Color(0xFFF98477);
const Color red300 = Color(0xFFFCA693);
const Color red200 = Color(0xFFFECAB7);
const Color red100 = Color(0xFFFEE7DB);

const Color yellow1000 = Color(0xFF52360A);
const Color yellow900 = Color(0xFF6E4A12);
const Color yellow800 = Color(0xFF855F1E);
const Color yellow700 = Color(0xFFA67E30);
const Color yellow600 = Color(0xFFC69E46);
const Color yellow500 = Color(0xFFE7C160);
const Color yellow400 = Color(0xFFF0D587);
const Color yellow300 = Color(0xFFF7E4A0);
const Color yellow200 = Color(0xFFFCF1C1);
const Color yellow100 = Color(0xFFFDF8E0);

const Color blue1000 = Color(0xFF041552);
const Color blue900 = Color(0xFF0B2174);
const Color blue800 = Color(0xFF12308C);
const Color blue700 = Color(0xFF1D46AE);
const Color blue600 = Color(0xFF2B5FD0);
const Color blue500 = Color(0xFF3B7CF3);
const Color blue400 = Color(0xFF6BA1F7);
const Color blue300 = Color(0xFF89B9FB);
const Color blue200 = Color(0xFFB0D4FD);
const Color blue100 = Color(0xFFD7EBFE);
const Color blue50 = Color(0xFF14ABD1);

const Color semanticRed = Color(0xFFF98477);
