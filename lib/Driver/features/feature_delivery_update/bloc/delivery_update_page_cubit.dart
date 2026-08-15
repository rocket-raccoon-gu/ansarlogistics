import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:ansarlogistics/Driver/features/feature_delivery_update/bloc/delivery_update_page_state.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/driver_base_response.dart';
import 'package:toastification/toastification.dart';

class DeliveryUpdatePageCubit extends Cubit<DeliveryUpdatePageState> {
  final ServiceLocator serviceLocator;
  BuildContext context;
  Map<String, dynamic> data;
  DeliveryUpdatePageCubit({
    required this.serviceLocator,
    required this.context,
    required this.data,
  }) : super(DeliveryUpdatePageInitial()) {
    updateOrder();
  }

  DataItem? orderResponseItem;

  updateOrder() {
    orderResponseItem = data['order'];
    emit(DeliveryUpdatePageInitial());
  }

  String? imageurl;
  bool billUploaded = false;
  bool updatestat = false;

  String get orderId =>
      orderResponseItem?.order.subgroupIdentifier ?? '';

  bool get isWarehouseOrder {
    final order = orderResponseItem;
    if (order == null) return false;
    return getType(order) == 'WAR';
  }

  Future<void> uploadimage(File billfile) async {
    try {
      if (orderId.isEmpty) {
        emit(DeliveryBillUpdateErrorState());
        return;
      }

      final token = await PreferenceUtils.getDataFromShared("usertoken") ?? '';

      final response = await serviceLocator.tradingApi.uploadDriverBill(
        bill: billfile,
        orderId: orderId,
        token: token,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final success = body['success'] == true;
        if (success) {
          imageurl =
              (body['bill_image'] ?? body['data']?['bill_image'])?.toString();
          billUploaded = true;
          log("bill uploaded: $imageurl");
          emit(DeliveryBillUpdatedState(true));
          return;
        }
      }

      billUploaded = false;
      log("bill upload failed: ${response.statusCode} ${response.body}");
      emit(DeliveryBillUpdateErrorState());
    } catch (e, st) {
      billUploaded = false;
      log("bill upload error: $e", stackTrace: st);
      emit(DeliveryBillUpdateErrorState());
    }
  }

  void resetBillUpload() {
    billUploaded = false;
    imageurl = null;
    emit(DeliveryUpdatePageInitial());
  }

  Future<void> updateMainOrderStat(String status) async {
    if (!billUploaded) {
      toastification.show(
        backgroundColor: customColors().warning,
        title: TranslatedText(
          text: "Please upload the bill first",
          style: customTextStyle(
            fontStyle: FontStyle.BodyL_Bold,
            color: FontColor.White,
          ),
        ),
        autoCloseDuration: const Duration(seconds: 4),
      );
      return;
    }

    try {
      updatestat = true;
      emit(DeliveryStatusUpdateState());

      final coords = await getDriverCoordinatesFast();
      final token =
          UserController().app_token.isNotEmpty
              ? UserController().app_token
              : UserController().profile.token.toString();

      final resp = await serviceLocator.tradingApi.updateMainOrderStat(
        orderid: orderId,
        orderstatus: status,
        comment:
            "${UserController().profile.name.toString()} (${UserController().profile.empId}) is Delivered This Order",
        userid: UserController().profile.id.toString(),
        latitude: coords.lat,
        longitude: coords.lng,
        token1: token,
      );

      PreferenceUtils.storeDataToShared("driverlat", coords.lat);
      PreferenceUtils.storeDataToShared("driverlong", coords.lng);

      if (resp.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(resp.body);

        if (data['message'].toString().contains(
          "Please mark order from delivered location",
        )) {
          toastification.show(
            backgroundColor: customColors().warning,
            title: TranslatedText(
              text: "Please mark order from \n delivered location",
              maxLines: 2,
              style: customTextStyle(
                fontStyle: FontStyle.BodyL_Bold,
                color: FontColor.White,
              ),
            ),
            autoCloseDuration: const Duration(seconds: 5),
          );

          updatestat = false;
          emit(DeliveryStatusUpdateState());
        } else {
          toastification.show(
            backgroundColor: customColors().secretGarden,
            title: TranslatedText(
              text: "Order Status Updated",
              style: customTextStyle(
                fontStyle: FontStyle.BodyL_Bold,
                color: FontColor.White,
              ),
            ),
            autoCloseDuration: const Duration(seconds: 5),
          );

          Navigator.of(context).popUntil((route) => route.isFirst);
          context.gNavigationService.openDriverDashBoardPage(context);
        }
      } else {
        toastification.show(
          backgroundColor: customColors().warning,
          title: TranslatedText(
            text: "Status Update Failed Please Try Again..!.",
            style: customTextStyle(
              fontStyle: FontStyle.BodyL_Bold,
              color: FontColor.White,
            ),
          ),
          autoCloseDuration: const Duration(seconds: 5),
        );

        updatestat = false;
        emit(DeliveryStatusUpdateState());
      }
    } catch (e) {
      toastification.show(
        backgroundColor: customColors().warning,
        title: TranslatedText(
          text: "Status Update Failed Please Try Again..!.",
          style: customTextStyle(
            fontStyle: FontStyle.BodyL_Bold,
            color: FontColor.White,
          ),
        ),
        autoCloseDuration: const Duration(seconds: 5),
      );
      updatestat = false;
      emit(DeliveryStatusUpdateState());
    }
  }
}
