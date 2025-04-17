abstract class SignupPageState {}

class SignupPageLoadingState extends SignupPageState {}

class SignupPageInitialState extends SignupPageState {
  final List<Map<String, dynamic>> companyList;
  final String currentId;

  SignupPageInitialState({required this.companyList, required this.currentId});
}

class SignupPageErrorState extends SignupPageState {
  final String message;

  SignupPageErrorState(this.message);
}
