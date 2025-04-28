import 'dart:convert';
import 'dart:developer';

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

  Order? orderItemsResponse;

  String? token;

  double? specialPrice;
  DateTime? specialFromDate;
  DateTime? specialToDate;

  updatedata(String sku, bool produce) async {
    if (sku.startsWith(']C1')) {
      log('contains c1');
      sku = sku.replaceAll(']C1', '');
    } else if (sku.startsWith('C1')) {
      sku = sku.replaceAll('C1', '');
    }

    token = await PreferenceUtils.getDataFromShared("usertoken");

    orderItemsResponse = data['order'];

    if (sku != "") {
      updateBarcodeLog('', sku);

      if (produce) {
        // Replace the last 4 digits with '0'
        String updatedBarcode = sku.substring(0, sku.length - 6) + '000000';

        log(updatedBarcode);

        getProduct(updatedBarcode);
      } else {
        getProduct(sku);
      }
    } else {
      emit(ItemAddPageInitialState(erPdata, productDBdata));

      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(errorMessage: "Please Scan Barcode ...!"),
      );
    }
  }

  updateBarcodeLog(String sku, String scannedsku) async {
    try {
      final response = await serviceLocator.tradingApi.updateBarcodeLog(
        orderid: orderItemsResponse!.subgroupIdentifier,
        sku: sku,
        scanned_sku: scannedsku,
        user_id: UserController().profile.id,
      );

      if (response.statusCode == 200) {
        log("Barcode Log Data Updated");
      }
    } catch (e) {
      log("Barcode Log Update Failed ${e.toString()}");
    }
  }

  getProduct(String sku) async {
    try {
      log(sku);

      log("scanned barcode.............");

      final productresponse = await serviceLocator.tradingApi
          .checkBarcodeDBService(endpoint: sku.toString());

      if (productresponse.statusCode == 200) {
        Map<String, dynamic> item = json.decode(productresponse.body);

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

    emit(ItemAddPageInitialState(erPdata, productDBdata));
  }

  updateItem(
    int qty,
    BuildContext ctxt,
    String price,
    String promo_price,
    String regularprice,
    String scannedsku1,
    String itemname,
  ) async {
    try {
      Map<String, dynamic> body = {
        "item_status": "new",
        "item_id": "0",
        "order_id": orderItemsResponse!.subgroupIdentifier,
        "productSku": scannedsku1,
        "productQty": qty,
        "picker_id": UserController.userController.profile.id,
        "shipping": 0,
        "item_name": itemname,
        "price": price,
        "promo_price": promo_price,
        "regular_price": regularprice,
      };

      log(body.toString());

      final response = await serviceLocator.tradingApi.updateItemStatusService(
        body: body,
        token: token,
      );

      if (response.statusCode == 200) {
        showSnackBar(
          context: context,
          snackBar: showSuccessDialogue(message: "status updted"),
        );

        eventBus.fire(DataChangedEvent("New Data from Screen B"));

        UserController.userController.alloworderupdated = true;

        // BlocProvider.of<PickerOrdersCubit>(ctxt).loadPosts(0, "");

        Navigator.of(context).popUntil((route) => route.isFirst);

        // context.gNavigationService.openPickerWorkspacePage(context);

        context.gNavigationService.openPickerOrderInnerPage(
          context,
          arg: {'orderitem': orderItemsResponse},
        );
      } else {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: 'Something went wrong try again....!',
          ),
        );
      }

      emit(ItemAddPageInitialState(erPdata, productDBdata));

      // emit(ItemAddPageErrorState(false, erPdata, productDBdata));
    } catch (e) {
      showSnackBar(
        context: context,
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

  getScannedProductData(String barcodeString, bool produce) async {
    // if (!isClosed) {
    //   emit(ItemLoading());
    // }

    if (produce) {
      // Replace the last 4 digits with '0'

      String updatedBarcode =
          '${barcodeString.substring(0, barcodeString.length - 6)}000000';

      log(updatedBarcode);

      getProduct(updatedBarcode);
    } else {
      getProduct(barcodeString);
    }
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
