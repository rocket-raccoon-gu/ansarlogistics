import 'package:ansarlogistics/components/custom_app_components/order_status_widget.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/driver_base_response.dart';

class DeliveryTypeTile extends StatelessWidget {
  final DataItem orderResponseItem;
  const DeliveryTypeTile({super.key, required this.orderResponseItem});

  @override
  Widget build(BuildContext context) {
    if (orderResponseItem.order.subgroupIdentifier.startsWith('EXP')) {
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
                TranslatedText(
                  // getTranslate(context, "Express"),
                  text: "Express",
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyL_ItalicBold,
                    color: FontColor.White,
                  ),
                ),
              ],
            ),
            Text(
              "${orderResponseItem.order.deliveryFrom} - ${orderResponseItem.order.deliveryTo}",
              style: customTextStyle(
                fontStyle: FontStyle.BodyL_SemiBold,
                color: FontColor.White,
              ),
            ),
            OrderStatusWidget(status: orderResponseItem.order.status),
          ],
        ),
      );
    } else if (orderResponseItem.order.subgroupIdentifier.startsWith('NOL')) {
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
            TranslatedText(
              text: "Normal Local",
              style: customTextStyle(
                fontStyle: FontStyle.BodyL_SemiBold,
                color: FontColor.White,
              ),
            ),
            OrderStatusWidget(status: orderResponseItem.order.status),
          ],
        ),
      );
    } else if (orderResponseItem.order.subgroupIdentifier.startsWith('SUP')) {
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
            TranslatedText(
              text: "Supplier",
              style: customTextStyle(
                fontStyle: FontStyle.BodyL_SemiBold,
                color: FontColor.White,
              ),
            ),
            OrderStatusWidget(status: orderResponseItem.order.status),
          ],
        ),
      );
    } else if (orderResponseItem.order.subgroupIdentifier.startsWith('VPO')) {
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
            TranslatedText(
              text: "Vendor Pickup",
              style: customTextStyle(
                fontStyle: FontStyle.BodyL_SemiBold,
                color: FontColor.White,
              ),
            ),
            OrderStatusWidget(status: orderResponseItem.order.status),
          ],
        ),
      );
    } else if (orderResponseItem.order.subgroupIdentifier.startsWith('CAK')) {
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
            TranslatedText(
              text: "Cake Orders",
              style: customTextStyle(
                fontStyle: FontStyle.BodyL_SemiBold,
                color: FontColor.White,
              ),
            ),
            OrderStatusWidget(status: orderResponseItem.order.status),
          ],
        ),
      );
    } else if (orderResponseItem.order.subgroupIdentifier.startsWith('WAR')) {
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
            TranslatedText(
              text: "WareHouse Order",
              style: customTextStyle(
                fontStyle: FontStyle.BodyL_SemiBold,
                color: FontColor.White,
              ),
            ),
            OrderStatusWidget(status: orderResponseItem.order.status),
          ],
        ),
      );
    } else if (orderResponseItem.order.subgroupIdentifier.startsWith('ABY')) {
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
            TranslatedText(
              text: "Abaya Order",
              style: customTextStyle(
                fontStyle: FontStyle.BodyL_SemiBold,
                color: FontColor.White,
              ),
            ),
            OrderStatusWidget(status: orderResponseItem.order.status),
          ],
        ),
      );
    } else {
      return Container();
    }
    // } else {
    //   return Container();
    // }
  }
}
