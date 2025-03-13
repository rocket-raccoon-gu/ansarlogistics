import 'package:picker_driver_api/responses/login_response.dart';

abstract class ProfilePageState {}

class ProfilePageInitialState extends ProfilePageState {
  Profile profiledata;

  ProfilePageInitialState({required this.profiledata});
}

class ProfilePageLoadingState extends ProfilePageState {}
