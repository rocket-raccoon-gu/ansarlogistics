import 'package:picker_driver_api/responses/order_items_response.dart';
import 'package:picker_driver_api/responses/order_response.dart';

abstract class DriverOrderInnerPageState {}

class DriverOrderInitialPageState extends DriverOrderInnerPageState {
  List<EndPicking> assignedDriver = [];

  DriverOrderInitialPageState({required this.assignedDriver});
}

class DriverOrderLoadingPageState extends DriverOrderInnerPageState {}

class DriverOrderInitialErrorState extends DriverOrderInnerPageState {
  List<EndPicking> assignedDriver = [];

  DriverOrderInitialErrorState(this.assignedDriver);
}
