import 'package:picker_driver_api/responses/orders_new_response.dart';

abstract class PickerDashboardTabState {}

class PickerDashboardTabInitial extends PickerDashboardTabState {}

class PickerDashboardTabLoading extends PickerDashboardTabState {}

class PickerDashboardTabLoadedState extends PickerDashboardTabState {
  final String suborderId; // exp/nol/...
  final String? preparationLabel; // e.g., PRNOL000098645
  final String? orderId; // fallback number
  final Map<String, List<OrderItemNew>> toPickByCategory;
  final Map<String, List<OrderItemNew>> pickedByCategory;
  final Map<String, List<OrderItemNew>> holdedByCategory;
  final Map<String, List<OrderItemNew>> notAvailableByCategory;

  PickerDashboardTabLoadedState({
    required this.suborderId,
    this.preparationLabel,
    this.orderId,
    required this.toPickByCategory,
    required this.pickedByCategory,
    required this.holdedByCategory,
    required this.notAvailableByCategory,
  });
}

class PickerDashboardTabErrorState extends PickerDashboardTabState {
  final String message;

  PickerDashboardTabErrorState({required this.message});
}
