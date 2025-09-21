import 'dart:async';

import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_tabs/bloc/picker_dashboard_tab_state.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';

class PickerDashboardTabCubit extends Cubit<PickerDashboardTabState> {
  final String suborderId; // exp/nol/... selected type
  final List<OrderItemNew> allItems; // items from order details page
  final String? preparationLabel; // e.g., PRNOL000098645
  final String? orderId; // fallback number for title
  final ServiceLocator serviceLocator;

  PickerDashboardTabCubit({
    required this.suborderId,
    required this.allItems,
    this.preparationLabel,
    this.orderId,
    required this.serviceLocator,
  }) : super(PickerDashboardTabInitial()) {
    _load();
  }

  Future<void> _load() async {
    emit(PickerDashboardTabLoading());
    try {
      // Filter items for selected delivery type
      final filtered =
          allItems
              .where((e) => (e.deliveryType ?? '').toLowerCase() == suborderId)
              .toList();

      // Buckets by status
      final toPick =
          filtered.where((e) {
            final st = (e.itemStatus ?? '').toLowerCase();
            return st == 'assigned_picker' ||
                st == 'start_picking' ||
                st == 'material_request';
          }).toList();

      final picked =
          filtered
              .where((e) => (e.itemStatus ?? '').toLowerCase() == 'end_picking')
              .toList();

      final holded =
          filtered
              .where((e) => (e.itemStatus ?? '').toLowerCase() == 'holded')
              .toList();

      final notAvailable =
          filtered
              .where(
                (e) =>
                    (e.itemStatus ?? '').toLowerCase() == 'item_not_available',
              )
              .toList();

      emit(
        PickerDashboardTabLoadedState(
          suborderId: suborderId,
          preparationLabel: preparationLabel,
          orderId: orderId,
          toPickByCategory: _groupByCategory(toPick),
          pickedByCategory: _groupByCategory(picked),
          holdedByCategory: _groupByCategory(holded),
          notAvailableByCategory: _groupByCategory(notAvailable),
        ),
      );
    } catch (_) {
      emit(PickerDashboardTabErrorState(message: 'Unexpected error'));
    }
  }

  // Public method to recompute groups when underlying items mutate
  void refresh() {
    _load();
  }

  // Update a specific item's status and recompute
  void setItemStatus(String itemId, String newStatus) {
    final idx = allItems.indexWhere((e) => (e.id ?? '') == itemId);
    if (idx != -1) {
      final current = allItems[idx];
      allItems[idx] = _cloneWithStatus(current, newStatus);
      _load();
    }
  }

  // Update a specific item's status and optionally price and picked quantity, then recompute
  void setItemStatusAndData(
    String itemId,
    String newStatus, {
    String? newPrice,
    int? pickedQty,
  }) {
    final idx = allItems.indexWhere((e) => (e.id ?? '') == itemId);
    if (idx != -1) {
      final current = allItems[idx];
      allItems[idx] = _cloneWithUpdates(
        current,
        status: newStatus,
        price: newPrice,
        qtyShipped: pickedQty,
      );
      _load();
    }
  }

  OrderItemNew _cloneWithStatus(OrderItemNew src, String status) {
    return OrderItemNew(
      id: src.id,
      name: src.name,
      sku: src.sku,
      price: src.price,
      qtyOrdered: src.qtyOrdered,
      qtyShipped: src.qtyShipped,
      categoryId: src.categoryId,
      categoryName: src.categoryName,
      imageUrl: src.imageUrl,
      deliveryType: src.deliveryType,
      itemStatus: status,
      rowTotal: src.rowTotal,
      rowTotalInclTax: src.rowTotalInclTax,
      productImage: src.productImage,
      isProduce: src.isProduce,
      subgroupIdentifier: src.subgroupIdentifier,
    );
  }

  // Clone helper that allows updating multiple fields
  OrderItemNew _cloneWithUpdates(
    OrderItemNew src, {
    String? status,
    String? price,
    int? qtyShipped,
  }) {
    return OrderItemNew(
      id: src.id,
      name: src.name,
      sku: src.sku,
      price: price ?? src.price,
      qtyOrdered: src.qtyOrdered,
      qtyShipped: qtyShipped ?? src.qtyShipped,
      categoryId: src.categoryId,
      categoryName: src.categoryName,
      imageUrl: src.imageUrl,
      deliveryType: src.deliveryType,
      itemStatus: status ?? src.itemStatus,
      rowTotal: src.rowTotal,
      rowTotalInclTax: src.rowTotalInclTax,
      productImage: src.productImage,
      isProduce: src.isProduce,
      subgroupIdentifier: src.subgroupIdentifier,
    );
  }

  Map<String, List<OrderItemNew>> _groupByCategory(List<OrderItemNew> list) {
    final map = <String, List<OrderItemNew>>{};
    for (final item in list) {
      final key =
          (item.categoryName ?? '').isNotEmpty ? item.categoryName! : 'Others';
      (map[key] ??= <OrderItemNew>[]).add(item);
    }
    return map;
  }

  updateOrderStatus({
    required String suborderId,
    required String preparationLabel,
    required String comment,
    required String status,
    required BuildContext context,
  }) async {
    try {
      emit(PickerDashboardTabLoading());

      final response = await serviceLocator.tradingApi.updateMainOrderStatNew(
        preparationId: preparationLabel,
        orderStatus: status,
        comment: comment,
        orderNumber: suborderId,
        token: UserController().app_token,
      );

      if (response.statusCode == 200) {
        context.gNavigationService.openPickerWorkspacePage(context);

        showSnackBar(
          context: context,
          snackBar: showSuccessDialogue(
            message: "Order Status Updated Successfully....!",
          ),
        );
      } else {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "Order Status Update Failed....!",
          ),
        );
      }
    } catch (_) {
      emit(PickerDashboardTabErrorState(message: 'Unexpected error'));
    }
  }
}
