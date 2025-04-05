import 'dart:convert';
import 'dart:developer';

import 'package:ansarlogistics/Driver/features/feature_driver_order_inner/bloc/driver_order_inner_page_state.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:picker_driver_api/responses/order_response.dart';
import 'package:toastification/toastification.dart';

class DriverOrderInnerPageCubit extends Cubit<DriverOrderInnerPageState> {
  final ServiceLocator serviceLocator;
  BuildContext context;
  Map<String, dynamic> data;
  DriverOrderInnerPageCubit({
    required this.serviceLocator,
    required this.context,
    required this.data,
  }) : super(DriverOrderLoadingPageState()) {
    updateSelectedItem(0);
  }

  List<EndPicking> assignedDriver = [];

  updateSelectedItem(int val) async {
    assignedDriver.clear();

    Order orderItem = data['orderitem'];

    String? token = await PreferenceUtils.getDataFromShared("usertoken");

    if (!isClosed) {
      emit(DriverOrderLoadingPageState());
    }

    if (orderItem.items.assignedDriver!.isNotEmpty) {
      assignedDriver.addAll(orderItem.items.assignedDriver!);
    }

    if (orderItem.items.onTheWay!.isNotEmpty) {
      assignedDriver.addAll(orderItem.items.onTheWay!);
    }

    if (orderItem.items.holded!.isNotEmpty) {
      assignedDriver.addAll(orderItem.items.holded!);
    }

    emit(DriverOrderInitialPageState(assignedDriver: assignedDriver));
  }

  // updateSelectedItem(int val) async {

  //   assignedDriver.clear();

  //   String? token = await PreferenceUtils.getDataFromShared("usertoken");

  //   final response = await serviceLocator.tradingApi.orderItemRequestService(
  //       orderid: orderItem.subgroupIdentifier, token: token);

  //   if (response != null && response.statusCode == 200) {
  //     Map<String, dynamic> mapdata = jsonDecode(response.body);

  //     if (mapdata.containsKey('success') && mapdata['success'] == 0) {
  //       showSnackBar(
  //           context: context,
  //           snackBar: showErrorDialogue(
  //               errorMessage: "Token got expired try again..."));
  //     } else {
  //       OrderItemsResponse orderItemsResponse =
  //           OrderItemsResponse.fromJson(mapdata);

  //       if (orderItemsResponse.items.assignedDriver.isNotEmpty) {
  //         assignedDriver.addAll(orderItemsResponse.items.assignedDriver);
  //       } else {
  //         assignedDriver.addAll(orderItemsResponse.items.onTheWay);
  //       }

  //       if (orderItemsResponse.items.holded.isNotEmpty) {
  //         assignedDriver.addAll(orderItemsResponse.items.holded);
  //       }

  //       if (orderItemsResponse.items.onTheWay.isNotEmpty) {
  //         assignedDriver.addAll(orderItemsResponse.items.onTheWay);
  //       }
  //     }
  //   }

  //   emit(DriverOrderInitialPageState(assignedDriver: assignedDriver));
  // }

  updateMainOrderStat(String orderid, String status) async {
    try {
      final resp = await serviceLocator.tradingApi.updateMainOrderStat(
        orderid: orderid,
        orderstatus: status,
        comment:
            "${UserController().profile.name.toString()} (${UserController().profile.empId}) is on the way to delivery location",
        userid: UserController().profile.id,
        latitude: UserController.userController.locationlatitude,
        longitude: UserController.userController.locationlongitude,
      );

      if (resp.statusCode == 200) {
        await Permission.location.isGranted.then((value) async {
          if (value) {
            try {
              Position position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
              );

              await PreferenceUtils.storeDataToShared(
                "userlat",
                position.latitude.toString(),
              );

              await PreferenceUtils.storeDataToShared(
                "userlong",
                position.longitude.toString(),
              );

              UserController.userController.locationlatitude =
                  position.latitude.toString();

              UserController.userController.locationlongitude =
                  position.longitude.toString();

              final resp1 = await serviceLocator.tradingApi
                  .updateDriverLocationdetails(
                    userId: int.parse(UserController().profile.id),
                    latitude: position.latitude.toString(),
                    longitude: position.longitude.toString(),
                  );

              if (resp1.statusCode == 200) {
                log("location updated");
              }
            } catch (e) {
              log(e.toString());
            }
          }
        });

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

        // loading = false;

        Navigator.of(context).popUntil((route) => route.isFirst);

        context.gNavigationService.openDriverDashBoardPage(context);
      } else {
        log(jsonDecode(resp.body)['message']);

        toastification.show(
          backgroundColor: customColors().carnationRed,
          title: TranslatedText(
            text: "${jsonDecode(resp.body)['message']}",
            textAlign: TextAlign.justify,
            maxLines: 3,
            style: customTextStyle(
              fontStyle: FontStyle.BodyL_Bold,
              color: FontColor.White,
            ),
          ),
          autoCloseDuration: const Duration(seconds: 5),
        );

        emit(DriverOrderInitialErrorState(assignedDriver));
      }
    } catch (e) {
      toastification.show(
        backgroundColor: customColors().carnationRed,
        title: TranslatedText(
          text: "Status Update Failed Please Try Again..!.",
          style: customTextStyle(
            fontStyle: FontStyle.BodyL_Bold,
            color: FontColor.White,
          ),
        ),
        autoCloseDuration: const Duration(seconds: 5),
      );

      emit(DriverOrderInitialErrorState(assignedDriver));
    }
  }
}
