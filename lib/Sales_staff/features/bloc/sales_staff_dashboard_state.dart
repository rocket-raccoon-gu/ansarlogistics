abstract class SalesStaffDashboardState {}

class SalesStaffDashboardInitialState extends SalesStaffDashboardState {}

class SalesStaffDashboardloadingState extends SalesStaffDashboardState {}

class SalesStaffBarcodeCheckSuccess extends SalesStaffDashboardState {
  final String erpSku;
  final String? discountPerc;
  SalesStaffBarcodeCheckSuccess({required this.erpSku, this.discountPerc});
}

class SalesStaffBarcodeCheckNotFound extends SalesStaffDashboardState {
  final String scannedSku;
  SalesStaffBarcodeCheckNotFound({required this.scannedSku});
}
