import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_details/bloc/picker_order_details_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_details/picker_order_details.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PickerOrderDetailsInnerPageRouteBuilder {
  final ServiceLocator serviceLocator;
  final Map<String, dynamic>? arguments;

  PickerOrderDetailsInnerPageRouteBuilder(
    this.serviceLocator, {
    this.arguments,
  });

  Widget call(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => PickerOrderDetailsInnerCubit(
                serviceLocator,
                arguments!['orderitem'],
              )..loadOrderDetails(),
        ),
      ],
      child: PickerOrderDetailsPage(
        orderDetails: arguments!['orderitem'],
        serviceLocator: serviceLocator,
      ),
    );
  }
}
