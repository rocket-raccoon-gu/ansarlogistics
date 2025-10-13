import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'staff_main_panel.dart';
import 'bloc/staff_main_panel_cubit.dart';

class StaffMainPanelRootBuilder {
  final ServiceLocator serviceLocator;

  StaffMainPanelRootBuilder({required this.serviceLocator});

  Widget call(BuildContext context) {
    return BlocProvider(
      create:
          (context) => StaffMainPanelCubit(
            serviceLocator: serviceLocator,
            context: context,
          ),
      child: RepositoryProvider(
        create:
            (context) =>
                RepositoryProvider.value(value: serviceLocator.tradingApi),
        child: StaffMainPanel(),
      ),
    );
  }
}
