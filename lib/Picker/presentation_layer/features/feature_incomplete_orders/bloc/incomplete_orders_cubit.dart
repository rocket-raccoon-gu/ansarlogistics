import 'package:ansarlogistics/Picker/presentation_layer/features/feature_incomplete_orders/bloc/incomplete_orders_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IncompleteOrdersCubit extends Cubit<IncompleteOrdersState> {
  IncompleteOrdersCubit() : super(IncompleteOrdersInitial()) {
    getIncompleteOrders();
  }

  void getIncompleteOrders() {
    emit(IncompleteOrdersLoading());
    try {
      emit(IncompleteOrdersLoaded());
    } catch (e) {
      emit(IncompleteOrdersError(message: e.toString()));
    }
  }
}
