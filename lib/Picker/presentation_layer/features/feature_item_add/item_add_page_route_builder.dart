import 'package:ansarlogistics/Picker/presentation_layer/features/feature_item_add/bloc/item_add_page_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_item_add/item_add_page.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/bloc/picker_orders_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/services/post_repositories.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/services/post_service.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemAddPageRouteBuilder {
  final ServiceLocator serviceLocator;
  Map<String, dynamic> data;

  ItemAddPageRouteBuilder({required this.serviceLocator, required this.data});

  Widget call(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => ItemAddPageCubit(
                serviceLocator: serviceLocator,
                context: context,
                data: data,
              ),
        ),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: serviceLocator.navigationService),
          RepositoryProvider<CubitsLocator>.value(value: serviceLocator),
        ],
        child: ItemAddPage(
          preparationNumber: data['preparationNumber'],
          orderNumber: data['orderNumber'],
        ),
      ),
    );
  }
}
