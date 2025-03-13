import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_dashboard/picker_dashboard_page.dart';
import 'package:ansarlogistics/common_features/feature_profile/bloc/profile_page_cubit.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PickerDashboardPageRouteBuilder {
  final ServiceLocator _serviceLocator;
  PickerDashboardPageRouteBuilder(this._serviceLocator);

  Widget call(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => ProfilePageCubit(
                serviceLocator: _serviceLocator,
                context: context,
              ),
        ),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: _serviceLocator.navigationService),
          RepositoryProvider<CubitsLocator>.value(value: _serviceLocator),
        ],
        child: PickerDashboardPage(serviceLocator: _serviceLocator),
      ),
    );
  }
}
