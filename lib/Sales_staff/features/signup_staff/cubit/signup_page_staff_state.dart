abstract class SignupPageStaffState {}

class SignupPageStaffInitial extends SignupPageStaffState {}

class SignupPageStaffLoading extends SignupPageStaffState {}

class SignupPageStaffSuccess extends SignupPageStaffState {
  SignupPageStaffSuccess();
}

class SignupPageStaffFailure extends SignupPageStaffState {
  final String message;

  SignupPageStaffFailure({required this.message});
}
