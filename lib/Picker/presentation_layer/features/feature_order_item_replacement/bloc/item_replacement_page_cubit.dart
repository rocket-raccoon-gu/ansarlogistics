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

  bool loadking = false;

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

  updatereplacement(
    int selectedindex,
    String product_name,
    String reason,
    int editqty,
    BuildContext ctxt,
    String price,
    String promo_price,
    String regularprice,
    String scannedsku1,
  ) async {
    try {
      String? token = await PreferenceUtils.getDataFromShared("usertoken");

      Map<String, dynamic> body = {};

      body = {
        "item_status": "replaced",
        "item_id": itemdata!.itemId,
        "canceled_sku": itemdata!.productSku,
        "new_sku": scannedsku1,
        "product_name": product_name,
        "new_product_qty": editqty != 0 ? editqty : itemdata!.qtyOrdered,
        "order_id": orderItemsResponse!.subgroupIdentifier,
        "picker_id": UserController.userController.profile.id,
        "shipping": 0,
        "reason": reason,
        "price": price,
        "promo_price": promo_price,
        "regular_price": regularprice,
      };

      loadking = true;

      if (loadking) {
        log(body.toString());
        final response = await serviceLocator.tradingApi
            .updateItemStatusService(body: body, token: token);

        if (response.statusCode == 200) {
          loadking = false;

          UserController.userController.notavailableindexlist.add(
            itemdata!.itemId,
          );

          showSnackBar(
            context: context,
            snackBar: showSuccessDialogue(message: "status updted"),
          );

          // // ignore: use_build_context_synchronously
          // BlocProvider.of<PickerOrdersCubit>(ctxt).loadPosts(0, "");

          // context.gNavigationService.openPickerWorkspacePage(context);

          eventBus.fire(
            DataChangedEvent(
              "New Data from Screen B",
            ).updatePriceData(orderItemsResponse!.subgroupIdentifier, price),
          );

          UserController.userController.alloworderupdated = true;

          Navigator.of(context).popUntil((route) => route.isFirst);

          context.gNavigationService.openPickerOrderInnerPage(
            context,
            arg: {'orderitem': orderItemsResponse},
          );
        } else {
          loadking = false;
          showSnackBar(
            context: context,
            snackBar: showErrorDialogue(
              errorMessage: "status update Failed...",
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
    } catch (e) {
      loadking = false;

      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(errorMessage: "status update Failed..."),
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
    // if (!isClosed) {
    //   emit(ItemLoading());
    // }

    if (produce) {
      // Replace the last 4 digits with '0'

      String updatedBarcode =
          '${barcodeString.substring(0, barcodeString.length - 6)}000000';

      log(updatedBarcode);

      getProductData(updatedBarcode);
    } else {
      getProductData(barcodeString);
    }
  }

  getProductData(String sku) async {
    try {
      log("scanned barcode.............");

      if (sku.startsWith(']C1')) {
        log('contains c1');
        sku = sku.replaceAll(']C1', '');
      } else if (sku.startsWith('C1')) {
        sku = sku.replaceAll('C1', '');
      }

      String? token = await PreferenceUtils.getDataFromShared("usertoken");

      log("sku  :  $sku");

      final response = await serviceLocator.tradingApi.checkBarcodeDBService(
        endpoint: sku,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> item = json.decode(response.body);

        showsku = sku;

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
        if (!isClosed) {
          emit(
            ItemReplacementLoaded(
              erPdata: erPdata,
              productDBdata: productDBdata,
            ),
          );
        }
      } else {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(errorMessage: "Product Not Found ...!"),
        );
      }
    } catch (e) {
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "Something went wrong..! Try Again",
        ),
      );
    }

    // emit(
    //   ItemReplacementInitail(
    //     itemdata: itemdata,
    //     replacements: relatableitems,
    //     prwork: prwork,
    //     loading: false,
    //   ),
    // );
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
