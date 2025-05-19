// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:developer';

import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_inner/bloc/order_item_details_state.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/bloc/picker_orders_cubit.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/notifier.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/order_response.dart';
import 'package:picker_driver_api/responses/product_bd_data_response.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:picker_driver_api/responses/erp_data_response.dart';

class OrderItemDetailsCubit extends Cubit<OrderItemDetailsState> {
  ServiceLocator serviceLocator;
  BuildContext context;
  Map<String, dynamic> data;
  OrderItemDetailsCubit({
    required this.serviceLocator,
    required this.context,
    required this.data,
  }) : super(OrderItemDetailLoadingState()) {
    updatedata();
  }

  EndPicking? orderItem;

  Order? orderResponseItem;

  bool loading = false;

  String colorOptionId = "";

  String carpetOptionId = "";

  String color = "";

  String carpetSizeValue = "";

  Map<String, dynamic>? productoptions = {};

  ColorInfo? colorInfo;

  CarpetSizeInfo? carpetSizeInfo;

  bool povisvible = false;

  updatedata() {
    orderItem = data['item'];
    orderResponseItem = data['order'];

    if (orderItem!.productOptions.isNotEmpty) {
      productoptions = orderItem!.productOptions;
    }

    if (productoptions!.isNotEmpty &&
        productoptions!.containsKey('attributes_info')) {
      final attributesInfo =
          productoptions!['attributes_info'] as List<dynamic>;

      // 2. Access super_attribute map and get the value using option_id as key
      final superAttributes =
          productoptions!["info_buyRequest"]["super_attribute"]
              as Map<String, dynamic>;

      // Step 2: Find the Color attribute
      final colorAttribute = attributesInfo.firstWhere(
        (attr) => attr['label'] == 'Color',
        orElse: () => null,
      );

      // Step 3: Extract option_id for Color
      if (colorAttribute != null) {
        colorOptionId = colorAttribute['option_value'];
        log('Color Option ID: $colorOptionId'); // Output: 93

        colorInfo = getColorInfo(colorOptionId);
      } else {
        print('Color attribute not found');
      }

      // 4. Find the Carpet Size attribute
      final carpetSizeAttribute = attributesInfo.firstWhere(
        (attr) => attr['label'] == 'Carpet Size',
        orElse: () => null,
      );

      if (carpetSizeAttribute != null) {
        carpetOptionId = carpetSizeAttribute['option_id'].toString();

        log("Carpet Option ID: $carpetOptionId");

        carpetSizeValue = superAttributes["$carpetOptionId"]; // "856"

        log("Carpet Value: $carpetSizeValue");

        carpetSizeInfo = getCarpetSizeInfo(carpetSizeValue);
      }
    }

    if (!isClosed) {
      emit(OrderItemDetailInitialState(orderItem: orderItem!));
    }
  }

  updateBarcodeLog(String sku, String scannedsku) async {
    try {
      final response = await serviceLocator.tradingApi.updateBarcodeLog(
        orderid: orderResponseItem!.subgroupIdentifier,
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

  updateitemstatuspick(String qty, String scannedSku, String price) async {
    try {
      String? token = await PreferenceUtils.getDataFromShared("usertoken");

      Map<String, dynamic> body = {
        "item_id": int.parse(orderItem!.itemId),
        "scanned_sku": scannedSku,
        "item_status": "end_picking",
        "shipping": "",
        "price": double.parse(price),
        "qty": double.parse(qty).toInt(),
        "reason": "",
        "picker_id": int.parse(UserController().profile.id),
        "is_produce": int.parse(orderItem!.isproduce),
        "qty_orderd": double.parse(orderItem!.qtyOrdered).toInt(),
      };

      loading = true;

      final response = await serviceLocator.tradingApi.updateItemStatusService(
        body: body,
        token: token,
      );

      if (response.statusCode == 200) {
        loading = false;

        UserController.userController.indexlist.add(orderItem!);
        UserController.userController.pickerindexlist.add(orderItem!.itemId);

        log("💵 Price logged: $price");

        eventBus.fire(
          DataChangedEvent(
            "New Data from Screen B",
          ).updatePriceData(orderResponseItem!.subgroupIdentifier, price),
        );

        showSnackBar(
          context: context,
          snackBar: showSuccessDialogue(message: "status updted2222222222"),
        );

        Navigator.of(context).popUntil((route) => route.isFirst);

        context.gNavigationService.openPickerOrderInnerPage(
          context,
          arg: {'orderitem': orderResponseItem},
        );
      } else {
        loading = false;

        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "status update failed try again..one.",
          ),
        );

        if (!isClosed) {
          emit(
            OrderItemDetailErrorState(loading: loading, orderItem: orderItem!),
          );
        }
      }
    } catch (e, stacktrace) {
      loading = false;

      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "status update failed try again..two.",
        ),
      );

      if (!isClosed) {
        emit(
          OrderItemDetailErrorState(loading: loading, orderItem: orderItem!),
        );
      }
    }
  }

  updateitemstatus(
    String item_status,
    String qty,
    String reason,
    String price,
  ) async {
    try {
      String? token = await PreferenceUtils.getDataFromShared("usertoken");

      Map<String, dynamic> body = {};

      body = {
        "item_id": orderItem!.itemId,
        "item_status": item_status,
        "shipping": "",
        "price": orderItem!.price,
        "qty": qty,
        "reason": "",
        "picker_id": UserController().profile.id,
        "is_produce": orderItem!.isproduce,
        "qty_orderd": orderItem!.qtyOrdered,
      };

      loading = true;

      final response = await serviceLocator.tradingApi.updateItemStatusService(
        body: body,
        token: token,
      );

      if (response.statusCode == 200) {
        // loading = false;

        // if (item_status == "end_picking") {
        //   UserController.userController.indexlist.add(orderItem!);
        //   UserController.userController.pickerindexlist.add(orderItem!.itemId);
        // } else
        if (item_status == "item_not_available") {
          UserController.userController.itemnotavailablelist.add(orderItem!);
          UserController.userController.notavailableindexlist.add(
            orderItem!.itemId,
          );
        }

        // // UserController.userController.alloworderupdated = true;

        // showSnackBar(
        //   context: context,
        //   snackBar: showSuccessDialogue(message: "status updted"),
        // );

        eventBus.fire(DataChangedEvent("New Data from Screen B"));

        Navigator.of(context).popUntil((route) => route.isFirst);

        // context.read<PickerOrdersCubit>().loadPosts(0, 'all');

        context.gNavigationService.openPickerOrderInnerPage(
          context,
          arg: {'orderitem': orderResponseItem},
        );
      } else {
        loading = false;
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "status update failed try again..three.",
          ),
        );

        if (!isClosed) {
          emit(
            OrderItemDetailErrorState(loading: loading, orderItem: orderItem!),
          );
        }
      }
    } catch (e) {
      loading = false;

      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "status update failed try again.four..",
        ),
      );

      if (!isClosed) {
        emit(
          OrderItemDetailErrorState(loading: loading, orderItem: orderItem!),
        );
      }
    }
  }

  void searchOnGoogle(String keyword) async {
    final searchUrl =
        "https://www.google.com/search?q=${Uri.encodeQueryComponent(keyword)}";
    // ignore: deprecated_member_use
    try {
      if (await canLaunch(searchUrl)) {
        await launch(searchUrl);
      } else {
        throw 'Could not launch $searchUrl';
      }
    } catch (e) {
      print("Error launching URL: $e");
    }
  }

  checkitemdb(String qty, String scannedSku, EndPicking? orderItem) async {
    try {
      String convertbarcode = '';

      if (orderItem!.isproduce == "1") {
        convertbarcode = replaceAfterFirstSixWithZero(scannedSku);
      }

      log(scannedSku);

      final response = await serviceLocator.tradingApi.checkBarcodeDBService(
        endpoint: convertbarcode != '' ? convertbarcode : scannedSku,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        if (data['priority'] == 1) {
          ErPdata erPdata = ErPdata.fromJson(data);

          if (!povisvible) {
            povisvible = true;

            showPickConfirmDialogue(
              context,
              '${erPdata.message} $scannedSku',
              () {
                if (orderItem.price == erPdata.erpPrice) {
                  updateitemstatuspick(
                    qty,
                    scannedSku,
                    orderItem.isproduce == "1"
                        ? getPriceFromBarcode(getLastSixDigits(scannedSku))
                        : erPdata.erpPrice,
                  );
                } else {
                  showSnackBar(
                    context: context,
                    snackBar: showErrorDialogue(
                      errorMessage: "price not same please replace the item",
                    ),
                  );
                }
              },
              erPdata.erpSku,
              orderItem.isproduce == "1"
                  ? getPriceFromBarcode(getLastSixDigits(scannedSku))
                  : erPdata.erpPrice,
              qty,
              erPdata.erpProductName,
              () {
                context.gNavigationService.back(context);
                povisvible = false;
              },
            );
          }
        } else if (data['priority'] == 2) {
          ProductDBdata productDBdata = ProductDBdata.fromJson(data);

          if (!povisvible) {
            povisvible = true;

            showPickConfirmDialogue(
              context,
              'Barcode Found in System',
              () {
                // if (orderItem.price == productDBdata.currentPromotionPrice) {
                updateitemstatuspick(
                  qty,
                  scannedSku,
                  orderItem.isproduce == "1"
                      ? getPriceFromBarcode(getLastSixDigits(scannedSku))
                      : productDBdata.currentPromotionPrice,
                );
                // } else {
                //   showSnackBar(
                //     context: context,
                //     snackBar: showErrorDialogue(
                //       errorMessage: "price not same please replace the item",
                //     ),
                //   );
                // }
              },
              productDBdata.sku,
              orderItem.isproduce == "1"
                  ? getPriceFromBarcode(getLastSixDigits(scannedSku))
                  : double.parse(
                    productDBdata.currentPromotionPrice,
                  ).toStringAsFixed(2),
              qty,
              productDBdata.skuName,
              () {
                context.gNavigationService.back(context);
                povisvible = false;
              },
            );
          }
        } else if (data.containsKey('suggestion')) {
          showSnackBar(
            context: context,
            snackBar: showErrorDialogue(errorMessage: data['message']),
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
    } catch (e) {
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "Barcode Not Scanned Please Retry!",
        ),
      );
    }
  }
}
