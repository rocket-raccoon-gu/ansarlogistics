import 'package:picker_driver_api/responses/order_response.dart';

abstract class PickerOrdersState {}

class PickerOrdersInitialState extends PickerOrdersState {}

class PickerOrdersLoadingState extends PickerOrdersState {
  final List<Order> oldpost;
  final bool isFirstFetch;
  PickerOrdersLoadingState(this.oldpost, {this.isFirstFetch = false});
}

class PickerOrdersLoadedState extends PickerOrdersState {
  final List<Order> posts;
  PickerOrdersLoadedState(
    this.posts,
  );
}

// New error state class
class PickerOrdersErrorState extends PickerOrdersState {
  final String message;

  PickerOrdersErrorState(this.message);

  @override
  List<Object> get props => [message];
}
