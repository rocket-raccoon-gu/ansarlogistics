import 'package:ansarlogistics/common_features/feature_signup/bloc/signup_page_cubit.dart';
import 'package:ansarlogistics/common_features/feature_signup/signup_page.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupPageRouteBuilder {
  final ServiceLocator _serviceLocator;
  Map<String, dynamic> data;

  @override
  SignupPageRouteBuilder(this._serviceLocator, this.data);

  Widget call(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SignupPageCubit(context, _serviceLocator),
        ),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: _serviceLocator.tradingApi),
        ],
        child: SignupPage(),
      ),
    );
  }
}
