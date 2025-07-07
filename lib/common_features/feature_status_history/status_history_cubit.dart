import 'dart:convert';
import 'dart:developer';
import 'package:ansarlogistics/common_features/feature_status_history/status_history_state.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/status_history_response.dart';

class StatusHistoryCubit extends Cubit<StatusHistoryState> {
  BuildContext context;
  final ServiceLocator serviceLocator;
  String orderid;

  StatusHistoryCubit(this.context, this.serviceLocator, this.orderid)
    : super(StatusHistoryStateLoading()) {
    // print(
    //   "🟡 Constructor called for StatusHistoryCubit with orderid: $orderid",
    // );
    loadData(orderid);
  }

  List<StatusHistory> historylist = [];

  loadData(String orderid) async {
    // print("📤 loadData() started for orderid: $orderid");

    if (!isClosed) {
      emit(StatusHistoryStateLoading());
      // print("📡 Emitted: StatusHistoryStateLoading");
    }

    try {
      // print("🌐 Calling API: statusHistoryRequest");
      final response = await serviceLocator.tradingApi.statusHistoryRequest(
        orderid: orderid,
      );

      // print("✅ API Response Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        log("got it.....................$orderid");
        // print("📦 Success: Response received");

        Map<String, dynamic> datamap = jsonDecode(response.body);
        // print("🧩 Decoded JSON: $datamap");

        StatusHistoryResponse statusHistoryResponse =
            await StatusHistoryResponse.fromJson(datamap);
        // print("🔄 Parsed StatusHistoryResponse");

        historylist = statusHistoryResponse.items;
        // print("📊 Items Count: ${historylist.length}");

        log("data");
      } else {
        // print("❌ Error: Non-200 response");
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "something went wrong please try again....!",
          ),
        );
      }

      emit(StatusHistorystateInitial(historylist));
      // print(
      //   "✅ Emitted: StatusHistorystateInitial with ${historylist.length} items",
      // );
    } catch (e) {
      log("somthing went wrong");
      // print("🔥 Exception occurred: $e");

      emit(StatusHistorystateInitial(historylist));
      // print(
      //   "⚠️ Emitted fallback: StatusHistorystateInitial with ${historylist.length} items",
      // );
    }
  }
}
