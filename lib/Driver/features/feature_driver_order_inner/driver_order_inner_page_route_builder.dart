import 'package:ansarlogistics/Driver/features/feature_driver_order_inner/bloc/driver_order_inner_page_cubit.dart';
import 'package:ansarlogistics/Driver/features/feature_driver_order_inner/driver_order_inner_page.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverOrderInnerPageRouteBuilder {
  final ServiceLocator serviceLocator;
  Map<String, dynamic> data;
  DriverOrderInnerPageRouteBuilder(this.serviceLocator, this.data);

  Widget call(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => DriverOrderInnerPageCubit(
                serviceLocator: serviceLocator,
                context: context,
                data: data,
              ),
        ),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: serviceLocator.navigationService),
          RepositoryProvider<CubitsLocator>.value(value: serviceLocator),
        ],
        child: DriverOrderInnerPage(
          orderResponseItem: data['orderitem'],
          serviceLocator: serviceLocator,
        ),
      ),
    );
  }
}
