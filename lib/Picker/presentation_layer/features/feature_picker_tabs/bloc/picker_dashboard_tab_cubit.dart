import 'dart:async';

import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_tabs/bloc/picker_dashboard_tab_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';

class PickerDashboardTabCubit extends Cubit<PickerDashboardTabState> {
  final String suborderId; // exp/nol/... selected type
  final List<OrderItemNew> allItems; // items from order details page
  final String? preparationLabel; // e.g., PRNOL000098645
  final String? orderId; // fallback number for title

  PickerDashboardTabCubit({
    required this.suborderId,
    required this.allItems,
    this.preparationLabel,
    this.orderId,
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

  Map<String, List<OrderItemNew>> _groupByCategory(List<OrderItemNew> list) {
    final map = <String, List<OrderItemNew>>{};
    for (final item in list) {
      final key =
          (item.categoryName ?? '').isNotEmpty ? item.categoryName! : 'Others';
      (map[key] ??= <OrderItemNew>[]).add(item);
    }
    return map;
  }
}
