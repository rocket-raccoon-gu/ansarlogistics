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
    loadData(orderid);
  }

  List<StatusHistory> historylist = [];

  loadData(String orderid) async {
    if (!isClosed) {
      emit(StatusHistoryStateLoading());
    }

    try {
      final response = await serviceLocator.tradingApi.statusHistoryRequest(
        orderid: orderid,
      );

      if (response.statusCode == 200) {
        log("got it.....................$orderid");

        Map<String, dynamic> datamap = jsonDecode(response.body);

        StatusHistoryResponse statusHistoryResponse =
            await StatusHistoryResponse.fromJson(datamap);

        historylist = statusHistoryResponse.items;

        log("data");
      } else {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "something went wrong please try again....!",
          ),
        );
      }

      emit(StatusHistorystateInitial(historylist));
    } catch (e) {
      log("somthing went wrong");
      emit(StatusHistorystateInitial(historylist));
    }
  }
}
