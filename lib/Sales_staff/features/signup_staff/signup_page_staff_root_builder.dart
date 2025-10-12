import 'package:ansarlogistics/Sales_staff/features/signup_staff/cubit/signup_page_staff_cubit.dart';
import 'package:ansarlogistics/Sales_staff/features/signup_staff/signup_page_staff.dart';
import 'package:flutter/material.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupPageStaffRootBuilder {
  final ServiceLocator _serviceLocator;

  SignupPageStaffRootBuilder(this._serviceLocator);

  Widget call(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SignupPageStaffCubit(_serviceLocator),
        ),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: _serviceLocator.tradingApi),
        ],
        child: SignupPageStaff(),
      ),
    );
  }
}
