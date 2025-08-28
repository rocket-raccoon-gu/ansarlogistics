import 'package:equatable/equatable.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';

abstract class PickerOrderDetailsState extends Equatable {
  const PickerOrderDetailsState();

  @override
  List<Object?> get props => [];
}

class PickerOrderDetailsInitial extends PickerOrderDetailsState {}

class PickerOrderDetailsLoading extends PickerOrderDetailsState {}

class PickerOrderDetailsLoaded extends PickerOrderDetailsState {
  final OrderNew orderDetails;

  const PickerOrderDetailsLoaded(this.orderDetails);

  @override
  List<Object?> get props => [orderDetails];
}

class PickerOrderDetailsError extends PickerOrderDetailsState {
  final String message;

  const PickerOrderDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
