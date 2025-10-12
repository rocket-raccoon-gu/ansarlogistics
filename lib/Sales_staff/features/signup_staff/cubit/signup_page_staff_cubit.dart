import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ansarlogistics/Sales_staff/features/signup_staff/cubit/signup_page_staff_state.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';

class SignupPageStaffCubit extends Cubit<SignupPageStaffState> {
  final ServiceLocator _serviceLocator;
  SignupPageStaffCubit(this._serviceLocator) : super(SignupPageStaffInitial()) {
    loadpage();
  }

  final List<String> sections = <String>[];

  void loadpage() {
    emit(SignupPageStaffSuccess());
  }

  void addSection(String name) {
    final n = name.trim();
    if (n.isEmpty) return;
    if (!sections.contains(n)) sections.add(n);
    emit(SignupPageStaffSuccess());
  }

  signup(Map<String, dynamic> data, BuildContext context) async {
    try {
      final response = await _serviceLocator.tradingApi.setStaffRegister(
        staffdata: data,
      );
      if (response.statusCode == 200) {
        context.gNavigationService.openLoginPage(context);

        emit(SignupPageStaffSuccess());
      } else {
        emit(SignupPageStaffFailure(message: response.body));
      }
    } catch (e) {
      emit(SignupPageStaffFailure(message: e.toString()));
    }
  }
}
