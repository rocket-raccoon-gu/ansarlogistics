import 'package:picker_driver_api/responses/order_response.dart';

abstract class PickerOrderDetailsState {}

class PickerOrderDetailsInitialState extends PickerOrderDetailsState {
  // List<OrderItem> topickItems = [];

  // List<OrderItem> pickedItems = [];

  // List<OrderItem> notfounditems = [];

  int tabindex;

  List<String> catlist = [];

  List<EndPicking> topickitems = [];

  List<EndPicking> pickeditems = [];

  List<EndPicking> notfounditems = [];

  List<EndPicking> canceleditems = [];

  PickerOrderDetailsInitialState(this.tabindex, this.catlist, this.topickitems,
      this.pickeditems, this.notfounditems, this.canceleditems);
}

class PickerOrderDetailsLoadingState extends PickerOrderDetailsState {
  final bool isFirstFetch;
  PickerOrderDetailsLoadingState({this.isFirstFetch = false});
}

class PickerOrderDetailsLoadedState extends PickerOrderDetailsState {
  PickerOrderDetailsLoadedState();
}

class PickerOrderDetailsErrorState extends PickerOrderDetailsState {
  PickerOrderDetailsErrorState();
}
