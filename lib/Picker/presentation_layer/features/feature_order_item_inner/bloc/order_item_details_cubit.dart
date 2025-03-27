// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_inner/bloc/order_item_details_state.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/notifier.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/order_response.dart';
import 'package:url_launcher/url_launcher.dart';

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

  updatedata() {
    orderItem = data['item'];
    orderResponseItem = data['order'];

    if (orderItem!.productOptions.isNotEmpty) {
      productoptions = orderItem!.productOptions;
    }

    if (productoptions!.isNotEmpty) {
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
        "shipping": "0",
        "price": price,
        "qty": qty,
        "reason": "",
        "picker_id": UserController().profile.id,
      };

      loading = true;

      final response = await serviceLocator.tradingApi.updateItemStatusService(
        body: body,
        token: token,
      );

      if (response.statusCode == 200) {
        loading = false;

        if (item_status == "end_picking") {
          UserController.userController.indexlist.add(orderItem!);
          UserController.userController.pickerindexlist.add(orderItem!.itemId);
        } else if (item_status == "item_not_available") {
          UserController.userController.itemnotavailablelist.add(orderItem!);
          UserController.userController.notavailableindexlist.add(
            orderItem!.itemId,
          );
        }

        // UserController.userController.alloworderupdated = true;

        showSnackBar(
          context: context,
          snackBar: showSuccessDialogue(message: "status updted"),
        );

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
            errorMessage: "status update failed try again...",
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
          errorMessage: "status update failed try again...",
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
}
