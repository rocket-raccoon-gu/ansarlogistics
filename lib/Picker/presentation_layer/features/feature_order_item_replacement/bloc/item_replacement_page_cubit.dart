import 'dart:convert';
import 'dart:developer';

import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_replacement/bloc/item_replacement_page_state.dart';
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
import 'package:picker_driver_api/responses/product_response.dart';
import 'package:picker_driver_api/responses/similiar_item_response.dart';
import 'package:picker_driver_api/responses/product_bd_data_response.dart';

class ItemReplacementPageCubit extends Cubit<ItemReplacementPageState> {
  ServiceLocator serviceLocator;
  BuildContext context;
  Map<String, dynamic> data;

  ItemReplacementPageCubit({
    required this.serviceLocator,
    required this.context,
    required this.data,
  }) : super(ItemReplacementLoading()) {
    updatedata();
  }

  EndPicking? itemdata;

  Order? orderItemsResponse;

  List<SimiliarItems> relatableitems = [];

  ProductResponse? prwork;

  bool loading = false;

  int prvalue = 0;

  String itemname = "";

  String scannedsku = "";

  String showsku = "";

  double? specialPrice;
  DateTime? specialFromDate;
  DateTime? specialToDate;

  ErPdata? erPdata;

  ProductDBdata? productDBdata;

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

  updatedata() async {
    itemdata = data['item'];
    orderItemsResponse = data['order'];
    if (!isClosed) {
      emit(ItemReplacementLoading());
    }

    try {
      final responce = await serviceLocator.tradingApi.getSimiliarItemsRequest(
        productid: itemdata!.productId,
      );

      if (responce.statusCode == 200) {
        log("----------------------responce succees");

        final Map<String, dynamic> respbody = jsonDecode(responce.body);

        SimilialItemsResponse similialItemsResponse =
            await SimilialItemsResponse.fromJson(respbody);

        relatableitems.addAll(similialItemsResponse.items);
      } else {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "No similar items Available..!",
          ),
        );
      }
    } catch (e) {
      log(e.toString());
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(errorMessage: "Error ${e.toString()}"),
      );
    }

    emit(
      ItemReplacementInitail(
        itemdata: itemdata,
        replacements: relatableitems,
        prwork: prwork,
        loading: false,
      ),
    );
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

  updatereplacement(
    // int selectedindex,
    // String product_name,
    // String reason,
    // int editqty,
    // BuildContext ctxt,
    // String price,
    // String promo_price,
    // String regularprice,
    // String scannedsku1,
    //=============================================================
    // int qty,
    // BuildContext ctxt,
    // String price,
    // String promo_price,
    // String regularprice,
    // String scannedsku1,
    // String itemname,
    // String scanned_sku,
    // String producebarcode,

    //---------------------------------------------------------------------
    int selectedindex,
    String product_name,
    String reason,
    int editqty,
    BuildContext ctxt,
    String price,
    String promo_price,
    String regularprice,
    String scannedsku1,
    String producebarcode,
    String isProduce,
  ) async {
    try {
      String? token = await PreferenceUtils.getDataFromShared("usertoken");

      // print('👉 isProduce: $isProduce');

      String newProducrPrice = getPriceFromBarcode(
        getLastSixDigits(producebarcode),
      );

      // ✅ Convert both quantities to int (remove decimals completely)
      int editedQty = int.tryParse(editqty.toString().split('.').first) ?? 1;
      int orderedQty =
          int.tryParse(itemdata!.qtyOrdered.toString().split('.').first) ?? 1;

      // ✅ Choose which quantity to use
      int newProductQty = editedQty != 0 ? editedQty : orderedQty;

      Map<String, dynamic> body = {
        "item_status": "replaced",
        "item_id": itemdata!.itemId,
        "canceled_sku": itemdata!.productSku,
        "new_sku": scannedsku1,
        "product_name": product_name,
        "new_product_qty": newProductQty,
        "order_id": orderItemsResponse!.subgroupIdentifier.toString(),
        "picker_id": UserController.userController.profile.id,
        "shipping": 0,
        "reason": reason,
        "price": isProduce == "1" ? newProducrPrice : price,
        "promo_price": promo_price,
        "regular_price": regularprice,
        "scanned_sku": producebarcode,
      };

      // print('📝 [DEBUG] Request body to send:');
      // body.forEach((key, value) {
      //   print('  • $key: $value');
      // });

      loading = true;

      if (loading) {
        // print("Sending updateItemStatusService request...");
        final response = await serviceLocator.tradingApi
            .updateItemStatusService(body: body, token: token);

        if (response.statusCode == 200) {
          loading = false;

          UserController.userController.notavailableindexlist.add(
            itemdata!.itemId,
          );

          showSnackBar(
            context: context,
            snackBar: showSuccessDialogue(
              message: "Status updated successfully",
            ),
          );

          // print("${newProducrPrice} newProducrPrice");

          if (isProduce == "1") {
            // print("isProduce == 1 if");

            String finalProduceQuantity =
                (editqty != 0 ? editqty : itemdata!.qtyOrdered).toString();
            String finalProducePrice = (double.parse(newProducrPrice) *
                    int.parse(finalProduceQuantity))
                .toStringAsFixed(2);

            eventBus.fire(
              DataChangedEvent("New Data from Screen B").updatePriceData(
                orderItemsResponse!.subgroupIdentifier,
                finalProducePrice,
              ),
            );

            // UserController.userController.printOrderData(); // 👈 Add this
          } else {
            String finalQuantity =
                (editqty != 0 ? editqty : itemdata!.qtyOrdered).toString();
            String finalPrice = (double.parse(price) * int.parse(finalQuantity))
                .toStringAsFixed(2);

            // print("✅ [DEBUG] finalQuantity: $finalQuantity");
            // print("✅ [DEBUG] finalPrice: $finalPrice");

            // print("isProduce == 0 else");

            eventBus.fire(
              DataChangedEvent("New Data from Screen B").updatePriceData(
                orderItemsResponse!.subgroupIdentifier,
                finalPrice,
              ),
            );
            // UserController.userController.printOrderData(); // 👈 Add this
          }

          // eventBus.fire(
          //   DataChangedEvent(
          //     "New Data from Screen B",
          //   ).updatePriceData(orderItemsResponse!.subgroupIdentifier, price),
          // );

          UserController.userController.alloworderupdated = true;

          Navigator.of(context).popUntil((route) => route.isFirst);

          context.gNavigationService.openPickerOrderInnerPage(
            context,
            arg: {'orderitem': orderItemsResponse},
          );
        } else {
          loading = false;
          // print("Update failed with status code: ${response.statusCode}");
          showSnackBar(
            context: context,
            snackBar: showErrorDialogue(
              errorMessage: "Status update failed...",
            ),
          );

          emit(
            ItemReplacementInitail(
              itemdata: itemdata,
              replacements: relatableitems,
              prwork: prwork,
              loading: false,
            ),
          );
        }
      }
    } catch (e, stacktrace) {
      loading = false;
      // print("Exception in updatereplacement: $e");
      // print(stacktrace);

      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(errorMessage: "Status update failed..."),
      );

      emit(
        ItemReplacementInitail(
          itemdata: itemdata,
          replacements: relatableitems,
          prwork: prwork,
          loading: false,
        ),
      );
    }
  }

  getScannedProductData(String barcodeString, bool produce) async {
    // print(jsonEncode("getScannedProductData"));

    getProductData(barcodeString);
  }

  getProductData(String sku) async {
    // print('📦 [DEBUG] Entered getProductData() with SKU: $sku');

    try {
      final productresponse = await serviceLocator.tradingApi
          .checkBarcodeDBService(endpoint: sku);

      // print('📡 [DEBUG] HTTP Status: ${productresponse.statusCode}');
      // print('🔍 [DEBUG] Raw response body: ${productresponse.body}');

      if (productresponse.statusCode == 200) {
        Map<String, dynamic> item = json.decode(productresponse.body);

        item['scanned_sku'] = sku;

        // print('🧩 [DEBUG] Decoded JSON: $item');

        if (item['priority'] == 1) {
          erPdata = ErPdata.fromJson(item);
          // print('✅ [DEBUG] Loaded into ErPdata model');
        } else if (item['priority'] == 2) {
          productDBdata = ProductDBdata.fromJson(item);
          // print('✅ [DEBUG] Loaded into ProductDBdata model');
        } else if (item.containsKey('suggestion')) {
          // print('⚠️ [DEBUG] Product suggestion found, showing error snackbar');
          showSnackBar(
            context: context,
            snackBar: showErrorDialogue(errorMessage: "Product Not Found ...!"),
          );
        }
      } else {
        // print('❌ [DEBUG] Non-200 response, showing error snackbar');
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(errorMessage: "Product Not Found ...!"),
        );
      }

      if (!isClosed) {
        emit(
          ItemReplacementLoaded(erPdata: erPdata, productDBdata: productDBdata),
        );
        // print('🚀 [DEBUG] Emitted ItemReplacementLoaded state');
      }
    } catch (e, stacktrace) {
      // print('🔥 [DEBUG] Exception caught: $e');
      // print('📜 [DEBUG] Stack trace: $stacktrace');

      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "Something Went Wrong try again...!",
        ),
      );
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

  updateManualState() {
    emit(ItemReplacementManualState());
  }

  updateScannerState() {
    emit(ReplacementScannerState());
  }
}
