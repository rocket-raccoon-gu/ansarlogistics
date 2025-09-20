import 'package:ansarlogistics/common_features/feature_select_region/bloc/select_region_page_state.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectRegionPageCubit extends Cubit<SelectRegionPageState> {
  final BuildContext context;
  final ServiceLocator serviceLocator;

  static const String _regionPrefKey = 'selected_region';

  SelectRegionPageCubit(this.context, this.serviceLocator)
    : super(SelectRegionLoadingState()) {
    loadpage();
  }

  Future<void> loadpage() async {
    emit(SelectRegionLoadingState());
    final String? saved = await PreferenceUtils.getDataFromShared(
      _regionPrefKey,
    );
    if (saved != null && saved.isNotEmpty) {
      // Region already selected; proceed to login
      await Future.delayed(const Duration(milliseconds: 200));
      serviceLocator.navigationService.openLoginPage(context);
    } else {
      emit(SelectRegionReadyState());
    }
  }

  Future<void> selectRegion(String regionCode) async {
    emit(SelectRegionLoadingState());
    await PreferenceUtils.storeDataToShared(_regionPrefKey, regionCode);
    serviceLocator.navigationService.openLoginPage(context);
  }
}
