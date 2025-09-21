import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_inner/bloc/order_item_details_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_inner/order_item_details.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/bloc/picker_orders_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/services/post_repositories.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/services/post_service.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/bloc/picker_order_details_cubit.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderItemInnerRouteBuilder {
  final ServiceLocator serviceLocator;
  Map<String, dynamic> data;
  OrderItemInnerRouteBuilder({
    required this.serviceLocator,
    required this.data,
  });

  Widget call(BuildContext context) {
    final bool hasLegacyOrder = data.containsKey('order');
    return MultiBlocProvider(
      providers: [
        if (hasLegacyOrder)
          BlocProvider(
            create:
                (context) => PickerOrderDetailsCubit(
                  serviceLocator: serviceLocator,
                  context: context,
                  orderItem: data['order'],
                ),
          ),
        BlocProvider(
          create:
              (context) => OrderItemDetailsCubit(
                serviceLocator: serviceLocator,
                context: context,
                data: data,
                pickerOrderDetailsCubit:
                    hasLegacyOrder
                        ? context.read<PickerOrderDetailsCubit>()
                        : null,
              ),
        ),
        BlocProvider(
          create:
              (context) => PickerOrdersCubit(
                context.gTradingApiGateway,
                context,
                PostRepositories(PostService(serviceLocator, context)),
              ),
        ),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: serviceLocator.navigationService),
          RepositoryProvider<CubitsLocator>.value(value: serviceLocator),
        ],
        child: OrderItemDetails(data: data),
      ),
    );
  }
}
