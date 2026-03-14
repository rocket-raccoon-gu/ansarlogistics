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
  int _orderCount = 0; // Private variable to store count

  int get orderCount => _orderCount; // Public getter

  CashierOrdersPageCubit({required this.serviceLocator, required this.context})
    : super(CashierOrdersPageStateInitial()) {
    log('CashierOrdersPageCubit created');
    // loadAssignedOrders();
    // Get initial order count
    findordercount();
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
      final token = await PreferenceUtils.getDataFromShared("usertoken");

      final response = await serviceLocator.tradingApi.getCashierOrders(
        page: 1,
        limit: 10,
        token: token!,
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
                // // await logout(context);
                // Navigator.of(
                //   context,
                // ).pushNamedAndRemoveUntil('/splash', (route) => false);
                logout(context);
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
      final token = await PreferenceUtils.getDataFromShared("usertoken");

      final response = await serviceLocator.tradingApi.getCashierOrdersSearch(
        key: search,
        token: token!,
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

  findordercount() async {
    try {
      final token1 = await PreferenceUtils.getDataFromShared("usertoken");

      final userId = UserController.userController.profile.id;
      final response = await serviceLocator.tradingApi.getCashierAssignedOrders(
        userId: userId,
        token: token1!,
      );

      // Guard against non-http responses (e.g., "Retry")
      if (response == null || response.statusCode == null) {
        return;
      }

      if (response.statusCode == 200) {
        final CashierOrders cashierOrders = cashierOrdersFromJson(
          response.body,
        );
        _orderCount = cashierOrders.data.length; // Use private variable
        // Emit state to update the UI with the count
        emit(
          CashierOrdersPageStateSuccess(
            cashierOrders: CashierOrders(
              success: true,
              count: _orderCount,
              totalCount: _orderCount,
              pagination: Pagination(
                currentPage: 1,
                totalPages: 1,
                totalItems: _orderCount,
                itemsPerPage: 10,
                hasNext: false,
                hasPrev: false,
              ),
              data: [], // Keep data empty since we only want count
            ),
          ),
        );
      }
    } catch (e) {
      log('Error finding order count: $e');
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
                // Navigator.of(
                //   context,
                // ).pushNamedAndRemoveUntil('/splash', (route) => false);
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
            clubvalue: 0,
            tripid: "",
          );

      if (response.statusCode == 200) {
        // Update only the specific order's status locally
        _updateSingleOrderStatus(orderId, status);

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
        // Handle error case
        if (context.mounted) {
          showSnackBar(
            context: context,
            snackBar: showErrorDialogue(
              errorMessage: "Failed to update order status",
            ),
          );
        }
      }
    } catch (e) {
      log('Error updating order status: $e');
      // Handle error case
      if (context.mounted) {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "Error updating order status",
          ),
        );
      }
    }
  }

  void _updateSingleOrderStatus(String orderId, String newStatus) {
    final currentState = state;
    if (currentState is CashierOrdersPageStateSuccess) {
      // Find and update the specific order
      final updatedOrders =
          currentState.cashierOrders.data.map((order) {
            if (order.subgroupIdentifier == orderId) {
              // Update the order status by creating a new order with modified status
              // We'll modify the order directly since there's no copyWith method
              order.orderStatus = newStatus;
              return order;
            }
            return order;
          }).toList();

      // Emit new state with updated orders, preserving all other fields
      emit(
        CashierOrdersPageStateSuccess(
          cashierOrders: CashierOrders(
            success: currentState.cashierOrders.success,
            count: currentState.cashierOrders.count,
            totalCount: currentState.cashierOrders.totalCount,
            pagination: currentState.cashierOrders.pagination,
            data: updatedOrders,
          ),
        ),
      );
    }
  }

  void clearOrders() async {
    try {
      final token1 = await PreferenceUtils.getDataFromShared("usertoken");

      final userId = UserController.userController.profile.id;
      final response = await serviceLocator.tradingApi.getCashierAssignedOrders(
        userId: userId,
        token: token1!,
      );

      // Update the count with current assigned orders
      if (response != null && response.statusCode == 200) {
        final CashierOrders cashierOrders = cashierOrdersFromJson(
          response.body,
        );
        _orderCount = cashierOrders.data.length;
      }
    } catch (e) {
      log('Error updating order count in clearOrders: $e');
    }

    // Emit state with updated count but empty list
    emit(
      CashierOrdersPageStateSuccess(
        cashierOrders: CashierOrders(
          success: true,
          count: _orderCount,
          totalCount: _orderCount,
          pagination: Pagination(
            currentPage: 1,
            totalPages: 1,
            totalItems: _orderCount,
            itemsPerPage: 10,
            hasNext: false,
            hasPrev: false,
          ),
          data: [], // Empty list
        ),
      ),
    );
  }
}
