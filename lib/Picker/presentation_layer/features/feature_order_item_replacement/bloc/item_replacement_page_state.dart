import 'package:picker_driver_api/responses/order_response.dart';
import 'package:picker_driver_api/responses/similiar_item_response.dart';
import 'package:picker_driver_api/responses/product_response.dart';

abstract class ItemReplacementPageState {}

class ItemReplacementInitail extends ItemReplacementPageState {
  EndPicking? itemdata;
  List<SimiliarItems> replacements = [];
  ProductResponse? prwork;
  bool loading = true;
  ItemReplacementInitail(
      {required this.itemdata,
      required this.replacements,
      required this.prwork,
      required this.loading});
}

class ItemReplacementLoading extends ItemReplacementPageState {}

class ItemLoading extends ItemReplacementPageState {}
