import 'dart:developer';

import 'package:ansarlogistics/Picker/repository_layer/more_content.dart';
import 'package:ansarlogistics/cashier/feature_cashier/bloc/cashier_orders_page_state.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/scrollable_bottomsheet.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/session_out_bottom_sheet.dart';
import 'package:ansarlogistics/firebase_configs/init_notification.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/cashier_order_response.dart';

class CashierOrdersPageCubit extends Cubit<CashierOrdersPageState> {
  final ServiceLocator serviceLocator;
  final BuildContext context;
  CashierOrdersPageCubit({required this.serviceLocator, required this.context})
    : super(CashierOrdersPageStateInitial()) {
    log('CashierOrdersPageCubit created');
    loadAssignedOrders();
    // Register the callback for notification refresh
    registerCashierOrdersRefreshCallback(loadAssignedOrders);
  }

  @override
  Future<void> close() {
    log('CashierOrdersPageCubit disposed');
    // Unregister the callback when cubit is disposed
    unregisterCashierOrdersRefreshCallback();
    return super.close();
  }

  loadOrders() async {
    emit(CashierOrdersPageStateLoading());
    try {
      final response = await serviceLocator.tradingApi.getCashierOrders(
        page: 1,
        limit: 10,
        token: UserController.userController.app_token,
      );

      // Guard against non-http responses (e.g., "Retry")
      if (response == null || response.statusCode == null) {
        emit(CashierOrdersPageStateError(message: 'Failed to load orders'));
        return;
      }

      if (response.statusCode == 401) {
        if (context.mounted) {
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

        return;
      }

      if (response.statusCode != 200) {
        emit(
          CashierOrdersPageStateError(
            message: response.body?.toString() ?? 'Unknown error',
          ),
        );
        return;
      }

      // response.body is a String; use the top-level helper to decode JSON
      final CashierOrders cashierOrders = cashierOrdersFromJson(response.body);

      emit(CashierOrdersPageStateSuccess(cashierOrders: cashierOrders));
    } catch (e) {
      emit(CashierOrdersPageStateError(message: e.toString()));
    }
  }

  searchcashierOrders(String search) async {
    try {
      final response = await serviceLocator.tradingApi.getCashierOrdersSearch(
        key: search,
        token: UserController.userController.app_token,
      );

      if (response == null || response.statusCode == null) {
        emit(CashierOrdersPageStateError(message: 'Failed to search orders'));
        return;
      }

      if (response.statusCode != 200) {
        emit(
          CashierOrdersPageStateError(
            message: response.body?.toString() ?? 'Unknown error',
          ),
        );
        return;
      }

      final CashierOrders cashierOrders = cashierOrdersFromJson(response.body);

      emit(CashierOrdersPageStateSuccess(cashierOrders: cashierOrders));
    } catch (e) {
      emit(CashierOrdersPageStateError(message: e.toString()));
    }
  }

  Future<void> loadAssignedOrders() async {
    emit(CashierOrdersPageStateLoading());
    try {
      final token1 = await PreferenceUtils.getDataFromShared("usertoken");

      final userId = UserController.userController.profile.id;
      final response = await serviceLocator.tradingApi.getCashierAssignedOrders(
        userId: userId,
        token: token1!,
      );

      // Guard against non-http responses (e.g., "Retry")
      if (response == null || response.statusCode == null) {
        emit(
          CashierOrdersPageStateError(
            message: 'Failed to load assigned orders',
          ),
        );
        return;
      }

      if (response.statusCode == 401) {
        if (context.mounted) {
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

        return;
      }

      if (response.statusCode != 200) {
        emit(
          CashierOrdersPageStateError(
            message: 'Failed to load assigned orders',
          ),
        );
        return;
      }

      final CashierOrders cashierOrders = cashierOrdersFromJson(response.body);

      emit(CashierOrdersPageStateSuccess(cashierOrders: cashierOrders));
    } catch (e) {
      emit(CashierOrdersPageStateError(message: e.toString()));
    }
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    required BuildContext context,
  }) async {
    try {
      emit(CashierOrdersPageStateLoading());

      final token = await PreferenceUtils.getDataFromShared("usertoken");
      final comment =
          'Order status updated to $status by ${UserController.userController.profile.name} (${UserController.userController.profile.empId})';

      log(comment);
      final response = await serviceLocator.tradingApi
          .updateMainOrderStatCashier(
            orderid: orderId,
            orderstatus: status,
            comment: comment,
            userid: UserController.userController.profile.empId,
            latitude: "",
            longitude: "",
            token1: token!,
          );

      if (response.statusCode == 200) {
        // Reload orders to get updated status
        await loadAssignedOrders();

        // Check if context is still valid before showing snackbar
        if (context.mounted) {
          showSnackBar(
            context: context,
            snackBar: showSuccessDialogue(
              message: "Order Status Updated Successfully!",
            ),
          );
        }
      } else {
        // Check if context is still valid before showing snackbar
        if (context.mounted) {
          showSnackBar(
            context: context,
            snackBar: showErrorDialogue(
              errorMessage: "Order Status Update Failed!",
            ),
          );
        }
      }
    } catch (e) {
      emit(
        CashierOrdersPageStateError(
          message: 'Unexpected error: ${e.toString()}',
        ),
      );
      // Check if context is still valid before showing snackbar
      if (context.mounted) {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(errorMessage: "Something went wrong!"),
        );
      }
    }
  }
}
