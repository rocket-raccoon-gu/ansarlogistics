import 'package:picker_driver_api/responses/orders_new_response.dart';

abstract class ItemBatchPickupState {}

class ItemBatchPickupInitialState extends ItemBatchPickupState {}

class ItemBatchPickupLoadingState extends ItemBatchPickupState {}

class ItemBatchPickupLoadedState extends ItemBatchPickupState {
  final GroupedProduct item;

  ItemBatchPickupLoadedState({required this.item});
}

class ItemBatchPickupErrorState extends ItemBatchPickupState {
  final String message;

  ItemBatchPickupErrorState(this.message);
}
