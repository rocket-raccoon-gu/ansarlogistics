import 'dart:convert';
import 'dart:developer';

import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ansarlogistics/Sales_staff/features/signup_staff/cubit/signup_page_staff_state.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';

class SignupPageStaffCubit extends Cubit<SignupPageStaffState> {
  final ServiceLocator serviceLocator;
  SignupPageStaffCubit(this.serviceLocator) : super(SignupPageStaffInitial()) {
    loadpage();
  }

  final List<String> sections = <String>[
    "Grocery",
    "Confectionary",
    "Bakery",
    "Beverages",
    "Dairy",
    "Meat",
    "Seafood",
    "Fashion",
    "Footwear",
    "Jewelry",
    "Stationery",
    "Health & Beauty",
    "Home & Garden",
    "Sports & Fitness",
    "Toys & Games",
    "Beauty & Personal Care",
    "Electronics",
    "Furniture",
    "Home Decor",
    "Sanitary",
    "Tiles",
    "Settings",
  ];

  String currentid = "";

  Future<void> loadpage() async {
    try {
      // First get the ID
      final response = await serviceLocator.tradingApi.getLastId();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        currentid = "0" + (data['last_id'] + 1).toString();

        log(currentid);

        emit(SignupPageStaffSuccess());
      } else {
        emit(SignupPageStaffFailure(message: response.body));
      }
    } catch (e) {
      emit(SignupPageStaffFailure(message: e.toString()));
    }
  }

  void addSection(String name) {
    final n = name.trim();
    if (n.isEmpty) return;
    if (!sections.contains(n)) sections.add(n);
    emit(SignupPageStaffSuccess());
  }

  signup(Map<String, dynamic> data, BuildContext context) async {
    try {
      final response = await serviceLocator.tradingApi.setStaffRegister(
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
