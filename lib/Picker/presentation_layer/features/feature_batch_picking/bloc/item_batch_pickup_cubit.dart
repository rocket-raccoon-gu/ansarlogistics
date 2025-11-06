import 'package:ansarlogistics/Picker/presentation_layer/features/feature_batch_picking/bloc/item_batch_pickup_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ansarlogistics/services/service_locator.dart';

class ItemBatchPickupCubit extends Cubit<ItemBatchPickupState> {
  final ServiceLocator serviceLocator;
  final Map<String, dynamic> data;
  ItemBatchPickupCubit(this.serviceLocator, this.data)
    : super(ItemBatchPickupLoadingState()) {
    updatedata();
  }

  void updatedata() {
    final item = data['items_data'];

    emit(ItemBatchPickupLoadedState(item: item));
  }
}
