import 'package:ansarlogistics/common_features/feature_select_region/bloc/select_region_page_state.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectRegionPageCubit extends Cubit<SelectRegionPageState> {
  BuildContext context;
  final ServiceLocator serviceLocator;
  SelectRegionPageCubit(this.context, this.serviceLocator)
    : super(SelectRegionLoadingState()) {
    loadpage();
  }

  loadpage() {}
}
