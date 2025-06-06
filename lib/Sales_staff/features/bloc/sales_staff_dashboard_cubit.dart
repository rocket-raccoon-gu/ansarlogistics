import 'dart:convert';
import 'dart:developer';

import 'package:ansarlogistics/Sales_staff/components/get_promotion_status.dart';
import 'package:ansarlogistics/Sales_staff/features/bloc/sales_staff_dashboard_state.dart';
import 'package:ansarlogistics/main.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class SalesStaffDashboardCubit extends Cubit<SalesStaffDashboardState> {
  final ServiceLocator serviceLocator;
  BuildContext context;
  SalesStaffDashboardCubit({
    required this.serviceLocator,
    required this.context,
  }) : super(SalesStaffDashboardloadingState()) {
    updateData();
  }

  updateData() {
    emit(SalesStaffDashboardInitialState());
  }

  checkBarcodeData(String barcodescanRes) async {
    try {
      String response = await serviceLocator.tradingApi.generalPromotionService(
        endpoint: barcodescanRes,
      );

      log(response);

      Map<String, dynamic> data = jsonDecode(response);

      Navigator.pop(context);

      log(data.toString());

      if (data['items'].isEmpty) {
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: "",
          pageBuilder: (context, animation, secondaryAnimation) {
            return Container();
          },
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            var curve = Curves.easeInOut.transform(animation.value);

            return Transform.scale(
              scale: curve,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.close, size: 25.0),
                        ),
                      ],
                    ),
                    Lottie.asset(
                      "assets/lottie_files/update_error.json",
                      height: 150.0,
                      width: 150.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        barcodescanRes,
                        textAlign: TextAlign.center,
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyL_Bold,
                          color: FontColor.FontPrimary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Oh No, This Item Not In The Promotion",
                        textAlign: TextAlign.center,
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyL_Bold,
                          color: FontColor.FontPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: "",
          pageBuilder: (context, animation, secondaryAnimation) {
            return Container();
          },
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            var curve = Curves.easeInOut.transform(animation.value);

            return Transform.scale(
              scale: curve,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.close, size: 25.0),
                        ),
                      ],
                    ),
                    Lottie.asset(
                      "assets/lottie_files/success_animation.json",
                      height: 150.0,
                      width: 150.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        barcodescanRes,
                        textAlign: TextAlign.center,
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyL_Bold,
                          color: FontColor.FontPrimary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Retail Price : ${double.parse(data['items'][0]['retail_price']).toStringAsFixed(2)} ${getcurrencyfromurl(baseUrl)}",
                        textAlign: TextAlign.center,
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyL_Bold,
                          color: FontColor.FontPrimary,
                        ),
                      ),
                    ),
                    SizedBox(
                      child: Center(
                        child: GetPromotionStatus(
                          promotionStatus: data['items'][0]['promotion_status'],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Discount Price : ${double.parse(data['items'][0]['discount_amount']).toStringAsFixed(2)} ${getcurrencyfromurl(baseUrl)}",
                        textAlign: TextAlign.center,
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyL_Bold,
                          color: FontColor.FontPrimary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Offer Price : ",
                            textAlign: TextAlign.center,
                            style: customTextStyle(
                              fontStyle: FontStyle.HeaderS_Bold,
                              color: FontColor.FontPrimary,
                            ),
                          ),
                          Text(
                            "${double.parse(data['items'][0]['offer_price']).toStringAsFixed(2)} ${getcurrencyfromurl(baseUrl)}",
                            style: customTextStyle(
                              fontStyle: FontStyle.HeaderS_Bold,
                              color: FontColor.CarnationRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      Navigator.pop(context);

      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "Barcode not read please check again...!",
        ),
      );
    }
  }
}
