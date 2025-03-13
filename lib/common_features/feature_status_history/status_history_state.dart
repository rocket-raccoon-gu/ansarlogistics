import 'package:picker_driver_api/responses/status_history_response.dart';

abstract class StatusHistoryState {}

class StatusHistorystateInitial extends StatusHistoryState {
  List<StatusHistory> historylist = [];

  StatusHistorystateInitial(this.historylist);
}

class StatusHistoryStateLoading extends StatusHistoryState {}
