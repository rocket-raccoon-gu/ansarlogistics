import 'package:picker_driver_api/responses/erp_data_response.dart';
import 'package:picker_driver_api/responses/product_bd_data_response.dart';
import 'package:picker_driver_api/responses/product_response.dart';

abstract class ItemAddPageState {}

class ItemAddPageInitialState extends ItemAddPageState {
  ErPdata? erPdata;
  ProductDBdata? productDBdata;
  double? specialPrice;

  ItemAddPageInitialState(this.erPdata, this.productDBdata, this.specialPrice);
}

class ItemAddPageStateLoading extends ItemAddPageState {}

class ItemAddPageErrorState extends ItemAddPageState {
  bool loading;
  ErPdata? erPdata;
  ProductDBdata? productDBdata;
  double? specialPrice;

  ItemAddPageErrorState(
    this.loading,
    this.erPdata,
    this.productDBdata,
    this.specialPrice,
  );
}

class ItemAddFormState extends ItemAddPageState {}

class MobileScannerState1 extends ItemAddPageState {}
