import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';
import 'picker_order_details_state.dart';

class PickerOrderDetailsInnerCubit extends Cubit<PickerOrderDetailsState> {
  final ServiceLocator serviceLocator;
  final OrderNew orderDetails;
  PickerOrderDetailsInnerCubit(this.serviceLocator, this.orderDetails)
    : super(PickerOrderDetailsInitial()) {
    loadOrderDetails();
  }

  void loadOrderDetails() async {
    emit(PickerOrderDetailsLoading());
    try {
      // Simulate a network call
      await Future.delayed(Duration(seconds: 2));
      // final orderDetails = OrderNew(); // Replace with actual data
      emit(PickerOrderDetailsLoaded(orderDetails));
    } catch (e) {
      emit(PickerOrderDetailsError("Failed to load order details"));
    }
  }
}
