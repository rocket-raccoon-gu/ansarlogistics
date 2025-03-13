import 'dart:developer';

import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
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
  @override
  Widget build(BuildContext context) {
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
          BottomNavigationBarItem(
            activeIcon: ImageIcon(
              const AssetImage("assets/order_active.png"),
              color: HexColor("#B7D635"),
            ),
            icon: ImageIcon(
              const AssetImage("assets/order_active.png"),
              color: HexColor('#8E8E8E'),
            ),
            label: DriverTexts.bottomBarItem1,
          ),
          BottomNavigationBarItem(
            activeIcon: ImageIcon(
              AssetImage("assets/report_new_active.png"),
              color: HexColor("#B7D635"),
            ),
            icon: ImageIcon(
              AssetImage("assets/report_new_active.png"),
              color: HexColor('#8E8E8E'),
            ),
            label: DriverTexts.bottomBarItem2,
          ),
          BottomNavigationBarItem(
            activeIcon: ImageIcon(
              AssetImage("assets/products_inactive.png"),
              color: HexColor("#B7D635"),
            ),
            icon: ImageIcon(
              AssetImage("assets/products_inactive.png"),
              color: HexColor('#8E8E8E'),
            ),
            label: DriverTexts.bottomBarItem3,
          ),
          BottomNavigationBarItem(
            activeIcon: ImageIcon(
              AssetImage("assets/profile_inactive.png"),
              color: HexColor("#B7D635"),
            ),
            icon: ImageIcon(
              AssetImage("assets/profile_inactive.png"),
              color: HexColor('#8E8E8E'),
            ),
            label: DriverTexts.bottomBarItem4,
          ),
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
}
