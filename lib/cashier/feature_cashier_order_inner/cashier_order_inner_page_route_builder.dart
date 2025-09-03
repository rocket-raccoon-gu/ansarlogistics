import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ansarlogistics/cashier/feature_cashier_order_inner/cashier_order_inner_page.dart';
import 'package:ansarlogistics/cashier/feature_cashier_order_inner/bloc/cashier_order_inner_page_cubit.dart';
import 'package:ansarlogistics/services/service_locator.dart';

class CashierOrderInnerPageRouteBuilder {
  final ServiceLocator serviceLocator;
  final Map<String, dynamic> arguments;

  CashierOrderInnerPageRouteBuilder({
    required this.serviceLocator,
    required this.arguments,
  });

  Widget call(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CashierOrderInnerPageCubit()),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: serviceLocator.navigationService),
          RepositoryProvider<CubitsLocator>.value(value: serviceLocator),
        ],
        child: CashierOrderInnerPage(arguments: arguments),
      ),
    );
  }
}
