import 'package:picker_driver_api/responses/driver_base_response.dart';

abstract class DriverOrdersPageState {}

class DriverPageInitialState extends DriverOrdersPageState {}

class DriverPageLoadingState extends DriverOrdersPageState {
  final List<DataItem> oldpost;
  final bool isFirstFetch;
  DriverPageLoadingState(this.oldpost, {this.isFirstFetch = false});
}

class DriverOrderSeekLoadingState extends DriverOrdersPageState {
  DriverOrderSeekLoadingState();
}

class DriverPageLoadedState extends DriverOrdersPageState {
  final List<DataItem> posts;
  DriverPageLoadedState(this.posts);
}

class DriverOrderErrorState extends DriverOrdersPageState {
  final String message;

  DriverOrderErrorState(this.message);

  @override
  List<Object> get props => [message];
}
