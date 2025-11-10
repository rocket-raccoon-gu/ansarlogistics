import 'package:ansarlogistics/Picker/presentation_layer/features/feature_batch_picking/bloc/item_batch_pickup_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_batch_picking/item_batch_pickup.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/bloc/picker_orders_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/services/post_repositories.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/services/post_service.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemBatchPickupRootBuilder {
  final ServiceLocator serviceLocator;
  final Map<String, dynamic> data;
  ItemBatchPickupRootBuilder(this.serviceLocator, this.data);

  // Widget call(BuildContext context) {
  //   return MultiBlocProvider(
  //     providers: [
  //       BlocProvider(
  //         create:
  //             (context) => ItemBatchPickupCubit(serviceLocator, data, context),
  //       ),
  //       BlocProvider(
  //         create:
  //             (context) => PickerOrdersCubit(
  //               context.gTradingApiGateway,
  //               context,
  //               PostRepositories(PostService(serviceLocator, context)),
  //             ),
  //       ),
  //     ],
  //     child: MultiRepositoryProvider(
  //       providers: [
  //         RepositoryProvider.value(value: serviceLocator.navigationService),
  //         RepositoryProvider<CubitsLocator>.value(value: serviceLocator),
  //       ],
  //       child: ItemBatchPickup(data: data),
  //     ),
  //   );
  // }

  Widget call(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => PickerOrdersCubit(
                context.gTradingApiGateway,
                context,
                PostRepositories(PostService(serviceLocator, context)),
              ),
        ),
        BlocProvider(
          create:
              (context) => ItemBatchPickupCubit(serviceLocator, data, context),
        ),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: serviceLocator.navigationService),
          RepositoryProvider<CubitsLocator>.value(value: serviceLocator),
        ],
        child: ItemBatchPickup(data: data),
      ),
    );
  }
}
