import 'package:picker_driver_api/responses/order_report_response.dart';

abstract class DriverReportState {}

class DriverReportInitialState extends DriverReportState {
  List<Datum> statuslist;

  DriverReportInitialState(this.statuslist);
}

class DriverReportLoadingState extends DriverReportState {
  DriverReportLoadingState();
}
