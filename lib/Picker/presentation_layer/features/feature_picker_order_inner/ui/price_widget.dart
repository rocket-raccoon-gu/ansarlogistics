import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/order_response.dart';

class PriceWidget extends StatelessWidget {
  Order orderResponseItem;
  Function()? onTapConfirm;
  double pickerprice;
  PriceWidget({
    super.key,
    required this.orderResponseItem,
    required this.onTapConfirm,
    required this.pickerprice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
      decoration: BoxDecoration(color: customColors().secretGarden),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order Price",
                style: customTextStyle(
                  fontStyle: FontStyle.BodyM_Bold,
                  color: FontColor.White,
                ),
              ),
              Text(
                double.parse(orderResponseItem.grandTotal).toStringAsFixed(2),
                style: customTextStyle(
                  fontStyle: FontStyle.BodyM_Bold,
                  color: FontColor.White,
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Picker Price",
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyL_Bold,
                    color: FontColor.White,
                  ),
                ),
                Text(
                  pickerprice.toStringAsFixed(2),
                  style: customTextStyle(
                    fontStyle: FontStyle.HeaderXS_Bold,
                    color: FontColor.White,
                  ),
                ),
              ],
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: onTapConfirm,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 10.0,
                  ),
                  decoration: BoxDecoration(
                    color: customColors().accent,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Center(child: Text("Confirm")),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
