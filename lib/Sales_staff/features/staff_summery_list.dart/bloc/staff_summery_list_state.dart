abstract class StaffSummeryListState {}

class StaffSummeryListInitialState extends StaffSummeryListState {}

class StaffSummeryListLoadingState extends StaffSummeryListState {}

class StaffSummeryListErrorState extends StaffSummeryListState {
  final String message;

  StaffSummeryListErrorState(this.message);
}

class StaffSummeryListSuccessState extends StaffSummeryListState {
  final List<Map<String, dynamic>> data;
  final Map<String, dynamic> summary;

  StaffSummeryListSuccessState({required this.data, required this.summary});
}
