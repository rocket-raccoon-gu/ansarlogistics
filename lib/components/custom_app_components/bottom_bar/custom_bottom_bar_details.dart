import 'dart:developer';

import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/bloc/picker_order_details_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/bloc/picker_order_details_state.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomBottomBarDetails extends StatelessWidget {
  const CustomBottomBarDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PickerOrderDetailsCubit, PickerOrderDetailsState>(
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            // if (UserController.userController.alloworderupdated) {
            UserController.userController.alloworderupdated = false;
            //   context.gNavigationService.openPickerWorkspacePage(context);
            // } else {
            context.gNavigationService.back(context);
            // }

            return Future.value(true);
          },
          child: Container(
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.only(topLeft: Radius.circular(14.0)),
              border: Border(
                top: BorderSide(
                  width: 1,
                  color: customColors().backgroundTertiary,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black38,
                  spreadRadius: 0,
                  blurRadius: 10,
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex:
                  BlocProvider.of<PickerOrderDetailsCubit>(context).tabindex,
              backgroundColor: customColors().backgroundPrimary,
              elevation: 0,
              unselectedFontSize: 10,
              selectedFontSize: 10,
              enableFeedback: true,
              selectedIconTheme: IconThemeData(
                color: customColors().backgroundPrimary,
              ),
              items: [
                BottomNavigationBarItem(
                  activeIcon: ImageIcon(
                    const AssetImage("assets/topick.png"),
                    color: HexColor("#B7D635"),
                  ),
                  icon: ImageIcon(
                    AssetImage("assets/topick.png"),
                    color: HexColor('8E8E8E'),
                  ),
                  label: "To pick",
                ),
                BottomNavigationBarItem(
                  activeIcon: ImageIcon(
                    const AssetImage("assets/picked.png"),
                    color: HexColor("#B7D635"),
                  ),
                  icon: ImageIcon(
                    AssetImage("assets/picked.png"),
                    color: HexColor('8E8E8E'),
                  ),
                  label: "Picked",
                ),
                BottomNavigationBarItem(
                  activeIcon: ImageIcon(
                    const AssetImage("assets/notfound.png"),
                    color: HexColor("#B7D635"),
                  ),
                  icon: ImageIcon(
                    AssetImage("assets/notfound.png"),
                    color: HexColor('8E8E8E'),
                  ),
                  label: "Not Found",
                ),
                BottomNavigationBarItem(
                  activeIcon: Icon(
                    Icons.published_with_changes,
                    color: HexColor('#B7D635'),
                  ),
                  icon: Icon(Icons.cancel),
                  label: "Canceled",
                ),
              ],
              iconSize: 24,
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
              onTap: (value) {
                log(
                  BlocProvider.of<PickerOrderDetailsCubit>(
                    context,
                  ).tabindex.toString(),
                );

                // if (UserController.userController.alloworderupdated) {
                //   BlocProvider.of<PickerOrderDetailsCubit>(context)
                //       .getrefreshedData(
                //           BlocProvider.of<PickerOrderDetailsCubit>(context)
                //               .orderItem
                //               .subgroupIdentifier);
                // } else {
                BlocProvider.of<PickerOrderDetailsCubit>(
                  context,
                ).updateSelectedItem(value);
                // }
              },
            ),
          ),
        );
      },
    );
  }

  String getTabFilter(int index) {
    switch (index) {
      case 0:
        return 'assigned_picker';
      case 1:
        return 'end_picking';
      case 2:
        return 'item_not_available';
      case 3:
        return 'replacement';
      default:
        return 'assigned_picker';
    }
  }
}
