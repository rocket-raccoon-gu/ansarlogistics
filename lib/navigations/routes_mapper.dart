part of 'navigation.dart';

Route<dynamic>? Function(RouteSettings settings) onGenerateAppRoute(
  RoutesFactory routesFactory,
) {
  return (RouteSettings settings) {
    switch (settings.name) {
      case _splash:
        return routesFactory.createSplashPageRoute();
      case _loginPageRouteName:
        return routesFactory.createLoginPageRoute();
      case _signupPageRouteName:
        final arg = settings.arguments as MapArguments;
        return routesFactory.createSignupPageRoute(arg.data);
      case _pickerDashBoardPageRouteName:
        return routesFactory.createPickerDashboardPageRoute();
      case _pickerOrderDetailsPageRouteName:
        final arg = settings.arguments as MapArguments;
        return routesFactory.createPickerOrderDetailsPageRoute(arg.data);
      case _orderItemDetailsPageRouteName:
        final arg = settings.arguments as MapArguments;
        return routesFactory.createOrderItemDetailsPageRoute(arg.data);
      case _orderItemReplacementPageRouteName:
        final arg = settings.arguments as MapArguments;
        return routesFactory.createOrderItemReplacementPageRoute(arg.data);
      case _orderitemAddPageRouteName:
        final arg = settings.arguments as MapArguments;
        return routesFactory.createOrderItemAddPageRoute(arg.data);
      case _driverDashBoardPageRouteName:
        return routesFactory.createDriverDashboardPageRoute();
      case _driverOrderInnerPageRouteName:
        final arg = settings.arguments as MapArguments;
        return routesFactory.createDriverOrderInnerPageRoute(arg.data);
      case _deliveryUpdatePageRouteName:
        final arg = settings.arguments as MapArguments;
        return routesFactory.createDeliveryUpdatePageRoute(arg.data);
      case _documentUploadPageRouteName:
        final arg = settings.arguments as MapArguments;
        return routesFactory.createDocumentUploadPageRoute(arg.data);
      case _viewOrderRoutePageRouteName:
        final arg = settings.arguments as MapArguments;
        return routesFactory.createViewOrderRoutePageRoute(arg.data);
      case _homeSectionInchargePageRouteName:
        return routesFactory.createHomeSectionInchargePageRoute();
      case _newScanBarcodePageRouteName:
        final arg = settings.arguments as MapArguments;
        return routesFactory.createNewScanBarcodePageRoute(arg.data);
      case _selectRegionsPageRouteName:
        return routesFactory.createSelectRegionsPageRoute();
      case _photographyDashBorardPageRouteName:
        return routesFactory.createPhotoGrpahyDashBoardPageRoute();
      case _salesStaffDashboardPageRouteName:
        return routesFactory.createSalesSectionDashBoardPageRoute();
      case _pickerOrderDetailsRouteName:
        final arg = settings.arguments as MapArguments;
        return routesFactory.createPickerOrderDetailsRoute(arg.data);
      case _cashierDashboardRouteName:
        return routesFactory.createCashierDashboardRoute();
      case _pickerDashboardRouteName:
        final arg = settings.arguments as MapArguments;
        return routesFactory.createPickerDashboardRoute(arg.data);
      default:
        return null;
    }
  };
}
