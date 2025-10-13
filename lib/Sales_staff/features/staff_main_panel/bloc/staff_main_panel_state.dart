abstract class StaffMainPanelState {}

class StaffMainPanelInitialState extends StaffMainPanelState {}

class StaffMainPanelLoadingState extends StaffMainPanelState {}

class StaffMainPanelErrorState extends StaffMainPanelState {
  final String message;

  StaffMainPanelErrorState(this.message);
}

class StaffMainPanelSuccessState extends StaffMainPanelState {
  final Map<String, dynamic> data;

  StaffMainPanelSuccessState(this.data);
}
