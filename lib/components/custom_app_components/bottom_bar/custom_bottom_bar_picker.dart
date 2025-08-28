import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigationBarPicker extends StatefulWidget {
  final int selectedIndex;
  final BuildContext context;
  final Function(int) onTap;
  CustomBottomNavigationBarPicker({
    this.selectedIndex = 0,
    required this.context,
    required this.onTap,
  });

  @override
  State<CustomBottomNavigationBarPicker> createState() =>
      _CustomBottomNavigationBarPickerState();
}

class _CustomBottomNavigationBarPickerState
    extends State<CustomBottomNavigationBarPicker> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(width: 1, color: customColors().backgroundTertiary),
        ),
        color: customColors().backgroundPrimary,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: BottomNavigationBar(
            backgroundColor: customColors().backgroundPrimary,
            elevation: 0,
            unselectedFontSize: 12,
            selectedFontSize: 12,
            enableFeedback: true,
            type: BottomNavigationBarType.fixed,
            selectedIconTheme: IconThemeData(
              color: customColors().dodgerBlue,
              size: 26,
            ),
            unselectedIconTheme: IconThemeData(
              color: customColors().fontSecondary,
              size: 24,
            ),
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                activeIcon: ImageIcon(
                  const AssetImage("assets/order_active.png"),
                  color: customColors().dodgerBlue,
                ),
                icon: ImageIcon(
                  const AssetImage("assets/order_active.png"),
                  color: customColors().fontSecondary,
                ),
                label: PickerTexts.bottomBarItem1,
              ),
              BottomNavigationBarItem(
                activeIcon: ImageIcon(
                  AssetImage("assets/report_new_active.png"),
                  color: customColors().dodgerBlue,
                ),
                icon: ImageIcon(
                  AssetImage("assets/report_new_active.png"),
                  color: customColors().fontSecondary,
                ),
                label: PickerTexts.bottomBarItem2,
              ),
              BottomNavigationBarItem(
                activeIcon: ImageIcon(
                  AssetImage("assets/products_inactive.png"),
                  color: customColors().dodgerBlue,
                ),
                icon: ImageIcon(
                  AssetImage("assets/products_inactive.png"),
                  color: customColors().fontSecondary,
                ),
                label: PickerTexts.bottomBarItem3,
              ),
              BottomNavigationBarItem(
                activeIcon: ImageIcon(
                  AssetImage("assets/profile_inactive.png"),
                  color: customColors().dodgerBlue,
                ),
                icon: ImageIcon(
                  AssetImage("assets/profile_inactive.png"),
                  color: customColors().fontSecondary,
                ),
                label: PickerTexts.bottomBarItem4,
              ),
            ],
            currentIndex: widget.selectedIndex,
            onTap: widget.onTap,
            selectedItemColor: customColors().dodgerBlue,
            unselectedItemColor: customColors().fontSecondary,
            unselectedLabelStyle: customTextStyle(
              fontStyle: FontStyle.BodyM_Bold,
              color: FontColor.FontSecondary,
            ),
            selectedLabelStyle: customTextStyle(
              fontStyle: FontStyle.BodyM_Bold,
              color: FontColor.Primary,
            ),
            showSelectedLabels: true,
            showUnselectedLabels: true,
          ),
        ),
      ),
    );
  }
}
