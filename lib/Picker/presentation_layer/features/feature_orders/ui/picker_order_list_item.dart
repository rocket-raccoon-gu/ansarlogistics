import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/ui/delivery_type_tile.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/order_response.dart';

class PickerOrderListItem extends StatefulWidget {
  Order orderResponseItem;
  int index;
  PickerOrderListItem({
    super.key,
    required this.orderResponseItem,
    required this.index,
  });

  @override
  State<PickerOrderListItem> createState() => _PickerOrderListItemState();
}

class _PickerOrderListItemState extends State<PickerOrderListItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: InkWell(
        onTap: () {
          if (widget.orderResponseItem.status != "assigned_picker") {
            context.gNavigationService.openPickerOrderInnerPage(
              context,
              arg: {'orderitem': widget.orderResponseItem},
            );
          }
        },
        child: Dismissible(
          key: UniqueKey(),
          direction:
              widget.orderResponseItem.status == "assigned_picker"
                  ? DismissDirection.endToStart
                  : DismissDirection.none,
          background: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ColoredBox(
              color: customColors().pacificBlue,
              child: Container(
                child: Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Text(
                          "Start Pick",
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyL_Bold,
                            color: FontColor.White,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          confirmDismiss: (direction) async {
            if (widget.orderResponseItem.status == "assigned_picker") {
              final responce = await context.gTradingApiGateway.updateMainOrderStat(
                orderid: widget.orderResponseItem.subgroupIdentifier,
                orderstatus: "start_picking",
                comment:
                    "${UserController().profile.name} (${UserController().profile.empId}) started to Pick the order",
                userid: UserController().profile.id,
                latitude: UserController.userController.locationlatitude,
                longitude: UserController.userController.locationlongitude,
              );

              if (responce.statusCode == 200) {
                setState(() {
                  UserController
                          .userController
                          .orderitems[widget.index]
                          .status ==
                      "start_picking";

                  widget.orderResponseItem.status = "start_picking";
                });
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: getTypeColor(widget.orderResponseItem.type),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
                bottomLeft: Radius.circular(6.0),
                bottomRight: Radius.circular(6.0),
              ),
            ),
            child: Column(
              children: [
                DeliveryTypeTile(orderResponseItem: widget.orderResponseItem),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 10.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.orderResponseItem.subgroupIdentifier,
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyL_Bold,
                          color: FontColor.FontPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            // "${getTranslate(context, "Date")} ",
                            "Date",
                            style: customTextStyle(
                              fontStyle: FontStyle.Inter_Light,
                            ),
                          ),
                          Text(
                            getFormatedDate(
                              widget.orderResponseItem.deliveryFrom.toString(),
                            ),
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyL_SemiBold,
                              color: FontColor.FontPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Row(
                //         children: [
                //           Text(
                //             "${getTranslate(context, "Total Amount")}  ",
                //             style: customTextStyle(
                //                 fontStyle: FontStyle.Inter_Light),
                //           ),
                //           Text(
                //             double.parse(widget.orderResponseItem.grandTotal)
                //                 .toStringAsFixed(2),
                //             style: customTextStyle(
                //                 fontStyle: FontStyle.Inter_Medium,
                //                 color: FontColor.FontPrimary),
                //           )
                //         ],
                //       ),
                //       // Text(
                //       //   "${widget.orderResponseItem.items.length} Items",
                //       //   style: customTextStyle(
                //       //       fontStyle: FontStyle.Inter_Medium,
                //       //       color: FontColor.FontPrimary),
                //       // )
                //     ],
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 5.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.orderResponseItem.itemCount.toString(),
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyM_Bold,
                          color: FontColor.FontPrimary,
                        ),
                      ),
                      Text(
                        "  Items",
                        style: customTextStyle(fontStyle: FontStyle.BodyM_Bold),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 10.0,
                  ),
                  child: Row(
                    children: [
                      widget.orderResponseItem.deliveryNote.toString() != ""
                          ? FutureBuilder(
                            future: getTranslateWord(
                              widget.orderResponseItem.deliveryNote.toString(),
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      text:
                                          // '${getTranslate(context, "Comment")} : ',
                                          "Comment : ",
                                      style: customTextStyle(
                                        fontStyle: FontStyle.Inter_Light,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: snapshot.data,
                                          style: customTextStyle(
                                            fontStyle: FontStyle.Inter_Medium,
                                            color: FontColor.FontPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return Text("");
                              }
                            },
                          )
                          : const Text(""),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
