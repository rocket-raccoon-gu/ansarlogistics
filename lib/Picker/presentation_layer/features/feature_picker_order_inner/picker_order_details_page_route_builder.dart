import 'dart:developer';

import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/bloc/picker_orders_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/services/post_repositories.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/services/post_service.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/bloc/picker_order_details_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/picker_order_details.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PickerOrderDetailsPageRouteBuilder {
  final ServiceLocator serviceLocator;
  Map<String, dynamic> data;
  PickerOrderDetailsPageRouteBuilder(this.serviceLocator, this.data);

  Widget call(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => PickerOrderDetailsCubit(
                serviceLocator: serviceLocator,
                context: context,
                orderItem: data['orderitem'],
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
        child: PickerOrderDetails(
          orderResponseItem: data['orderitem'],
          serviceLocator: serviceLocator,
        ),
      ),
    );
  }
}
