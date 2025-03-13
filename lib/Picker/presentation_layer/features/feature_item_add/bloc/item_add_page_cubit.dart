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
import 'package:picker_driver_api/responses/order_response.dart';
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
    updatedata("", false);
  }

  // ScanResult? scanResult;

  ProductResponse? productResponse;

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
      if (produce) {
        // Replace the last 4 digits with '0'
        String updatedBarcode = sku.substring(0, sku.length - 6) + '000000';

        log(updatedBarcode);

        getProduct(updatedBarcode);
      } else {
        getProduct(sku);
      }
    } else {
      emit(ItemAddPageInitialState(productResponse));

      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(errorMessage: "Please Scan Barcode ...!"),
      );
    }
  }

  getProduct(String sku) async {
    try {
      log(sku);

      log("scanned barcode.............");

      final productresponse = await serviceLocator.tradingApi.getProductdata(
        product_id: sku.toString(),
        token: token,
      );

      if (productresponse.statusCode == 200) {
        Map<String, dynamic> item = json.decode(productresponse.body);

        if (item.containsKey('message')) {
          showSnackBar(
            context: context,
            snackBar: showErrorDialogue(
              errorMessage: item['message'],
              duration: Duration(seconds: 10),
            ),
          );
        } else {
          productResponse = ProductResponse.fromJson(
            jsonDecode(productresponse.body),
          );
          log(productresponse.toString());

          final fromDateString =
              productResponse!.customAttributes
                  .firstWhere(
                    (attr) => attr.attributeCode == 'special_from_date',
                    orElse:
                        () => CustomAttribute(
                          attributeCode: '',
                          value: '',
                        ), // Provide a default CustomAttribute
                  )
                  .value;

          final toDateString =
              productResponse!.customAttributes
                  .firstWhere(
                    (attr) => attr.attributeCode == 'special_to_date',
                    orElse:
                        () => CustomAttribute(
                          attributeCode: '',
                          value: '',
                        ), // Provide a default CustomAttribute
                  )
                  .value;

          final specialPriceString =
              productResponse!.customAttributes
                  .firstWhere(
                    (attr) => attr.attributeCode == 'special_price',
                    orElse: () => CustomAttribute(attributeCode: '', value: ''),
                  )
                  .value;

          specialFromDate =
              fromDateString != ''
                  ? DateTime.tryParse(fromDateString)
                  : DateTime.tryParse('0000-00-00 00:00:00');

          specialToDate =
              toDateString != ''
                  ? DateTime.tryParse(toDateString)
                  : DateTime.tryParse('0000-00-00 00:00:00');

          specialPrice =
              specialPriceString != ''
                  ? double.parse(specialPriceString.toString())
                  : 0.00;

          log(specialFromDate.toString());

          log(specialToDate.toString());

          log(specialPrice.toString());
        }
      } else {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "Barcode Not Found Please Check ..!",
          ),
        );
      }
    } catch (e) {
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "Something Went Wrong try again...!",
        ),
      );
    }

    emit(ItemAddPageInitialState(productResponse));
  }

  updateItem(int qty, BuildContext ctxt, String price) async {
    try {
      String pdtype =
          productResponse!.customAttributes
              .where((x) => x.attributeCode == "delivery_type")
              .first
              .value;

      if (getDelivery(pdtype) == orderItemsResponse!.type) {
        Map<String, dynamic> body = {
          "item_status": "new",
          "item_id": "0",
          "order_id": orderItemsResponse!.subgroupIdentifier,
          "productSku": productResponse!.sku,
          "productQty": qty,
          "picker_id": UserController.userController.profile.id,
          "shipping": 0,
          "item_name": productResponse!.name,
          "sp_price": price,
        };

        final response = await serviceLocator.tradingApi
            .updateItemStatusService(body: body, token: token);

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

        emit(ItemAddPageInitialState(productResponse));
      } else {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(errorMessage: 'Type Not Matching....!'),
        );
      }
      emit(ItemAddPageErrorState(false, productResponse));
    } catch (e) {
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(errorMessage: e.toString()),
      );
      emit(ItemAddPageErrorState(false, productResponse));
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
}
