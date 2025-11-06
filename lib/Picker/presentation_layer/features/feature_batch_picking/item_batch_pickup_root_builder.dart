import 'package:ansarlogistics/Picker/presentation_layer/features/feature_batch_picking/bloc/item_batch_pickup_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_batch_picking/item_batch_pickup.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemBatchPickupRootBuilder {
  final ServiceLocator serviceLocator;
  final Map<String, dynamic> data;
  ItemBatchPickupRootBuilder(this.serviceLocator, this.data);

  Widget call(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ItemBatchPickupCubit(serviceLocator, data),
        ),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: serviceLocator.navigationService),
          RepositoryProvider<CubitsLocator>.value(value: serviceLocator),
        ],
        child: ItemBatchPickup(),
      ),
    );
  }
}
