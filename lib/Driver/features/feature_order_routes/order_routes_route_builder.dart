import 'package:ansarlogistics/Driver/features/feature_order_routes/bloc/order_routes_page_cubit.dart';
import 'package:ansarlogistics/Driver/features/feature_order_routes/order_routes_page.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderRoutesRouteBuilder {
  final ServiceLocator serviceLocator;
  Map<String, dynamic> data;

  OrderRoutesRouteBuilder(this.serviceLocator, this.data);

  Widget call(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => OrderRoutesPageCubit(context, data)),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: serviceLocator.navigationService),
          RepositoryProvider<CubitsLocator>.value(value: serviceLocator),
        ],
        child: OrderRoutesPage(mapdate: data),
      ),
    );
  }
}
