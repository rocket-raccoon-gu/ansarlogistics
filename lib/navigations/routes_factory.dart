part of 'navigation.dart';

abstract class RoutesFactory {
  Route<dynamic> createSplashPageRoute();
  Route<dynamic> createLoginPageRoute();
  Route<dynamic> createSignupPageRoute(Map<String, dynamic> data);
  Route<dynamic> createPickerDashboardPageRoute();
  Route<dynamic> createPickerOrderDetailsPageRoute(Map<String, dynamic> data);
  Route<dynamic> createOrderItemDetailsPageRoute(Map<String, dynamic> data);
  Route<dynamic> createOrderItemReplacementPageRoute(Map<String, dynamic> data);
  Route<dynamic> createOrderItemAddPageRoute(Map<String, dynamic> data);
  Route<dynamic> createDriverDashboardPageRoute();
  Route<dynamic> createDriverOrderInnerPageRoute(Map<String, dynamic> data);
  Route<dynamic> createDeliveryUpdatePageRoute(Map<String, dynamic> data);
  Route<dynamic> createDocumentUploadPageRoute(Map<String, dynamic> data);
  Route<dynamic> createViewOrderRoutePageRoute(Map<String, dynamic> dara);
  Route<dynamic> createHomeSectionInchargePageRoute();
  Route<dynamic> createHomeSectionPageRoute(Map<String, dynamic> dara);
  Route<dynamic> createNewScanBarcodePageRoute(Map<String, dynamic> data);
  Route<dynamic> createSelectRegionsPageRoute();
  Route<dynamic> createPhotoGrpahyDashBoardPageRoute();
  Route<dynamic> createSalesSectionDashBoardPageRoute();
  Route<dynamic> createPickerOrderDetailsRoute(Map<String, dynamic> data);
  Route<dynamic> createCashierDashboardRoute();
}
