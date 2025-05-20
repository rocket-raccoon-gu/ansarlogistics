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

class PostService {
  final ServiceLocator _serviceLocator;
  BuildContext context;
  int FETCH_LIMIT = 6;

  PostService(this._serviceLocator, this.context);

  List<Order> orderlist = [];

  Future<List<Order>> fetchpost(int page, int postcount, String status) async {
    print(
      "📌 fetchpost called with page=$page, postcount=$postcount, status=$status",
    );

    Map<String, dynamic> map = {};

    try {
      print("🔐 Getting user token...");
      String? token = await PreferenceUtils.getDataFromShared("usertoken");
      print("✅ Token received: $token");

      print("🌐 Sending API request to orderRequestService...");
      final responce = await _serviceLocator.tradingApi.orderRequestService(
        pagesize: FETCH_LIMIT,
        currentpage: page,
        token: token,
        role: '',
        status: status,
      );

      print("📥 Response status code: ${responce.statusCode}");

      if (responce.statusCode == 200) {
        print("📦 Raw response body: ${responce.body}");

        try {
          print("🔄 Decoding JSON response...");
          map = jsonDecode(responce.body);
          print("✅ Decoded Map: $map");

          if (map.containsKey("items")) {
            print("📄 Parsing items into OrderResponse...");
            OrderResponse orderResponse = OrderResponse.fromJson(map);
            orderlist = orderResponse.items;
            print("✅ Parsed Order List Length: ${orderlist.length}");
          } else if (map.containsKey("success") && map["success"] == 0) {
            print("⚠️ Session expired detected in response.");

            sessionTimeOutBottomSheet(
              context: context,
              inputWidget: SessionOutBottomSheet(
                onTap: () async {
                  print("🚪 Logging out due to session timeout...");
                  await PreferenceUtils.removeDataFromShared("userCode");
                  await logout(context);
                },
              ),
            );
          } else {
            print("❌ Unexpected response format: $map");
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

        print("📤 Returning orderlist of length: ${orderlist.length}");
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
      print("📨 Error message: $message");

      if (message.contains("The consumer isn't authorized")) {
        print("⚠️ Unauthorized access - session expired.");

        sessionTimeOutBottomSheet(
          context: context,
          inputWidget: SessionOutBottomSheet(
            onTap: () async {
              print("🚪 Logging out due to unauthorized access...");
              await PreferenceUtils.removeDataFromShared("userCode");
              await logout(context);
            },
          ),
        );
      } else {
        print("⚠️ General failure fallback triggered.");

        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "Something Went Wrong..! Logout and Try Again1",
          ),
        );
      }

      print("📤 Returning fallback orderlist of length: ${orderlist.length}");
      return orderlist;
    }
  }
}
