part of 'navigation.dart';

class NavigationService {
  Future<void> openSplashPage(BuildContext context) {
    return Navigator.of(context).pushNamed(_splash);
  }

  Future<void> openLoginPage(BuildContext context) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
      _loginPageRouteName,
      (Route<dynamic> route) => false,
    );
  }

  Future<void> openSignupPage(
    BuildContext context, {
    Map<String, dynamic>? arg,
  }) {
    return Navigator.of(
      context,
    ).pushNamed(_signupPageRouteName, arguments: MapArguments(arg!));
  }

  Future<void> openPickerWorkspacePage(BuildContext context) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
      _pickerDashBoardPageRouteName,
      (Route<dynamic> route) => false,
    );
  }

  Future<void> openSectionInChargePage(BuildContext context) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
      _homeSectionInchargePageRouteName,
      (Route<dynamic> route) => false,
    );
  }

  Future<void> openPhotoGrpahyDashboard(BuildContext context) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
      _photographyDashBorardPageRouteName,
      (Route<dynamic> route) => false,
    );
  }

  Future<void> openSalesDashboard(BuildContext context) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
      _salesStaffDashboardPageRouteName,
      (Route<dynamic> route) => false,
    );
  }

  dynamic back(BuildContext context, {Map<String, dynamic>? arg}) {
    return Navigator.pop(context, arg);
  }

  Future<void> openPickerOrderInnerPage(
    BuildContext context, {
    Map<String, dynamic>? arg,
  }) {
    // print("📦 Navigating to PickerOrderDetails page...");

    if (arg == null) {
      // print("❌ Error: 'arg' is null. Cannot proceed to navigation.");
      return Future.value(); // Prevent crash by returning early
    }

    // print("✅ Navigation arguments: $arg");
    // print("➡️ Route: $_pickerOrderDetailsPageRouteName");

    return Navigator.of(
      context,
    ).pushNamed(_pickerOrderDetailsPageRouteName, arguments: MapArguments(arg));
  }

  Future<void> openOrderItemDetailsPage(
    BuildContext context, {
    Map<String, dynamic>? arg,
  }) {
    return Navigator.of(
      context,
    ).pushNamed(_orderItemDetailsPageRouteName, arguments: MapArguments(arg!));
  }

  Future<void> openOrderItemReplacementPage(
    BuildContext context, {
    Map<String, dynamic>? arg,
  }) {
    return Navigator.of(context).pushNamed(
      _orderItemReplacementPageRouteName,
      arguments: MapArguments(arg!),
    );
  }

  Future<void> openOrderItemAddPage(
    BuildContext context, {
    Map<String, dynamic>? arg,
  }) {
    return Navigator.of(
      context,
    ).pushNamed(_orderitemAddPageRouteName, arguments: MapArguments(arg!));
  }

  Future<void> openDriverDashBoardPage(BuildContext context) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
      _driverDashBoardPageRouteName,
      (Route<dynamic> route) => false,
    );
  }

  Future<void> openDriverOrderInnerPage(
    BuildContext context, {
    Map<String, dynamic>? arg,
  }) {
    return Navigator.of(
      context,
    ).pushNamed(_driverOrderInnerPageRouteName, arguments: MapArguments(arg!));
  }

  Future<void> openDeliveryUpdatePage(
    BuildContext context, {
    Map<String, dynamic>? arg,
  }) {
    return Navigator.of(
      context,
    ).pushNamed(_deliveryUpdatePageRouteName, arguments: MapArguments(arg!));
  }

  Future<void> openDocumentUpdatePage(
    BuildContext context, {
    Map<String, dynamic>? arg,
  }) {
    return Navigator.of(
      context,
    ).pushNamed(_documentUploadPageRouteName, arguments: MapArguments(arg!));
  }

  Future<void> openOrderRoutesPage(
    BuildContext context, {
    Map<String, dynamic>? arg,
  }) {
    return Navigator.of(
      context,
    ).pushNamed(_viewOrderRoutePageRouteName, arguments: MapArguments(arg!));
  }

  Future<void> openNewScannerPage2(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    return Navigator.of(
      context,
    ).pushNamed(_newScanBarcodePageRouteName, arguments: MapArguments(data));
  }

  Future<void> openPickerOrderDetailsPage(
    BuildContext context, {
    Map<String, dynamic>? arg,
  }) {
    return Navigator.of(
      context,
    ).pushNamed(_pickerOrderDetailsRouteName, arguments: MapArguments(arg!));
  }

  Future<void> openCashierDashboardPage(BuildContext context) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
      _cashierDashboardRouteName,
      (Route<dynamic> route) => false,
    );
  }

  Future<void> openPickerDashboardPage(
    BuildContext context, {
    Map<String, dynamic>? arg,
  }) {
    return Navigator.of(
      context,
    ).pushNamed(_pickerDashboardRouteName, arguments: MapArguments(arg!));
  }

  // Future<void> openSelectRegionsPage(
  //   BuildContext context
  // ){
  //  return Navigator.of(context)
  // }
}
