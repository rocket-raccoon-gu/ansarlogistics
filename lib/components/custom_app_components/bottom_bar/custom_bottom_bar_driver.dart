import 'dart:developer';

import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomBottomBarDriver extends StatefulWidget {
  final int selectedIndex;
  final BuildContext context;
  final Function(int) onTap;
  const CustomBottomBarDriver({
    super.key,
    this.selectedIndex = 0,
    required this.context,
    required this.onTap,
  });

  @override
  State<CustomBottomBarDriver> createState() => _CustomBottomBarDriverState();
}

class _CustomBottomBarDriverState extends State<CustomBottomBarDriver> {
  late List<String> translatedLabels;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    translatedLabels = List.filled(4, ''); // Initialize with empty strings
    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    final labelsToTranslate = [
      DriverTexts.bottomBarItem1,
      DriverTexts.bottomBarItem2,
      DriverTexts.bottomBarItem3,
      DriverTexts.bottomBarItem4,
    ];

    for (int i = 0; i < labelsToTranslate.length; i++) {
      translatedLabels[i] = await _translateLabel(labelsToTranslate[i]);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<String> _translateLabel(String text) async {
    try {
      final langval =
          await PreferenceUtils.getDataFromShared('language') ?? 'en';
      final targetLang = langval == 'en' ? 'en' : 'ar';
      final translated = await translator.translate(text, to: targetLang);
      return translated.toString();
    } catch (e) {
      // debugPrint("Translation error: $e");
      return text; // Return original if translation fails
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox.shrink(); // Or a loading indicator
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 1, color: customColors().backgroundTertiary),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: customColors().backgroundPrimary,
        elevation: 0,
        unselectedFontSize: 10,
        selectedFontSize: 10,
        enableFeedback: true,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          _buildNavItem("assets/order_active.png", translatedLabels[0]),
          _buildNavItem("assets/report_new_active.png", translatedLabels[1]),
          _buildNavItem("assets/products_inactive.png", translatedLabels[2]),
          _buildNavItem("assets/profile_inactive.png", translatedLabels[3]),
        ],
        currentIndex: widget.selectedIndex,
        iconSize: 24,
        onTap: widget.onTap,
        selectedItemColor: customColors().primary,
        unselectedItemColor: customColors().fontSecondary,
        unselectedLabelStyle: customTextStyle(
          fontStyle: FontStyle.BodyM_Bold,
          color: FontColor.FontSecondary,
        ),
        selectedLabelStyle: customTextStyle(
          fontStyle: FontStyle.BodyM_Bold,
          color: FontColor.FontSecondary,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(String assetPath, String label) {
    return BottomNavigationBarItem(
      activeIcon: ImageIcon(AssetImage(assetPath), color: HexColor("#B7D635")),
      icon: ImageIcon(AssetImage(assetPath), color: HexColor('#8E8E8E')),
      label: label,
    );
  }
}
