import 'package:picker_driver_api/responses/product_response.dart';

abstract class ItemAddPageState {}

class ItemAddPageInitialState extends ItemAddPageState {
  ProductResponse? productResponse;

  ItemAddPageInitialState(this.productResponse);
}

class ItemAddPageStateLoading extends ItemAddPageState {}

class ItemAddPageErrorState extends ItemAddPageState {
  bool loading;
  ProductResponse? productResponse;

  ItemAddPageErrorState(this.loading, this.productResponse);
}
