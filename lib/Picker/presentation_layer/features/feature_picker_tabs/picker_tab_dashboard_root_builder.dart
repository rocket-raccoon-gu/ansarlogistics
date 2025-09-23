import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_tabs/bloc/picker_dashboard_tab_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_tabs/picker_tab_dashboard.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';

class PickerTabDashboardRootBuilder {
  final ServiceLocator _serviceLocator;
  final Map<String, dynamic> _data;
  PickerTabDashboardRootBuilder(this._serviceLocator, this._data);

  Widget call(BuildContext context) {
    final suborderId = (_data['suborder_id'] ?? '').toString();

    // Expect either a flattened list of OrderItemNew in 'order_items'
    // or an 'order' (OrderNew) object to take items from.
    final dynamic itemsArg = _data['order'];
    final List<OrderItemNew> items =
        (itemsArg is OrderNew)
            ? itemsArg.items
            : (itemsArg is List<OrderItemNew>)
            ? itemsArg
            : <OrderItemNew>[];

    // Preparation label: try explicit arg, else from order
    final String? prepLabel =
        (_data['preparation_label']?.toString().isNotEmpty ?? false)
            ? _data['preparation_label'].toString()
            : (itemsArg is OrderNew ? itemsArg.subgroupIdentifier : null);

    // Order id fallback
    final String? orderId =
        (_data['order_id']?.toString().isNotEmpty ?? false)
            ? _data['order_id'].toString()
            : (itemsArg is OrderNew ? itemsArg.id : null);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ServiceLocator>.value(value: _serviceLocator),
        RepositoryProvider.value(value: _serviceLocator.navigationService),
      ],
      child: BlocProvider(
        create:
            (context) => PickerDashboardTabCubit(
              suborderId: suborderId,
              allItems: items,
              preparationLabel: prepLabel,
              orderId: orderId,
              serviceLocator: _serviceLocator,
            ),
        child: PickerTabDashboard(
          orderResponseItem: itemsArg,
          serviceLocator: _serviceLocator,
        ),
      ),
    );
  }
}
