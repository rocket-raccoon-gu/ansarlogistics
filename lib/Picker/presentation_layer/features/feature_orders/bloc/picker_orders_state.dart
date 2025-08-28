import 'package:picker_driver_api/responses/order_response.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';

abstract class PickerOrdersState {}

class PickerOrdersInitialState extends PickerOrdersState {}

class PickerOrdersLoadingState extends PickerOrdersState {
  final List<OrderNew> oldpost;
  final bool isFirstFetch;
  PickerOrdersLoadingState(this.oldpost, {this.isFirstFetch = false});
}

class PickerOrdersLoadedState extends PickerOrdersState {
  final List<OrderNew> posts;
  PickerOrdersLoadedState(this.posts);
}

// New error state class
class PickerOrdersErrorState extends PickerOrdersState {
  final String message;

  PickerOrdersErrorState(this.message);

  @override
  List<Object> get props => [message];
}

// New states for non-paginated /ordersnew endpoint
class PickerOrdersNewLoadingState extends PickerOrdersState {}

class PickerOrdersNewLoadedState extends PickerOrdersState {
  final List<OrderNew> orders;
  final List<CategoryGroup> categories;
  PickerOrdersNewLoadedState({required this.orders, required this.categories});
}

class PickerOrdersNewErrorState extends PickerOrdersState {
  final String message;
  PickerOrdersNewErrorState(this.message);
}
