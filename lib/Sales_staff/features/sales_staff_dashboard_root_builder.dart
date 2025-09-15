import 'package:ansarlogistics/Sales_staff/features/bloc/sales_staff_dashboard_cubit.dart';
import 'package:ansarlogistics/Sales_staff/features/sales_staff_dashboard.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SalesStaffDashboardRootBuilder {
  final ServiceLocator serviceLocator;

  SalesStaffDashboardRootBuilder(this.serviceLocator);

  Widget call(BuildContext context) {
    return BlocProvider(
      create:
          (context) => SalesStaffDashboardCubit(
            serviceLocator: this.serviceLocator,
            context: context,
          ),
      child: RepositoryProvider(
        create:
            (context) =>
                RepositoryProvider.value(value: serviceLocator.tradingApi),
        child: SalesStaffDashboard(),
      ),
    );
  }
}
