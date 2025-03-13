part of 'login_cubit.dart';

@immutable
abstract class LoginState {}

class LoginInitial extends LoginState {
  String errorMessage;
  final bool needOtp;
  final bool loading;
  LoginInitial(
      {this.errorMessage = "", this.loading = false, this.needOtp = false});

  LoginInitial copyWith({String? error, bool? loading, bool? otp}) {
    return LoginInitial(
        errorMessage: error ?? "",
        loading: loading ?? false,
        needOtp: otp ?? needOtp);
  }
}

class LoginLoading extends LoginState {}
