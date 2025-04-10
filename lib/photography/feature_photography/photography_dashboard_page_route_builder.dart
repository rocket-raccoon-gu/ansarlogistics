import 'package:ansarlogistics/photography/feature_photography/bloc/photography_dashboard_cubit.dart';
import 'package:ansarlogistics/photography/feature_photography/photography_dashboard.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PhotographyDashboardPageRouteBuilder {
  final ServiceLocator serviceLocator;

  PhotographyDashboardPageRouteBuilder({required this.serviceLocator});

  Widget call(BuildContext contex) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => PhotographyDashboardCubit(
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
        child: PhotographyDashboard(serviceLocator: serviceLocator),
      ),
    );
  }
}
