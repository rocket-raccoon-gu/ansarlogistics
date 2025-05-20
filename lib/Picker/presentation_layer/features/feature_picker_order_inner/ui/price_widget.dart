// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/bloc/picker_order_details_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/ui/picker_order_item.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/ui/tabs/picked_items_page.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/order_response.dart';

class PriceWidget extends StatelessWidget {
  final Order orderResponseItem;
  final Function()? onTapConfirm;
  final String orderStatus;
  final String shippingCharge;

  PriceWidget({
    super.key,
    required this.orderResponseItem,
    required this.onTapConfirm,
    required this.orderStatus,
    required this.shippingCharge,
  });

  final double epsilon = 0.01;

  @override
  Widget build(BuildContext context) {
    final assignedPicker =
        BlocProvider.of<PickerOrderDetailsCubit>(context).pickeditems;

    double assignedSubtotal = 0.0;

    print(jsonEncode(orderResponseItem));

    if (assignedPicker.isNotEmpty) {
      for (var item in assignedPicker) {
        double finalPrice = double.tryParse(item.finalPrice) ?? 0.0;
        double price = double.tryParse(item.price.toString()) ?? 0.0;
        double quantity = double.tryParse(item.qtyShipped.toString()) ?? 0.0;

        double effectivePrice = finalPrice < 1.0 ? price : finalPrice;
        double itemSubtotal = effectivePrice * quantity;
        assignedSubtotal += itemSubtotal;
      }
    }
    double grandTotal = double.tryParse(orderResponseItem.grandTotal) ?? 0.0;

    final assignedPickerFromResponse = orderResponseItem.items?.assignedPicker;
    double shippingCharges = double.tryParse(shippingCharge.trim()) ?? 0.0;
    bool hasShipping = shippingCharges > 0;

    double totalAmount =
        hasShipping ? shippingCharges + grandTotal : grandTotal;

    bool pickerListIsEmpty =
        assignedPickerFromResponse == null ||
        assignedPickerFromResponse.isEmpty;

    bool shouldAddShipping = pickerListIsEmpty && hasShipping;

    double finalPickerTotal =
        assignedSubtotal + (shouldAddShipping ? shippingCharges : 0.0);

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
      decoration: BoxDecoration(color: customColors().secretGarden),
      child: Column(
        children: [
          // ✅ Order Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order Amount",
                style: customTextStyle(
                  fontStyle: FontStyle.BodyL_Bold,
                  color: FontColor.White,
                ),
              ),
              Text(
                (hasShipping ? grandTotal : grandTotal - shippingCharges)
                    .toStringAsFixed(2),
                style: customTextStyle(
                  fontStyle: FontStyle.BodyL_Bold,
                  color: FontColor.White,
                ),
              ),
            ],
          ),

          // ✅ Shipping Charges
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Shipping Charges",
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyL_Bold,
                    color: FontColor.White,
                  ),
                ),
                Text(
                  hasShipping ? shippingCharges.toStringAsFixed(2) : "Free",
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyL_Bold,
                    color: FontColor.White,
                  ),
                ),
              ],
            ),
          ),

          Divider(color: Colors.white, thickness: 1.0),

          // ✅ Total Order Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Order Amount",
                style: customTextStyle(
                  fontStyle: FontStyle.BodyL_Bold,
                  color: FontColor.White,
                ),
              ),
              Text(
                totalAmount.toStringAsFixed(2),
                style: customTextStyle(
                  fontStyle: FontStyle.BodyL_Bold,
                  color: FontColor.White,
                ),
              ),
            ],
          ),

          Divider(color: Colors.white, thickness: 1.0),

          // ✅ Final Picker Price (with shipping)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Final End Pick Price (including shipping)",
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyL_Bold,
                    color: FontColor.White,
                  ),
                ),
                Text(
                  finalPickerTotal.toStringAsFixed(2),
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyL_Bold,
                    color: FontColor.White,
                  ),
                ),
              ],
            ),
          ),

          // ✅ Price mismatch warning
          if (orderStatus == "start_picking")
            if ((finalPickerTotal - totalAmount).abs() > epsilon)
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.red,
                child: Text(
                  "Price mismatch: Please confirm with the customer before endpick.",
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyL_Bold,
                    color: FontColor.White,
                  ),
                ),
              ),

          // ✅ Confirm Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: onTapConfirm,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: customColors().accent,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: const Center(child: Text("Confirm")),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
