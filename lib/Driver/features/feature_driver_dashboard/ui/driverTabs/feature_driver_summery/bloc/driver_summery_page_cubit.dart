import 'package:ansarlogistics/Driver/features/feature_driver_dashboard/ui/driverTabs/feature_driver_summery/bloc/driver_summery_page_state.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverSummeryPageCubit extends Cubit<DriverSummeryPageState> {
  final ServiceLocator serviceLocator;
  // final PDApiGateway? pdApiGateway;
  BuildContext context;

  DriverSummeryPageCubit({required this.serviceLocator, required this.context})
    : super(DriverSummeryPageStateLoading()) {
    try {} catch (e) {}
  }

  getUpdatedData() {}
}
