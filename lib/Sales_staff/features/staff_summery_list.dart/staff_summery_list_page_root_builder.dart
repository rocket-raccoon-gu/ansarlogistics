import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'staff_summery_list_page.dart';
import 'bloc/staff_summery_list_cubit.dart';

class StaffSummeryListPageRootBuilder {
  final ServiceLocator serviceLocator;

  StaffSummeryListPageRootBuilder({required this.serviceLocator});

  Widget call(BuildContext context) {
    return BlocProvider(
      create:
          (context) => StaffSummeryListCubit(
            serviceLocator: serviceLocator,
            context: context,
          ),
      child: RepositoryProvider(
        create:
            (context) =>
                RepositoryProvider.value(value: serviceLocator.tradingApi),
        child: StaffSummeryListPage(),
      ),
    );
  }
}
