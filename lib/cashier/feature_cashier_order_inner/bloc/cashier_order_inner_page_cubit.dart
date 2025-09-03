import 'package:ansarlogistics/cashier/feature_cashier_order_inner/bloc/cashier_order_inner_page_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CashierOrderInnerPageCubit extends Cubit<CashierOrderInnerPageState> {
  CashierOrderInnerPageCubit() : super(CashierOrderInnerPageStateLoading());
}
