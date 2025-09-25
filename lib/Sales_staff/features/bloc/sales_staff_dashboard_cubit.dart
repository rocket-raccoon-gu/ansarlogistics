import 'dart:convert';
import 'dart:developer';

import 'package:ansarlogistics/Sales_staff/components/get_promotion_status.dart';
import 'package:ansarlogistics/Sales_staff/features/bloc/sales_staff_dashboard_state.dart';
import 'package:ansarlogistics/main.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
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

  String? selectedRegion;

  updateData() async {
    selectedRegion = await PreferenceUtils.getDataFromShared("selected_region");

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
        // Emit not-found state so UI can reflect the result
        emit(SalesStaffBarcodeCheckNotFound(scannedSku: barcodescanRes));
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
                        data['items'][0]['erp_product_name'],
                        textAlign: TextAlign.center,
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyM_Bold,
                          color: FontColor.FontPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        barcodescanRes,
                        textAlign: TextAlign.center,
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyM_Bold,
                          color: FontColor.FontPrimary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Standard Price : ${double.parse(data['items'][0]['erp_price']).toStringAsFixed(2)} ${getcurrencyfromurl(baseUrl)}",
                        textAlign: TextAlign.center,
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyM_Bold,
                          color: FontColor.FontPrimary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child:
                          data['items'][0]['discount_perc'] != null &&
                                  data['items'][0]['discount_perc'] != ""
                              ? Text(
                                "Discount Percentage : ${double.parse(data['items'][0]['discount_perc']).toStringAsFixed(2)} %",
                                textAlign: TextAlign.center,
                                style: customTextStyle(
                                  fontStyle: FontStyle.BodyM_Bold,
                                  color: FontColor.FontPrimary,
                                ),
                              )
                              : Text(
                                "Discount Percentage :  %",
                                textAlign: TextAlign.center,
                                style: customTextStyle(
                                  fontStyle: FontStyle.BodyM_Bold,
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
                              fontStyle: FontStyle.BodyM_Bold,
                              color: FontColor.FontPrimary,
                            ),
                          ),
                          data['items'][0]['offer_price'] != null &&
                                  data['items'][0]['offer_price'] != ""
                              ? Text(
                                "${double.parse(data['items'][0]['offer_price']).toStringAsFixed(2)} ${getcurrencyfromurl(baseUrl)}",
                                style: customTextStyle(
                                  fontStyle: FontStyle.BodyM_Bold,
                                  color: FontColor.CarnationRed,
                                ),
                              )
                              : Text(
                                "",
                                style: customTextStyle(
                                  fontStyle: FontStyle.BodyM_Bold,
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
        // Emit success state so UI can autofill fields
        final String? discountPerc =
            data['items'][0]['discount_perc']?.toString();
        emit(
          SalesStaffBarcodeCheckSuccess(
            erpSku: barcodescanRes,
            discountPerc:
                (discountPerc != null && discountPerc.isNotEmpty)
                    ? discountPerc
                    : null,
          ),
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

  checkBarcodeDataUae(String barcodescanRes, String username) async {
    try {
      String branch = '';

      if (username == 'ahuae_sales') {
        branch = 'AM';
      } else {
        branch = 'DXB';
      }

      String response = await serviceLocator.tradingApi
          .generalPromotionServiceUae(endpoint: barcodescanRes, branch: branch);

      log(response);

      Map<String, dynamic> data = jsonDecode(response);

      Navigator.pop(context);

      log(data.toString());

      if (data['items'] ==
              'No records found for the given barcode and branch' ||
          data['items'].isEmpty) {
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
        // Emit not-found state so UI can reflect the result
        emit(SalesStaffBarcodeCheckNotFound(scannedSku: barcodescanRes));
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
                        data['items'][0]['product_name'],
                        textAlign: TextAlign.center,
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyM_Bold,
                          color: FontColor.FontPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        barcodescanRes,
                        textAlign: TextAlign.center,
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyM_Bold,
                          color: FontColor.FontPrimary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Standard Price : ${double.parse(data['items'][0]['retail_price']).toStringAsFixed(2)} AED",
                        textAlign: TextAlign.center,
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyM_Bold,
                          color: FontColor.FontPrimary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child:
                          data['items'][0]['discount_perc'] != null &&
                                  data['items'][0]['discount_perc'] != ""
                              ? Text(
                                "Discount Percentage : ${double.parse(data['items'][0]['discount_perc']).toStringAsFixed(2)} %",
                                textAlign: TextAlign.center,
                                style: customTextStyle(
                                  fontStyle: FontStyle.BodyM_Bold,
                                  color: FontColor.FontPrimary,
                                ),
                              )
                              : Text(
                                "Discount Percentage :  %",
                                textAlign: TextAlign.center,
                                style: customTextStyle(
                                  fontStyle: FontStyle.BodyM_Bold,
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
                              fontStyle: FontStyle.BodyM_Bold,
                              color: FontColor.FontPrimary,
                            ),
                          ),
                          data['items'][0]['offer_price'] != null &&
                                  data['items'][0]['offer_price'] != ""
                              ? Text(
                                "${double.parse(data['items'][0]['offer_price']).toStringAsFixed(2)} AED",
                                style: customTextStyle(
                                  fontStyle: FontStyle.BodyM_Bold,
                                  color: FontColor.CarnationRed,
                                ),
                              )
                              : Text(
                                "",
                                style: customTextStyle(
                                  fontStyle: FontStyle.BodyM_Bold,
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
        // Emit success state so UI can autofill fields
        final String? discountPerc =
            data['items'][0]['discount_perc']?.toString();
        emit(
          SalesStaffBarcodeCheckSuccess(
            erpSku: barcodescanRes,
            discountPerc:
                (discountPerc != null && discountPerc.isNotEmpty)
                    ? discountPerc
                    : null,
          ),
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

  Future<void> addProductToBarcodeDB({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await serviceLocator.tradingApi.updateBarcodeData(
        body: body,
      );

      // Try to parse status and message
      final statusCode = response.statusCode;
      String message = "";
      try {
        final data = jsonDecode(response.body);
        message = data['message']?.toString() ?? '';
      } catch (_) {}

      if (statusCode == 200) {
        showSnackBar(
          context: context,
          snackBar: showSuccessDialogue(
            message:
                message.isNotEmpty ? message : "Product updated successfully",
          ),
        );
      } else {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage:
                message.isNotEmpty
                    ? message
                    : "Failed to update product. (${statusCode})",
          ),
        );
      }
    } catch (e) {
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(errorMessage: "Error: ${e.toString()}"),
      );
      rethrow;
    }
  }
}
