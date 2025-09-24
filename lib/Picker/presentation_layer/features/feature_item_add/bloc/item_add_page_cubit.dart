// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';

import 'package:ansarlogistics/Picker/presentation_layer/features/feature_item_add/bloc/item_add_page_state.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/notifier.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/erp_data_response.dart';
import 'package:picker_driver_api/responses/order_response.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';
import 'package:picker_driver_api/responses/product_bd_data_response.dart';
import 'package:picker_driver_api/responses/product_response.dart';
import 'package:toastification/toastification.dart';

class ItemAddPageCubit extends Cubit<ItemAddPageState> {
  final ServiceLocator serviceLocator;
  BuildContext context;
  Map<String, dynamic> data;

  ItemAddPageCubit({
    required this.serviceLocator,
    required this.context,
    required this.data,
  }) : super(ItemAddPageStateLoading()) {
    updateFormState();
  }

  ErPdata? erPdata;

  ProductDBdata? productDBdata;

  OrderNew? orderItemsResponse;

  String? token;

  double? specialPrice;
  DateTime? specialFromDate;
  DateTime? specialToDate;

  // updatedata(String sku, bool produce) async {
  //   if (sku.startsWith(']C1')) {
  //     log('contains c1');
  //     sku = sku.replaceAll(']C1', '');
  //   } else if (sku.startsWith('C1')) {
  //     sku = sku.replaceAll('C1', '');
  //   }

  //   token = await PreferenceUtils.getDataFromShared("usertoken");

  //   orderItemsResponse = data['order'];

  //   if (sku != "") {
  //     updateBarcodeLog('', sku);

  //     if (produce) {
  //       // Replace the last 4 digits with '0'
  //       String updatedBarcode = sku.substring(0, sku.length - 6) + '000000';

  //       log(updatedBarcode);

  //       getProduct(updatedBarcode);
  //     } else {
  //       getProduct(sku);
  //     }
  //   } else {
  //     emit(ItemAddPageInitialState(erPdata, productDBdata));

  //     showSnackBar(
  //       context: context,
  //       snackBar: showErrorDialogue(errorMessage: "Please Scan Barcode ...!"),
  //     );
  //   }
  // }

  updateBarcodeLog(String sku, String scannedsku) async {
    try {
      final response = await serviceLocator.tradingApi.updateBarcodeLog(
        orderid: orderItemsResponse!.subgroupIdentifier,
        sku: sku,
        scanned_sku: scannedsku,
        user_id: UserController().profile.id.toString(),
      );

      if (response.statusCode == 200) {
        log("Barcode Log Data Updated");
      }
    } catch (e) {
      log("Barcode Log Update Failed ${e.toString()}");
    }
  }

  getProduct(String sku, String productSku, String action) async {
    try {
      final productresponse = await serviceLocator.tradingApi
          .checkBarcodeDBService(
            endpoint: sku,
            productSku: productSku,
            action: action,
            token1: UserController.userController.app_token,
          );

      if (productresponse.statusCode == 200) {
        Map<String, dynamic> item = json.decode(productresponse.body);

        item['scanned_sku'] = sku;

        if (item['priority'] == 1) {
          erPdata = ErPdata.fromJson(item);
        } else if (item['priority'] == 2) {
          productDBdata = ProductDBdata.fromJson(item);
        } else if (item.containsKey('suggestion')) {
          showSnackBar(
            context: context,
            snackBar: showErrorDialogue(errorMessage: "Product Not Found ...!"),
          );
        }
      } else {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(errorMessage: "Product Not Found ...!"),
        );
      }

      if (!isClosed) {
        emit(ItemAddPageInitialState(erPdata, productDBdata));
      }
    } catch (e) {
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "Something Went Wrong try again...!",
        ),
      );
    }
  }

  String getPriceFromBarcode(String code) {
    String last = code;
    String price = "00";

    // Check if code starts with '00'
    if (code.startsWith('00')) {
      last = code.substring(2);
    }

    // Convert to price value (divide by 1000)
    double parsedValue = double.parse(last) / 1000;

    // Format the price string
    String priceString = parsedValue.toString();
    int dotIndex = priceString.indexOf('.');

    if (dotIndex != -1 && dotIndex < priceString.length - 2) {
      // Decimal part is not zero - include up to two decimal places
      price = priceString.substring(0, dotIndex + 3);
    } else {
      // Decimal part is zero
      price = priceString;
    }

    return price;
  }

  String getLastSixDigits(String barcode) {
    if (barcode.length <= 6) {
      return barcode; // Return as-is if 6 or fewer characters
    }
    return barcode.substring(barcode.length - 6);
  }

  updateItem(
    int itemId,
    String scannedSku,
    String reason,
    String price,
    String qty,
    String preparationId,
    int isProduce,
    int productId,
    String productName,
    String orderNumber,
    BuildContext ctxt,
  ) async {
    try {
      // print("🛠️ Preparing body for updateItem...");
      // Map<String, dynamic> body = {
      //   "item_id": itemId,
      //   "order_number": orderNumber,
      //   // "scanned_sku": scannedSku,
      //   "status": "new",
      //   "price": double.parse(price),
      //   // Normalize qty: if produce, treat large values as grams and convert to kg, round to 3 decimals; else 2 decimals
      //   "qty":
      //       (() {
      //         final normalized = qty.replaceAll(',', '.');
      //         double raw = double.tryParse(normalized) ?? 0.0;
      //         if (isProduce == true) {
      //           double kg = raw >= 10 ? (raw / 1000.0) : raw;
      //           return double.parse(kg.toStringAsFixed(3));
      //         } else {
      //           return double.parse(raw.toStringAsFixed(2));
      //         }
      //       })(),
      //   "preparation_id": preparationId,
      //   "reason": reason,
      //   "is_produce": isProduce,
      //   "productId": productId,
      //   "name": productName,
      // };

      Map<String, dynamic> body = {
        'item_id': itemId,
        'order_number': orderNumber,
        'scanned_sku': scannedSku,
        'status': "new",
        'price': double.parse(price),
        'qty':
            (() {
              final normalized = qty.replaceAll(',', '.');
              double raw = double.tryParse(normalized) ?? 0.0;
              if (isProduce == true) {
                double kg = raw >= 10 ? (raw / 1000.0) : raw;
                return double.parse(kg.toStringAsFixed(3));
              } else {
                return double.parse(raw.toStringAsFixed(2));
              }
            })(),
        'preparation_id': preparationId,
        'is_produce': isProduce,
        'productId': productId,
        'name': productName,
        'reason': reason,
      };

      log("📦 Request Body: $body");
      // print("🔎 body body: ${body}");

      // print("📡 Calling updateItemStatusService API...");
      final response = await serviceLocator.tradingApi.updateItemStatusService(
        body: body,
        token: token,
      );
      // print("✅ API Response received");

      // print("🔎 Status Code: ${response.statusCode}");
      // print("🧾 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        // print("🎉 Status update successful");
        showSnackBar(
          context: ctxt,
          snackBar: showSuccessDialogue(
            message: "status updted new additional item",
          ),
        );

        //   eventBus.fire(
        //   DataChangedEvent(
        //     "New Data from Screen B",
        //   ).updatePriceData(orderItemsResponse!.subgroupIdentifier, price),
        // );

        String newProducrPrice = getPriceFromBarcode(
          getLastSixDigits(scannedSku),
        );

        // print("📢 Firing DataChangedEvent");
        // print("🧾 producebarcode Body: ${producebarcode}");

        // if (isProduce == "1") {
        //   eventBus.fire(
        //     DataChangedEvent("New Data from Screen B").updatePriceData(
        //       orderItemsResponse!.subgroupIdentifier,
        //       newProducrPrice,
        //     ),
        //   );
        // } else {
        //   String finalPrice = price * qty;
        //   eventBus.fire(
        //     DataChangedEvent("New Data from Screen B").updatePriceData(
        //       orderItemsResponse!.subgroupIdentifier,
        //       finalPrice,
        //     ),
        //   );
        // }

        // print("✅ Setting alloworderupdated to true");
        UserController.userController.alloworderupdated = true;

        // print("🔙 Navigating back to first route");
        Navigator.of(ctxt).popUntil((route) => route.isFirst);

        // print("➡️ Opening PickerOrderInnerPage...");
        context.gNavigationService.openPickerWorkspacePage(context);
      } else {
        // print("❌ API call failed with status code: ${response.statusCode}");
        showSnackBar(
          context: ctxt,
          snackBar: showErrorDialogue(
            errorMessage: 'Something went wrong try again....!',
          ),
        );
      }

      // print("🔄 Emitting ItemAddPageInitialState...");
      emit(ItemAddPageInitialState(erPdata, productDBdata));
    } catch (e) {
      // print("🔥 Exception caught in updateItem: $e");
      showSnackBar(
        context: ctxt,
        snackBar: showErrorDialogue(errorMessage: e.toString()),
      );
      emit(ItemAddPageInitialState(erPdata, productDBdata));
    }
  }

  bool get isSpecialPriceActive {
    final now = DateTime.now();

    // Ensure specialFromDate and specialToDate are non-null
    if (specialFromDate != null && specialToDate != null) {
      // Strip time portion by comparing year, month, and day
      final isSameDayAsFromDate =
          now.year == specialFromDate!.year &&
          now.month == specialFromDate!.month &&
          now.day == specialFromDate!.day;

      final isSameDayAsToDate =
          now.year == specialToDate!.year &&
          now.month == specialToDate!.month &&
          now.day == specialToDate!.day;

      // Check if now is within range or same day
      return (now.isAfter(specialFromDate!) && now.isBefore(specialToDate!)) ||
          isSameDayAsFromDate ||
          isSameDayAsToDate;
    }

    return false; // If either of the dates is null, return false
  }

  double get displayPrice {
    return isSpecialPriceActive && specialPrice != null ? specialPrice! : 0.00;
  }

  getScannedProductData(
    String barcodeString,
    bool produce,
    String productSku,
    String action,
  ) async {
    getProduct(barcodeString, productSku, action);
  }

  updateFormState() async {
    token = await PreferenceUtils.getDataFromShared("usertoken");

    orderItemsResponse = data['order'];

    emit(ItemAddFormState());
  }

  updateScannerState() {
    emit(MobileScannerState1());
  }
}
