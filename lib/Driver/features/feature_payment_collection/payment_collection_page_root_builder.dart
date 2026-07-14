import 'package:ansarlogistics/Driver/features/feature_payment_collection/bloc/payment_collection_cubit.dart';
import 'package:ansarlogistics/Driver/features/feature_payment_collection/payment_collection_page.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentCollectionPageRootBuilder {
  final ServiceLocator serviceLocator;
  final Map<String, dynamic> data;

  PaymentCollectionPageRootBuilder(this.serviceLocator, {required this.data});

  Widget call(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => PaymentCollectionCubit(
                serviceLocator: serviceLocator,
                data: data,
              ),
        ),
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: serviceLocator.navigationService),
          RepositoryProvider<CubitsLocator>.value(value: serviceLocator),
        ],
        child: PaymentCollectionPage(
          serviceLocator: serviceLocator,
          data: data,
        ),
      ),
    );
  }
}
