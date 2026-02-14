import 'dart:convert';

import 'package:ansarlogistics/Picker/repository_layer/more_content.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/scrollable_bottomsheet.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/session_out_bottom_sheet.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:picker_driver_api/responses/driver_base_response.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';

class PostService {
  final ServiceLocator _serviceLocator;
  BuildContext context;
  int FETCH_LIMIT = 6;

  PostService(this._serviceLocator, this.context);

  List<DataItem> orderlist = [];

  Future<List<DataItem>> fetchpost(
    int page,
    int postcount,
    String status,
  ) async {
    Map<String, dynamic> map = {};

    try {
      String? token = await PreferenceUtils.getDataFromShared("usertoken");

      int userId = UserController.userController.profile.id;

      final responce = await _serviceLocator.tradingApi.orderRequestService(
        pagesize: FETCH_LIMIT,
        currentpage: page,
        token: token,
        status: status,
        id: userId,
      );

      if (responce.statusCode == 200) {
        map = jsonDecode(responce.body);

        if (map.containsKey("data")) {
          DriverBaseOrderResponse orderResponse =
              DriverBaseOrderResponse.fromJson(map);
          orderlist = orderResponse.data.items;
        } else if (map.containsKey("success") && map["success"] == 0) {
          // print("ok");
          // ignore: use_build_context_synchronously
          sessionTimeOutBottomSheet(
            context: context,
            inputWidget: SessionOutBottomSheet(
              onTap: () async {
                await PreferenceUtils.removeDataFromShared("userCode");
                await logout(context);
              },
            ),
          );
        }
        return orderlist;
      } else {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "Something Went Wrong..! Logout and Try Again",
          ),
        );

        return [];
      }
    } catch (e) {
      if (map['message'] ==
          "The consumer isn't authorized to access %resources.") {
        // print(map['message']);
        sessionTimeOutBottomSheet(
          context: context,
          inputWidget: SessionOutBottomSheet(
            onTap: () async {
              await PreferenceUtils.removeDataFromShared("userCode");
              await logout(context);
            },
          ),
        );
      } else {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "Something Went Wrong..! Logout and Try Again",
          ),
        );
      }

      return orderlist;
    }
    // }
  }

  // New non-paginated endpoint: /api/picker/ordersnew
  Future<OrdersNewResponse?> fetchOrdersNew() async {
    // Do not assume the JSON root is a Map; backend might return a List
    try {
      final String? token = await PreferenceUtils.getDataFromShared(
        "usertoken",
      );

      final response =
          await _serviceLocator.tradingApi.ordersNewRequestService(
                token: token ?? "",
              )
              as dynamic;

      if (response?.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        // if (decoded is Map<String, dynamic>) {
        OrdersNewResponse ordersNewResponse = OrdersNewResponse.fromJson(
          decoded,
        );
        return ordersNewResponse;
        // }

        // if (decoded is List) {
        //   // Normalize list response into expected shape
        //   final List list = decoded;
        //   final Map<String, dynamic> data = {};

        //   if (list.isNotEmpty && list.first is Map) {
        //     final Map first = list.first as Map;
        //     final bool looksLikeOrder =
        //         first.containsKey('status') ||
        //         first.containsKey('items') ||
        //         first.containsKey('customer');

        //     if (looksLikeOrder) {
        //       data['orders'] = List<Map<String, dynamic>>.from(list);
        //     } else {
        //       data['categories'] = List<Map<String, dynamic>>.from(list);
        //     }
        //   } else {
        //     data['orders'] = <Map<String, dynamic>>[];
        //   }

        //   final normalized = <String, dynamic>{
        //     'success': true,
        //     'count': list.length,
        //     'data': data,
        //     'message': null,
        //   };

        //   return OrdersNewResponse.fromJson(normalized);
        // }

        // Unexpected payload shape
      } else if (response?.statusCode == 401) {
        // session timeout handling similar to fetchpost
        // ignore: use_build_context_synchronously
        sessionTimeOutBottomSheet(
          context: context,
          inputWidget: SessionOutBottomSheet(
            onTap: () async {
              await PreferenceUtils.removeDataFromShared("userCode");
              await logout(context);
            },
          ),
        );

        return null;
      } else {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "Failed to load orders. Please try again.",
          ),
        );
        return null;
      }
    } catch (e) {
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "Something Went Wrong..! Logout and Try Again",
        ),
      );
      return null;
    }
  }
}
