import 'package:ansarlogistics/Driver/features/feature_driver_dashboard/ui/bottom_sheet/contact_customer_sheet.dart';
import 'package:ansarlogistics/Driver/features/feature_driver_dashboard/ui/bottom_sheet/view_direction_sheet.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/ui/delivery_type_tile.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/schedular_sheet.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/scrollable_bottomsheet.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/order_response.dart';

class DriverOrderListItem extends StatefulWidget {
  Order orderResponseItem;
  int index;
  Function() reschedulesuccess;
  DriverOrderListItem({
    super.key,
    required this.orderResponseItem,
    required this.index,
    required this.reschedulesuccess,
  });

  @override
  State<DriverOrderListItem> createState() => _DriverOrderListItemState();
}

class _DriverOrderListItemState extends State<DriverOrderListItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: InkWell(
        onTap: () {
          // if (widget.orderResponseItem.status != "assigned_picker") {
          context.gNavigationService.openDriverOrderInnerPage(
            context,
            arg: {'orderitem': widget.orderResponseItem},
          );
          // }
        },
        child: Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.startToEnd,
          background: ColoredBox(
            color: customColors().pacificBlue,
            child: Container(
              color: customColors().pacificBlue,
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          "assets/rescheduling.png",
                          height: 30.0,
                          color: customColors().backgroundPrimary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          "Reschedule",
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyM_Bold,
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
            if (widget.orderResponseItem.type == "EXP") {
              schedularBottomSheets(
                context: context,
                inputwidget: OrderSchedulerDateRange(
                  orderid: widget.orderResponseItem.subgroupIdentifier,
                  reschedulesuccess: widget.reschedulesuccess,
                ),
              );
            } else if (widget.orderResponseItem.type == "NOL") {
              schedularBottomSheets(
                context: context,
                inputwidget: OrderSchedulerNol(
                  mainorderid: widget.orderResponseItem.subgroupIdentifier,
                  reschedulesuccess: widget.reschedulesuccess,
                ),
              );
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
                            "${getTranslate(context, "Date")} ",
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 3.0,
                                    ),
                                    child: Text(
                                      "Zone  ",
                                      style: customTextStyle(
                                        fontStyle: FontStyle.Inter_Light,
                                      ),
                                    ),
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.symmetric(
                                  //       vertical: 3.0),
                                  //   child: Text(
                                  //     "Street ",
                                  //     style: customTextStyle(
                                  //         fontStyle: FontStyle.Inter_Light),
                                  //   ),
                                  // ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 3.0,
                                    ),
                                    child: Text(
                                      "Building  ",
                                      style: customTextStyle(
                                        fontStyle: FontStyle.Inter_Light,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 3.0,
                                    ),
                                    child: Text(
                                      widget.orderResponseItem.postcode,
                                      style: customTextStyle(
                                        fontStyle: FontStyle.BodyL_Bold,
                                        color: FontColor.FontPrimary,
                                      ),
                                    ),
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.symmetric(
                                  //       vertical: 3.0),
                                  //   child: Row(
                                  //     children: [
                                  //       Text(
                                  //         widget.orderResponseItem
                                  //             .billingStreet,
                                  //         style: customTextStyle(
                                  //             fontStyle:
                                  //                 FontStyle.BodyL_Bold,
                                  //             color: FontColor.FontPrimary),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 3.0,
                                    ),
                                    child: Text(
                                      widget.orderResponseItem.buildingNumber
                                          .toString(),
                                      style: customTextStyle(
                                        fontStyle: FontStyle.BodyL_Bold,
                                        color: FontColor.FontPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        widget.orderResponseItem.status == "on_the_way"
                            ? IconButton(
                              onPressed: () async {
                                customShowModalBottomSheet(
                                  context: context,
                                  inputWidget: ContactCustomerSheet(
                                    orderResponseItem: widget.orderResponseItem,
                                  ),
                                );
                              },
                              icon: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5.0,
                                  horizontal: 5.0,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: customColors().fontTertiary,
                                  ),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Icon(Icons.phone),
                              ),
                            )
                            : SizedBox(),
                        IconButton(
                          onPressed: () async {
                            customShowModalBottomSheet(
                              context: context,
                              inputWidget: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 12.0,
                                ),
                                child: ViewDirectionSheet(
                                  destinationlat:
                                      widget.orderResponseItem.latitude,
                                  destinationlong:
                                      widget.orderResponseItem.longitude,
                                ),
                              ),
                            );
                          },
                          icon: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 5.0,
                              horizontal: 5.0,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: customColors().fontTertiary,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Icon(Icons.directions_outlined),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 5.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Payment Method",
                        style: customTextStyle(fontStyle: FontStyle.BodyM_Bold),
                      ),
                      Text(
                        widget.orderResponseItem.paymentMethod,
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyM_Bold,
                          color: FontColor.FontPrimary,
                        ),
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
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'Comment : ',
                            style: customTextStyle(
                              fontStyle: FontStyle.Inter_Light,
                            ),
                            children: [
                              TextSpan(
                                text: widget.orderResponseItem.deliveryNote,
                                style: customTextStyle(
                                  fontStyle: FontStyle.Inter_Medium,
                                  color: FontColor.FontPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  void schedularBottomSheets({
    required BuildContext context,
    required inputwidget,
  }) {}
}
