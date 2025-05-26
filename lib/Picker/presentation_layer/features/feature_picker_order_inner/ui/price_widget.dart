// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/bloc/picker_order_details_cubit.dart';
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

    // print(
    //   '[PriceWidget] 📦 OrderResponseItem: ${jsonEncode(orderResponseItem)}',
    // );

    // print(
    //   '[PriceWidget] 🔄 Assigned Picker Items Count: ${assignedPicker.length}',
    // );
    if (assignedPicker.isNotEmpty) {
      for (var item in assignedPicker) {
        double finalPrice = double.tryParse(item.finalPrice) ?? 0.0;
        double price = double.tryParse(item.price.toString()) ?? 0.0;
        double quantity = double.tryParse(item.qtyShipped.toString()) ?? 0.0;

        double effectivePrice = finalPrice < 1.0 ? price : finalPrice;

        double itemSubtotal;

        if (item.isproduce == "1") {
          itemSubtotal = effectivePrice;
        } else {
          itemSubtotal = effectivePrice * quantity;
        }

        assignedSubtotal += itemSubtotal;

        // print(
        //   '[PriceWidget] 🧾 Item -> price: $price, finalPrice: $finalPrice, qtyAssigned: $quantity, '
        //   'effectivePrice: $effectivePrice, isproduce: ${item.isproduce}, itemSubtotal: $itemSubtotal',
        // );
      }
    }

    double grandTotal = double.tryParse(orderResponseItem.grandTotal) ?? 0.0;
    double shippingCharges = double.tryParse(shippingCharge.trim()) ?? 0.0;
    bool hasShipping = shippingCharges > 0;

    // print('[PriceWidget] 🧮 assignedSubtotal: $assignedSubtotal');
    // print(
    //   '[PriceWidget] 🚚 Shipping Charges Input: "$shippingCharge" => Parsed: $shippingCharges',
    // );
    // print('[PriceWidget] 📊 Grand Total from Response: $grandTotal');

    final assignedPickerFromResponse = orderResponseItem.items?.assignedPicker;
    bool pickerListIsEmpty =
        assignedPickerFromResponse == null ||
        assignedPickerFromResponse.isEmpty;
    bool shouldAddShipping = pickerListIsEmpty && hasShipping;

    double finalPickerTotal =
        hasShipping ? assignedSubtotal + shippingCharges : assignedSubtotal;

    // print(
    //   '[PriceWidget] 📌 PickerList from Response: ${assignedPickerFromResponse?.length ?? 0}',
    // );
    // print('[PriceWidget] ⚠️ shouldAddShipping: $shouldAddShipping');
    // print(
    //   '[PriceWidget] 💰 Final Picker Total (with shipping if applicable): $finalPickerTotal',
    // );
    // print('[PriceWidget] 🔍 Order Status: $orderStatus');

    if (orderStatus == "start_picking" &&
        finalPickerTotal > grandTotal + epsilon) {
      // print(
      //   '[PriceWidget] ❗ Price mismatch detected: Final Picker Total ($finalPickerTotal) > Grand Total ($grandTotal)',
      // );
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
      decoration: BoxDecoration(color: customColors().secretGarden),
      child: Column(
        children: [
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
                grandTotal.toStringAsFixed(2),
                style: customTextStyle(
                  fontStyle: FontStyle.BodyL_Bold,
                  color: FontColor.White,
                ),
              ),
            ],
          ),

          const Divider(color: Colors.white, thickness: 1.0),

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

          const Divider(color: Colors.white, thickness: 1.0),

          if (orderStatus == "start_picking" &&
              finalPickerTotal > grandTotal + epsilon)
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
