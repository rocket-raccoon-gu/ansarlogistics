import 'package:picker_driver_api/responses/order_response.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';

abstract class OrderItemDetailsState {}

class OrderItemDetailInitialState extends OrderItemDetailsState {
  EndPicking orderItem;
  OrderItemDetailInitialState({required this.orderItem});
}

class OrderItemDetailInitialNewState extends OrderItemDetailsState {
  final OrderItemNew orderItem;
  OrderItemDetailInitialNewState({required this.orderItem});
}

class OrderItemDetailErrorState extends OrderItemDetailsState {
  bool loading;
  EndPicking orderItem;
  OrderItemDetailErrorState({required this.loading, required this.orderItem});
}

class OrderItemDetailLoadingState extends OrderItemDetailsState {}
