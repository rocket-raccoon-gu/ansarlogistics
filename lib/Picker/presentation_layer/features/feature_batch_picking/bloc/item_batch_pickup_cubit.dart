import 'dart:convert';

import 'package:ansarlogistics/Picker/presentation_layer/features/feature_batch_picking/bloc/item_batch_pickup_state.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:picker_driver_api/responses/erp_data_response.dart';
import 'package:picker_driver_api/responses/product_bd_data_response.dart';

class ItemBatchPickupCubit extends Cubit<ItemBatchPickupState> {
  final ServiceLocator serviceLocator;
  final Map<String, dynamic> data;
  ItemBatchPickupCubit(this.serviceLocator, this.data)
    : super(ItemBatchPickupLoadingState()) {
    updatedata();
  }

  bool _isDialogShowing = false;

  void updatedata() {
    final item = data['items_data'];

    emit(ItemBatchPickupLoadedState(item: item));
  }

  checkitemdb(
    String qty,
    String scannedSku,
    String productSku,
    String action,
    BuildContext context,
  ) async {
    // print("🔍 checkitemdb() called");
    // print("📦 Qty: $qty");
    // print("🔍 Scanned SKU: $scannedSku");
    // print("🏷️ Product SKU: $productSku");
    // print("🔁 Action: $action");

    try {
      String? token = UserController.userController.app_token;

      final response = await serviceLocator.tradingApi.checkBarcodeDBService(
        endpoint: scannedSku,
        productSku: productSku,
        action: action,
        token1: token,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        if (data['priority'] == 1) {
          ErPdata erPdata = ErPdata.fromJson(data);

          // showPickConfirmBottomSheet(
          //   name: erPdata.name ?? '',
          //   sku: erPdata.sku ?? '',
          //   newPrice: erPdata.price?.toString() ?? '0',
          //   regularPrice: erPdata.regularPrice?.toString() ?? '0',
          //   onConfirm: () {
          //     // Handle confirm action
          //     Navigator.pop(context);
          //   },
          // );
        } else if (data['priority'] == 2) {
          ProductDBdata productDBdata = ProductDBdata.fromJson(data);
        } else if (data['priority'] == 0) {
          showSnackBar(
            context: context,
            snackBar: showErrorDialogue(errorMessage: "Barcode Not Matching!"),
          );
        }
      } else {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "Barcode Not Scanned Please Retry!",
          ),
        );
      }

      if (!_isDialogShowing) {
        _isDialogShowing = true;
      }
    } catch (e, stacktrace) {
      // print("🔥 Exception in checkitemdb(): ${e.toString()}");
      // print("📉 StackTrace: $stacktrace");
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "Barcode Not Scanned Please Retry!",
        ),
      );
    }
  }
}
