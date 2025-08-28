import 'package:ansarlogistics/cashier/feature_cashier/bloc/cashier_orders_page_state.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/cashier_order_response.dart';

class CashierOrdersPageCubit extends Cubit<CashierOrdersPageState> {
  final ServiceLocator serviceLocator;
  final BuildContext context;
  CashierOrdersPageCubit({required this.serviceLocator, required this.context})
    : super(CashierOrdersPageStateInitial()) {
    loadOrders();
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
      if (response == null ||
          !(response is dynamic && response.statusCode != null)) {
        emit(CashierOrdersPageStateError(message: 'Failed to load orders'));
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
}
