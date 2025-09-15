import 'package:picker_driver_api/responses/order_report_response.dart';

abstract class DriverSummeryPageState {}

class DriverSummeryPageStateInitial extends DriverSummeryPageState {
  List<StatusHistory> statuslist = [];

  DriverSummeryPageStateInitial({required this.statuslist});
}

class DriverSummeryPageStateLoading extends DriverSummeryPageState {
  DriverSummeryPageStateLoading();
}
