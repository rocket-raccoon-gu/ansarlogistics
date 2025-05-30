import 'package:ansarlogistics/Driver/features/feature_delivery_update/bloc/delivery_update_page_cubit.dart';
import 'package:ansarlogistics/Driver/features/feature_delivery_update/delivery_update_page.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeliveryUpdatePageRouteBuilder {
  final ServiceLocator serviceLocator;
  Map<String, dynamic> data;

  DeliveryUpdatePageRouteBuilder(this.serviceLocator, this.data);

  Widget call(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => DeliveryUpdatePageCubit(
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
        child: DeliveryUpdatePage(),
      ),
    );
  }
}
