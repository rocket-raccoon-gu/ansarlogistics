import 'package:ansarlogistics/common_features/feature_scan_barcode/bloc/new_scan_barcode_page_cubit.dart';
import 'package:ansarlogistics/common_features/feature_scan_barcode/new_scan_barcode_page.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewScanPageRouteBuilder {
  final ServiceLocator _serviceLocator;
  Map<String, dynamic> data;
  NewScanPageRouteBuilder(this._serviceLocator, this.data);

  Widget call(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => NewScanBarcodePageCubit(
                context,
                serviceLocator: _serviceLocator,
              ),
        ),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: _serviceLocator.tradingApi),
        ],
        child: NewScanBarcodePage(serviceLocator: _serviceLocator),
      ),
    );
  }
}
