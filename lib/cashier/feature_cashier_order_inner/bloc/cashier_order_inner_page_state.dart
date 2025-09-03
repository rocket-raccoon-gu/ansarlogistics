import 'package:picker_driver_api/responses/cashier_order_response.dart';

abstract class CashierOrderInnerPageState {}

class CashierOrderInnerPageStateLoading extends CashierOrderInnerPageState {}

class CashierOrderInnerPageStateLoaded extends CashierOrderInnerPageState {
  final Datum response;
  CashierOrderInnerPageStateLoaded({required this.response});
}

class CashierOrderInnerPageStateError extends CashierOrderInnerPageState {
  final String message;
  CashierOrderInnerPageStateError({required this.message});
}
