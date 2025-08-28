part of 'navigation.dart';

class MapArguments {
  final Map<String, dynamic> data;

  MapArguments(this.data);
}

swithcnavigate(BuildContext context, String role) {
  switch (role) {
    case "1":
    case "4":
      context.gNavigationService.openPickerWorkspacePage(context);
      break;
    case "2":
    case "3":
      context.gNavigationService.openDriverDashBoardPage(context);
      break;
    case "5":
      context.gNavigationService.openPhotoGrpahyDashboard(context);
      break;
    case "6":
      context.gNavigationService.openSectionInChargePage(context);
      break;
    case "7":
      context.gNavigationService.openSalesDashboard(context);
      break;
    case "8":
      context.gNavigationService.openCashierDashboardPage(context);
      break;
    default:
      context.gNavigationService.openPickerWorkspacePage(context);
  }
}
