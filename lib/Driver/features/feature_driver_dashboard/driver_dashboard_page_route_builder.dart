import 'package:ansarlogistics/Driver/features/feature_driver_dashboard/driver_dashboard_page.dart';
import 'package:ansarlogistics/common_features/feature_profile/bloc/profile_page_cubit.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverDashboardPageRouteBuilder {
  final ServiceLocator serviceLocator;
  DriverDashboardPageRouteBuilder(this.serviceLocator);

  Widget call(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => ProfilePageCubit(
                serviceLocator: serviceLocator,
                context: context,
              ),
        ),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: serviceLocator.navigationService),
          RepositoryProvider<CubitsLocator>.value(value: serviceLocator),
        ],
        child: DriverDashboardPage(serviceLocator: serviceLocator),
      ),
    );
  }
}
