import 'package:picker_driver_api/responses/cashier_order_response.dart';

abstract class CashierOrdersPageState {}

class CashierOrdersPageStateInitial extends CashierOrdersPageState {}

class CashierOrdersPageStateLoading extends CashierOrdersPageState {}

class CashierOrdersPageStateSuccess extends CashierOrdersPageState {
  final CashierOrders cashierOrders;
  final bool isLoadingMore;

  CashierOrdersPageStateSuccess({
    required this.cashierOrders,
    this.isLoadingMore = false,
  });
}

class CashierOrdersPageStateError extends CashierOrdersPageState {
  final String message;

  CashierOrdersPageStateError({required this.message});
}
