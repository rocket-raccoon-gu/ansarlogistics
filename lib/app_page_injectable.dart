import 'package:ansarlogistics/navigations/navigation.dart';
import 'package:ansarlogistics/services/api_gateway.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

extension AppPageInjectable on BuildContext {
  NavigationService get gNavigationService =>
      read<ServiceLocator>().navigationService;

  PDApiGateway get gTradingApiGateway => read<ServiceLocator>().tradingApi;

  void resetCubits() {
    read<ServiceLocator>().resetCubits();
  }
}
