import 'package:ansarlogistics/components/custom_app_components/image_widgets/list_image_widget.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/order_response.dart';

class DriverOrderInnerListItem extends StatelessWidget {
  EndPicking orderItem;
  DriverOrderInnerListItem({super.key, required this.orderItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: customColors().backgroundTertiary,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                height: 109.0,
                width: 109.0,
                padding: const EdgeInsets.only(
                  right: 5.0,
                  top: 4.0,
                  bottom: 4.0,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child:
                      orderItem.productImages.isNotEmpty
                          ? ListImageWidget(
                            imageurl: orderItem.productImages[0],
                          )
                          : Image.asset('assets/placeholder.png'),
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        orderItem.productName,
                        style: customTextStyle(
                          fontStyle: FontStyle.Inter_Medium,
                          color: FontColor.FontPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 3.0,
                  ),
                  child: Row(
                    children: [
                      Text(
                        "SKU : ",
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyL_SemiBold,
                          color: FontColor.FontTertiary,
                        ),
                      ),
                      Text(
                        orderItem.productSku,
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyM_Bold,
                          color: FontColor.FontPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 2.0),
                      child: Row(
                        children: [
                          Text(
                            "Price :",
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyL_SemiBold,
                              color: FontColor.FontTertiary,
                            ),
                          ),
                          Text(
                            double.parse(orderItem.price).toStringAsFixed(2),
                            style: customTextStyle(
                              fontStyle: FontStyle.Inter_SemiBold,
                              color: FontColor.FontPrimary,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text(
                              "QAR",
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyM_Bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 2.0),
                      child: Row(
                        children: [
                          Text(
                            "Qty : ",
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyL_SemiBold,
                              color: FontColor.FontTertiary,
                            ),
                          ),
                          Text(
                            (double.parse(orderItem.qtyOrdered).toInt() -
                                    double.parse(orderItem.qtyCanceled).toInt())
                                .toString(),
                            style: customTextStyle(
                              fontStyle: FontStyle.Inter_SemiBold,
                              color: FontColor.FontPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
