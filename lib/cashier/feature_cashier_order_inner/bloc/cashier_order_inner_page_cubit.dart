import 'package:ansarlogistics/cashier/feature_cashier_order_inner/bloc/cashier_order_inner_page_state.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/cashier_order_response.dart';

class CashierOrderInnerPageCubit extends Cubit<CashierOrderInnerPageState> {
  CashierOrderInnerPageCubit() : super(CashierOrderInnerPageStateLoading());

  ServiceLocator? _serviceLocator;

  void initialize({
    required ServiceLocator serviceLocator,
    required Datum initialOrder,
  }) {
    _serviceLocator = serviceLocator;
    emit(CashierOrderInnerPageStateLoaded(response: initialOrder));
  }

  Future<void> loadBySubgroupId(String subgroupId) async {
    if (_serviceLocator == null) return;
    emit(CashierOrderInnerPageStateLoading());
    try {
      final response = await _serviceLocator!.tradingApi.getCashierOrdersSearch(
        key: subgroupId,
        token: UserController.userController.app_token,
      );

      if (response == null ||
          !(response is dynamic && response.statusCode != null)) {
        emit(
          CashierOrderInnerPageStateError(message: 'Failed to search orders'),
        );
        return;
      }

      if (response.statusCode != 200) {
        emit(
          CashierOrderInnerPageStateError(
            message: response.body?.toString() ?? 'Unknown error',
          ),
        );
        return;
      }

      final CashierOrders result = cashierOrdersFromJson(response.body);

      Datum? found;
      // Prefer exact subgroup identifier match
      for (final d in result.data) {
        if (d.subgroupIdentifier == subgroupId) {
          found = d;
          break;
        }
      }
      // Fallback to first item if available
      found ??= result.data.isNotEmpty ? result.data.first : null;

      if (found == null) {
        emit(
          CashierOrderInnerPageStateError(
            message: 'Order not found for #$subgroupId',
          ),
        );
        return;
      }

      emit(CashierOrderInnerPageStateLoaded(response: found));
    } catch (e) {
      emit(CashierOrderInnerPageStateError(message: e.toString()));
    }
  }
}
