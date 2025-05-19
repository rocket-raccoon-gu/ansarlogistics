// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:ansarlogistics/Picker/repository_layer/more_content.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/scrollable_bottomsheet.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/session_out_bottom_sheet.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/order_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostService {
  final ServiceLocator _serviceLocator;
  BuildContext context;
  int FETCH_LIMIT = 6;

  PostService(this._serviceLocator, this.context);

  List<Order> orderlist = [];

  Future<List<Order>> fetchpost(int page, int postcount, String status) async {
    Map<String, dynamic> map = {};
    try {
      String? token = await PreferenceUtils.getDataFromShared("usertoken");

      final responce = await _serviceLocator.tradingApi.orderRequestService(
        pagesize: FETCH_LIMIT,
        currentpage: page,
        token: token,
        role: '',
        status: status,
      );

      if (responce.statusCode == 200) {
        print(jsonEncode(responce.statusCode));

        try {
          map = jsonDecode(responce.body);
          print(map);

          if (map.containsKey("items")) {
            OrderResponse orderResponse = OrderResponse.fromJson(map);
            orderlist = orderResponse.items;
          } else if (map.containsKey("success") && map["success"] == 0) {
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
        } catch (e) {
          print("❌ JSON decode failed: $e");
          print("❌ Raw response body: ${responce.body}");
          showSnackBar(
            context: context,
            snackBar: showErrorDialogue(
              errorMessage: "Invalid response format from server.",
            ),
          );
        }

        return orderlist;
      } else {
        print("❌ API returned non-200 status code: ${responce.statusCode}");
        print("❌ Raw response body: ${responce.body}");

        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "Something Went Wrong..! Logout and Try Again2",
          ),
        );

        return [];
      }
    } catch (e) {
      print("❌ Exception caught in fetchpost: $e");

      final message = map['message']?.toString() ?? '';

      if (message.contains("The consumer isn't authorized")) {
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
            errorMessage: "Something Went Wrong..! Logout and Try Again1",
          ),
        );
      }

      return orderlist;
    }
  }
}
