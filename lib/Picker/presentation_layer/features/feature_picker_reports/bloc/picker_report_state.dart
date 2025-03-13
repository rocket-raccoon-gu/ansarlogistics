import 'package:picker_driver_api/responses/order_report_response.dart';

abstract class PickerReportState {}

class PickerReportInitialState extends PickerReportState {
  List<StatusHistory> statuslist;

  PickerReportInitialState(this.statuslist);
}

class PickerReportLoadingState extends PickerReportState {
  PickerReportLoadingState();
}
