import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_replacement/bloc/item_replacement_page_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_replacement/item_replacement_page.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/bloc/picker_orders_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/services/post_repositories.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/services/post_service.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemReplacementPageRouteBuilder {
  final ServiceLocator serviceLocator;
  Map<String, dynamic> data;

  ItemReplacementPageRouteBuilder(this.serviceLocator, this.data);

  Widget call(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => ItemReplacementPageCubit(
                serviceLocator: serviceLocator,
                data: data,
                context: context,
              ),
        ),
        BlocProvider(
          create:
              (context) => PickerOrdersCubit(
                serviceLocator.tradingApi,
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
        child: ItemReplacementPage(itemdata: data['item']),
      ),
    );
  }
}
