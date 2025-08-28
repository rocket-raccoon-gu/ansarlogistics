import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/app_bar/order_inner_app_bar.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';
import 'bloc/picker_order_details_cubit.dart';
import 'bloc/picker_order_details_state.dart';

class PickerOrderDetailsPage extends StatefulWidget {
  final OrderNew orderDetails;
  final ServiceLocator serviceLocator;
  const PickerOrderDetailsPage({
    super.key,
    required this.orderDetails,
    required this.serviceLocator,
  });

  @override
  State<PickerOrderDetailsPage> createState() => _PickerOrderDetailsPageState();
}

class _PickerOrderDetailsPageState extends State<PickerOrderDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PickerOrderDetailsInnerCubit, PickerOrderDetailsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(0.0),
            child: AppBar(elevation: 0, backgroundColor: HexColor('#F9FBFF')),
          ),
          backgroundColor: customColors().backgroundPrimary,
          body: Stack(
            children: [
              // ------------------------------- header start ----------------------------------------
              OrderInnerAppBar(
                onTapBack: () async {
                  context.gNavigationService.back(context);
                },
                orderResponseItem: widget.orderDetails,
                onTapinfo: () {
                  showTopModel(
                    context,
                    widget.serviceLocator,
                    widget.orderDetails,
                  );
                },
                onTaptranslate: () {
                  // setState(() {
                  //   translate = !translate;
                  // });
                },
              ),
              _deliveryNotes(),
            ],
          ),
        );
      },
    );
  }

  Widget _deliveryNotes() {
    final notes =
        widget.orderDetails.deliveryNote?.trim().isNotEmpty == true
            ? widget.orderDetails.deliveryNote!.trim()
            : (widget.orderDetails.statusText ?? '');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: customColors().warning.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: customColors().backgroundTertiary.withOpacity(0.5),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 6.0,
            ),
            decoration: BoxDecoration(
              color: customColors().adBackground,
              borderRadius: BorderRadius.circular(6.0),
              border: Border.all(color: customColors().warning),
            ),
            child: Text(
              'Delivery Notes',
              style: customTextStyle(
                fontStyle: FontStyle.BodyM_Bold,
                color: FontColor.FontPrimary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              color: customColors().backgroundPrimary,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: customColors().backgroundTertiary),
            ),
            child: Text(
              notes.isEmpty ? '—' : notes,
              style: customTextStyle(
                fontStyle: FontStyle.BodyM_Regular,
                color: FontColor.FontSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
