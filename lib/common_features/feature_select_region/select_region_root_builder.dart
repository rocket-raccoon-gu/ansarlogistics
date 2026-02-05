import 'package:ansarlogistics/common_features/feature_select_region/bloc/select_region_page_cubit.dart';
import 'package:ansarlogistics/common_features/feature_select_region/select_region.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectRegionRootBuilder {
  final ServiceLocator _serviceLocator;

  SelectRegionRootBuilder(this._serviceLocator);

  Widget call(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SelectRegionPageCubit(context, _serviceLocator),
        ),
      ],
      child: RepositoryProvider(
        create:
            (context) =>
                RepositoryProvider.value(value: _serviceLocator.tradingApi),
        child: SelectRegionPage(serviceLocator: _serviceLocator),
      ),
    );
  }
}
