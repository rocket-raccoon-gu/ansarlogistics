part of 'navigation.dart';

class MapArguments {
  final Map<String, dynamic> data;

  MapArguments(this.data);
}

swithcnavigate(BuildContext context, String role) {
  switch (role) {
    case "1":
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
    default:
      context.gNavigationService.openPickerWorkspacePage(context);
  }
}
