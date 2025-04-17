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

  List<Map<String, dynamic>> companylist = [];

  Future<void> loadpage() async {
    try {
      // First get the ID
      final response = await serviceLocator.tradingApi.getLastId();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final currentId = "0" + (data['last_id'] + 1).toString();

        // Then get company details
        final companyList = await getCompanyDetails();

        // Only emit when we have all data
        emit(
          SignupPageInitialState(
            companyList: companyList,
            currentId: currentId,
          ),
        );
      } else {
        emit(SignupPageErrorState("Error generating Id"));
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(errorMessage: "Error generating Id"),
        );
      }
    } catch (e) {
      emit(SignupPageErrorState(e.toString()));
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(errorMessage: e.toString()),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getCompanyDetails() async {
    try {
      final response = await serviceLocator.tradingApi.getCompanyList();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return []; // Return empty list if no data
    } catch (e) {
      emit(SignupPageErrorState("Error loading companies"));
      return [];
    }
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
 
    // getCompanyDetails() async {
  //   final companyresp = await serviceLocator.tradingApi.getCompanyList();

  //   if (companyresp.statusCode == 200) {
  //     Map<String, dynamic> data = jsonDecode(companyresp.body);

  //     if (data['data'].isNotEmpty) {
  //       companylist = List<Map<String, dynamic>>.from(data['data']);
  //     }
  //   }

  //   log(companylist.toString());
  // }
// }
