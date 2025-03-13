import 'package:picker_driver_api/responses/order_response.dart';

abstract class DriverOrdersPageState {}

class DriverPageInitialState extends DriverOrdersPageState {}

class DriverPageLoadingState extends DriverOrdersPageState {
  final List<Order> oldpost;
  final bool isFirstFetch;
  DriverPageLoadingState(this.oldpost, {this.isFirstFetch = false});
}

class DriverOrderSeekLoadingState extends DriverOrdersPageState {
  DriverOrderSeekLoadingState();
}

class DriverPageLoadedState extends DriverOrdersPageState {
  final List<Order> posts;
  DriverPageLoadedState(
    this.posts,
  );
}

class DriverOrderErrorState extends DriverOrdersPageState {
  final String message;

  DriverOrderErrorState(this.message);

  @override
  List<Object> get props => [message];
}
