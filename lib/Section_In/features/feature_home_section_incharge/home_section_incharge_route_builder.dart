import 'package:ansarlogistics/Section_In/features/feature_home_section_incharge/bloc/home_section_incharge_cubit.dart';
import 'package:ansarlogistics/Section_In/features/feature_home_section_incharge/home_section_incharge.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeSectionInchargeRootBuilder {
  final ServiceLocator _serviceLocator;

  HomeSectionInchargeRootBuilder(this._serviceLocator);

  Widget call(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => HomeSectionInchargeCubit(_serviceLocator, context),
        ),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: _serviceLocator.tradingApi),
        ],
        child: HomeSectionIncharge(),
      ),
    );
  }
}
