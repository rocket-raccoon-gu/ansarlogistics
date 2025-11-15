// import 'package:ansarlogistics/Driver/features/feature_delivery_update/delivery_update_page_route_builder.dart';
// import 'package:ansarlogistics/Driver/features/feature_document_upload/document_upload_page_route_builder.dart';
// import 'package:ansarlogistics/Driver/features/feature_driver_dashboard/driver_dashboard_page_route_builder.dart';
// import 'package:ansarlogistics/Driver/features/feature_driver_order_inner/driver_order_inner_page_route_builder.dart';
// import 'package:ansarlogistics/Driver/features/feature_order_routes/order_routes_route_builder.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_batch_picking/item_batch_pickup_root_builder.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_item_add/item_add_page_route_builder.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_inner/order_item_inner_route_builder.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_replacement/item_replacement_page_route_builder.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_dashboard/picker_dashboard_page_route_builder.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_details/picker_order_details_page_route_builder.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/picker_order_details_page_route_builder.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_tabs/picker_tab_dashboard_root_builder.dart';
import 'package:ansarlogistics/Sales_staff/features/sales_staff_dashboard_root_builder.dart';
import 'package:ansarlogistics/Section_In/features/feature_home_section_incharge/home_section_incharge_route_builder.dart';
// import 'package:ansarlogistics/Sales_staff/features/sales_staff_dashboard_root_builder.dart';
// import 'package:ansarlogistics/Section_In/features/feature_home_section_incharge/home_section_incharge_route_builder.dart';
import 'package:ansarlogistics/cashier/feature_cashier/cashier_order_page_route_builder.dart';
import 'package:ansarlogistics/cashier/feature_cashier_order_inner/cashier_order_inner_page_route_builder.dart';
import 'package:ansarlogistics/common_features/feature_login/login_page_route_builder.dart';
import 'package:ansarlogistics/common_features/feature_scan_barcode/new_scan_page_route_builder.dart';
import 'package:ansarlogistics/common_features/feature_select_region/select_region_root_builder.dart';
import 'package:ansarlogistics/common_features/feature_signup/signup_page_routebuilder.dart';
import 'package:ansarlogistics/common_features/feature_splash/splash_route_builder.dart';
import 'package:ansarlogistics/navigations/navigation.dart';
// import 'package:ansarlogistics/photography/feature_photography/photography_dashboard_page_route_builder.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';

class AppRoutesFactory extends RoutesFactory {
  final ServiceLocator _serviceLocator;

  AppRoutesFactory(this._serviceLocator);

  @override
  Route createSplashPageRoute() {
    // TODO: implement createSplashPageRoute
    return CustomRoute(builder: SplashRouteBuilder());
  }

  @override
  Route createLoginPageRoute() {
    // TODO: implement createLoginPageRoute
    return CustomRoute(builder: LoginPageRouteBuilder(_serviceLocator));
  }

  @override
  Route createPickerDashboardPageRoute() {
    // TODO: implement createPickerDashboardPageRoute
    return CustomRoute(
      builder: PickerDashboardPageRouteBuilder(_serviceLocator),
    );
  }

  // @override
  // Route createHomeSectionInchargePageRoute() {
  //   // TODO: implement createHomeSectionInchargePageRoute
  //   return CustomRoute(
  //     builder: HomeSectionInchargeRootBuilder(_serviceLocator),
  //   );
  // }

  @override
  Route createPickerOrderDetailsPageRoute(Map<String, dynamic> data) {
    // TODO: implement createPickerOrderDetailsPageRoute
    return CustomRoute(
      builder: PickerOrderDetailsPageRouteBuilder(_serviceLocator, data),
    );
  }

  @override
  Route createOrderItemDetailsPageRoute(Map<String, dynamic> data) {
    // TODO: implement createOrderItemDetailsPageRoute
    return CustomRoute(
      builder: OrderItemInnerRouteBuilder(
        serviceLocator: _serviceLocator,
        data: data,
      ),
    );
  }

  @override
  Route createOrderItemReplacementPageRoute(Map<String, dynamic> data) {
    // TODO: implement createOrderItemReplacementPageRoute
    return CustomRoute(
      builder: ItemReplacementPageRouteBuilder(_serviceLocator, data),
    );
  }

  @override
  Route createOrderItemAddPageRoute(Map<String, dynamic> data) {
    // TODO: implement createOrderItemAddPageRoute
    return CustomRoute(
      builder: ItemAddPageRouteBuilder(
        serviceLocator: _serviceLocator,
        data: data,
      ),
    );
  }

  // @override
  // @override
  // Route createDriverDashboardPageRoute() {
  //   // TODO: implement createDriverDashboardPageRoute
  //   return CustomRoute(
  //     builder: DriverDashboardPageRouteBuilder(_serviceLocator),
  //   );
  // }

  // @override
  // Route createDriverOrderInnerPageRoute(Map<String, dynamic> data) {
  //   // TODO: implement createDriverOrderInnerPageRoute
  //   return CustomRoute(
  //     builder: DriverOrderInnerPageRouteBuilder(_serviceLocator, data),
  //   );
  // }

  // @override
  // Route createDeliveryUpdatePageRoute(Map<String, dynamic> data) {
  //   // TODO: implement createDeliveryUpdatePageRoute
  //   return CustomRoute(
  //     builder: DeliveryUpdatePageRouteBuilder(_serviceLocator, data),
  //   );
  // }

  @override
  // Route createDocumentUploadPageRoute(Map<String, dynamic> data) {
  //   // TODO: implement createDocumentUploadPageRoute
  //   return CustomRoute(
  //     builder: DocumentUploadPageRouteBuilder(_serviceLocator, data),
  //   );
  // }
  // @override
  // Route createViewOrderRoutePageRoute(Map<String, dynamic> data) {
  //   // TODO: implement createViewOrderRoutePageRoute
  //   return CustomRoute(builder: OrderRoutesRouteBuilder(_serviceLocator, data));
  // }
  @override
  Route createHomeSectionPageRoute(Map<String, dynamic> dara) {
    // TODO: implement createHomeSectionPageRoute
    return CustomRoute(
      builder: HomeSectionInchargeRootBuilder(_serviceLocator),
    );
  }

  @override
  Route createSignupPageRoute(Map<String, dynamic> data) {
    // TODO: implement createSignupPageRoute
    return CustomRoute(builder: SignupPageRouteBuilder(_serviceLocator, data));
  }

  @override
  Route createNewScanBarcodePageRoute(Map<String, dynamic> data) {
    // TODO: implement createNewScanBarcodePageRoute
    return CustomRoute(builder: NewScanPageRouteBuilder(_serviceLocator, data));
  }

  @override
  Route createSelectRegionsPageRoute() {
    // TODO: implement createSelectRegionsPageRoute
    return CustomRoute(builder: SelectRegionRootBuilder(_serviceLocator));
  }

  // @override
  // Route createPhotoGrpahyDashBoardPageRoute() {
  //   // TODO: implement createPhotoGrpahyDashBoardPageRoute
  //   return CustomRoute(
  //     builder: PhotographyDashboardPageRouteBuilder(
  //       serviceLocator: _serviceLocator,
  //     ),
  //   );
  // }

  @override
  Route createSalesSectionDashBoardPageRoute() {
    return CustomRoute(
      builder: SalesStaffDashboardRootBuilder(_serviceLocator),
    );
  }

  // @override
  // Route createSalesSectionDashBoardPageRoute() {
  //   // TODO: implement createSalesSectionDashBoardPageRoute
  //   return CustomRoute(
  //     builder: SalesStaffDashboardRootBuilder(_serviceLocator),
  //   );
  // }

  @override
  Route createPickerOrderDetailsRoute(Map<String, dynamic> data) {
    // TODO: implement createPickerOrderDetailsRoute
    return CustomRoute(
      builder: PickerOrderDetailsInnerPageRouteBuilder(
        _serviceLocator,
        arguments: data,
      ),
    );
  }

  @override
  Route createCashierDashboardRoute() {
    // TODO: implement createCashierDashboardRoute
    return CustomRoute(
      builder: CashierOrderPageRouteBuilder(serviceLocator: _serviceLocator),
    );
  }

  @override
  Route createPickerDashboardRoute(Map<String, dynamic> data) {
    // TODO: implement createPickerDashboardRoute
    return CustomRoute(
      builder: PickerTabDashboardRootBuilder(_serviceLocator, data),
    );
  }

  @override
  Route createCashierOrderInnerPageRoute(Map<String, dynamic> data) {
    // TODO: implement createCashierOrderInnerPageRoute
    return CustomRoute(
      builder: CashierOrderInnerPageRouteBuilder(
        serviceLocator: _serviceLocator,
        arguments: data,
      ),
    );
  }

  @override
  Route createItemBatchPickupRoute(Map<String, dynamic> data) {
    // TODO: implement createItemBatchPickupRoute
    return CustomRoute(
      builder: ItemBatchPickupRootBuilder(_serviceLocator, data),
    );
  }

  @override
  Route createHomeSectionInchargePageRoute() {
    // TODO: implement createHomeSectionInchargePageRoute
    return CustomRoute(
      builder: HomeSectionInchargeRootBuilder(_serviceLocator),
    );
  }
}

class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({required WidgetBuilder builder}) : super(builder: builder);
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      transformHitTests: false,
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          reverseCurve: Curves.easeOut,
          parent: animation,
          curve: Curves.ease,
        ),
      ),
      child: child,
    );
  }
}
