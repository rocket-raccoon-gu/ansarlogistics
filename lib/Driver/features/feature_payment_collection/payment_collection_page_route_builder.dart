import 'package:ansarlogistics/Driver/features/feature_payment_collection/payment_collection_page.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/driver_base_response.dart';

class PaymentCollectionPageRouteBuilder {
  final ServiceLocator serviceLocator;
  final Map<String, dynamic> data;

  PaymentCollectionPageRouteBuilder(this.serviceLocator, this.data);

  Widget call(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: serviceLocator.navigationService),
        RepositoryProvider<CubitsLocator>.value(value: serviceLocator),
      ],
      child: PaymentCollectionPage(
        serviceLocator: serviceLocator,
        order: data['order'] as DataItem,
      ),
    );
  }
}
