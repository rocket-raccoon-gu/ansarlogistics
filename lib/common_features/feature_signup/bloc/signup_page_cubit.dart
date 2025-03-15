import 'dart:convert';
import 'dart:developer';

import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/common_features/feature_signup/bloc/signup_page_state.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupPageCubit extends Cubit<SignupPageState> {
  BuildContext context;
  final ServiceLocator serviceLocator;
  SignupPageCubit(this.context, this.serviceLocator)
    : super(SignupPageLoadingState()) {
    loadpage();
  }

  String currentid = "";

  loadpage() async {
    try {
      final response = await serviceLocator.tradingApi.getLastId();

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        currentid = "0" + (data['last_id'] + 1).toString();

        log(currentid.toString());
      } else {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(errorMessage: "Error generating Id"),
        );
      }
    } catch (e) {
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(errorMessage: e.toString()),
      );
    }

    emit(SignupPageInitialState());
  }

  signUpDriver(Map<String, dynamic> data) async {
    try {
      final response = await serviceLocator.tradingApi.setDriverRegister(
        driverdata: data,
      );

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        context.gNavigationService.openLoginPage(context);
        // ignore: use_build_context_synchronously
        showSnackBar(
          context: context,
          snackBar: showSuccessDialogue(message: "User Registered"),
        );
      } else {
        // ignore: use_build_context_synchronously
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "Registration Failed Try Again...!",
          ),
        );
      }
    } catch (e) {
      log("Driver Signup Failed...");

      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "User Signup Failed Try Again...!",
        ),
      );
    }
  }
}
