import 'package:ansarlogistics/components/custom_app_components/order_status_widget.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/order_response.dart';

class DeliveryTypeTile extends StatelessWidget {
  Order orderResponseItem;
  DeliveryTypeTile({super.key, required this.orderResponseItem});

  @override
  Widget build(BuildContext context) {
    // if (orderResponseItem.statusType == "New") {
    switch (orderResponseItem.type) {
      case "EXP":
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
            color: HexColor('#FF6E40'),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset('assets/express.png', height: 19.0),
                  Text(
                    // getTranslate(context, "Express"),
                    "Express",
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyL_ItalicBold,
                      color: FontColor.White,
                    ),
                  ),
                ],
              ),
              Text(
                orderResponseItem.deliveryTimerange.toString(),
                style: customTextStyle(
                  fontStyle: FontStyle.BodyL_SemiBold,
                  color: FontColor.White,
                ),
              ),
              OrderStatusWidget(status: orderResponseItem.status),
            ],
          ),
        );
      case "NOL":
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
            color: HexColor('#ffc160'),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Normal Local",
                style: customTextStyle(
                  fontStyle: FontStyle.BodyL_SemiBold,
                  color: FontColor.White,
                ),
              ),
              OrderStatusWidget(status: orderResponseItem.status),
            ],
          ),
        );
      case "SUP":
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
            color: HexColor('#20c9a6'),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Supplier",
                style: customTextStyle(
                  fontStyle: FontStyle.BodyL_SemiBold,
                  color: FontColor.White,
                ),
              ),
              OrderStatusWidget(status: orderResponseItem.status),
            ],
          ),
        );
      case "VPO":
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
            color: HexColor('#f64e4b'),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Vendor Pickup",
                style: customTextStyle(
                  fontStyle: FontStyle.BodyL_SemiBold,
                  color: FontColor.White,
                ),
              ),
              OrderStatusWidget(status: orderResponseItem.status),
            ],
          ),
        );
      case "CAK":
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
            color: HexColor('#ff4081'),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Cake Orders",
                style: customTextStyle(
                  fontStyle: FontStyle.BodyL_SemiBold,
                  color: FontColor.White,
                ),
              ),
              OrderStatusWidget(status: orderResponseItem.status),
            ],
          ),
        );
      case "WAR":
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
            color: HexColor('#ff4081'),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "WareHouse Order",
                style: customTextStyle(
                  fontStyle: FontStyle.BodyL_SemiBold,
                  color: FontColor.White,
                ),
              ),
              OrderStatusWidget(status: orderResponseItem.status),
            ],
          ),
        );
      case "ABY":
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
            color: HexColor('#04a6c7'),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Abaya Order",
                style: customTextStyle(
                  fontStyle: FontStyle.BodyL_SemiBold,
                  color: FontColor.White,
                ),
              ),
              OrderStatusWidget(status: orderResponseItem.status),
            ],
          ),
        );
      default:
        return Container();
    }
    // } else {
    //   return Container();
    // }
  }
}
