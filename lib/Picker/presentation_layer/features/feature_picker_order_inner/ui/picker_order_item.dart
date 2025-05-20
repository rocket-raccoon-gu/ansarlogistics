import 'dart:developer';
import 'dart:ui';

import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/bloc/picker_order_details_cubit.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/image_widgets/list_image_widget.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/order_items_response.dart';
import 'package:picker_driver_api/responses/order_response.dart';

class PickerOrderItem extends StatefulWidget {
  List<EndPicking> itemslistbackcategories;
  List<String> catlist;
  int index;
  Order orderResponseItem;
  bool translate;
  PickerOrderItem({
    super.key,
    required this.catlist,
    required this.index,
    required this.orderResponseItem,
    required this.itemslistbackcategories,
    required this.translate,
  });

  @override
  State<PickerOrderItem> createState() => _PickerOrderItemState();
}

class _PickerOrderItemState extends State<PickerOrderItem> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  onDismissed1(EndPicking end) {
    // BlocProvider.of<PickerOrderDetailsCubit>(context).scanNormlBarcode(end);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: HexColor('#FCFCFC'),
          border: Border.all(color: HexColor("#D1D1D1")),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                widget.catlist[widget.index],
                style: customTextStyle(
                  fontStyle: FontStyle.BodyL_Bold,
                  color: FontColor.FontPrimary,
                ),
              ),
            ),
            // Text(widget.data['items'].length.toString())
            Padding(
              padding: EdgeInsets.only(top: 5.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: customColors().grey.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            // itemdetails(),
            ItemDetails(
              widget.itemslistbackcategories,
              widget.orderResponseItem,
              widget.catlist[widget.index],
            ),
          ],
        ),
      ),
    );
  }

  Widget ItemDetails(
    List<EndPicking> items,
    Order orderResponseItem,
    String cat,
  ) {
    List<EndPicking> itemslistbackcategories =
        items.where((element) => element.catename == cat).toList();

    return ListView.builder(
      itemCount: itemslistbackcategories.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        String actual =
            double.parse(
              itemslistbackcategories[index].qtyOrdered,
            ).toInt().toString();

        String shipped =
            double.parse(
              itemslistbackcategories[index].qtyShipped,
            ).toInt().toString();

        return InkWell(
          onTap: () {
            // log(index.toString());
            context.gNavigationService.openOrderItemDetailsPage(
              context,
              arg: {
                'item': itemslistbackcategories[index],
                'order': orderResponseItem,
              },
            );
          },
          child: Dismissible(
            key: Key(itemslistbackcategories[index].itemId),
            // direction:
            //     itemslistbackcategories[index].itemStatus == "end_picking"
            //         ? DismissDirection.none
            //         : DismissDirection.endToStart,
            direction: DismissDirection.none,
            background: ColoredBox(color: customColors().carnationRed),
            secondaryBackground: ColoredBox(
              color: Color.fromRGBO(183, 214, 53, 1),
              child: Container(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        'assets/delivery_man.png',
                        height: 50.0,
                        color: customColors().backgroundPrimary,
                      ),
                      Text(
                        "Pick",
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyL_Bold,
                          color: FontColor.White,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(width: 20),
                    ],
                  ),
                ),
              ),
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.endToStart) {
                // scanBarcodeNormal(context, itemslistbackcategories[index]);
                onDismissed1(itemslistbackcategories[index]);
              } else {}
              return false;
            },
            child: Container(
              decoration: BoxDecoration(
                color:
                    actual == "0" ||
                            itemslistbackcategories[index].itemStatus ==
                                "item_not_available"
                        ? customColors().backgroundTertiary.withOpacity(0.8)
                        : HexColor('#FCFCFC'),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: CustomPaint(
                      painter:
                          itemslistbackcategories.length == 1 ||
                                  index == itemslistbackcategories.length - 1
                              ? null
                              : DottedBorderPainter(),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 3,
                              vertical: 5.0,
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
                                        borderRadius: BorderRadius.circular(
                                          10.0,
                                        ),
                                        child:
                                            itemslistbackcategories[index]
                                                        .productImages
                                                        .isNotEmpty &&
                                                    itemslistbackcategories[index]
                                                            .productImages[0] !=
                                                        ""
                                                ? ListImageWidget(
                                                  imageurl:
                                                      itemslistbackcategories[index]
                                                          .productImages[0],
                                                )
                                                : Image.network(
                                                  '${noimageurl}',
                                                ),
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0,
                                          vertical: 3.0,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                actual == "0" ||
                                                        itemslistbackcategories[index]
                                                                .itemStatus ==
                                                            "item_not_available"
                                                    ? customColors()
                                                        .backgroundTertiary
                                                        .withOpacity(0.8)
                                                    : customColors()
                                                        .backgroundPrimary,
                                            border: Border(
                                              left: BorderSide(
                                                color: customColors().grey,
                                              ),
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 5.0,
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  widget.translate
                                                      ? FutureBuilder(
                                                        future: getTranslateWord(
                                                          itemslistbackcategories[index]
                                                              .productName,
                                                        ),
                                                        builder: (
                                                          context,
                                                          snapshot,
                                                        ) {
                                                          if (snapshot
                                                              .hasData) {
                                                            return Expanded(
                                                              child: Text(
                                                                snapshot.data!,
                                                                style: customTextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .Inter_Medium,
                                                                  color:
                                                                      FontColor
                                                                          .FontPrimary,
                                                                ),
                                                              ),
                                                            );
                                                          } else {
                                                            return Expanded(
                                                              child: Text(
                                                                itemslistbackcategories[index]
                                                                    .productName,
                                                                style: customTextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .Inter_Medium,
                                                                  color:
                                                                      FontColor
                                                                          .FontPrimary,
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        },
                                                      )
                                                      : Expanded(
                                                        child: Text(
                                                          itemslistbackcategories[index]
                                                              .productName,
                                                          style: customTextStyle(
                                                            fontStyle:
                                                                FontStyle
                                                                    .Inter_Medium,
                                                            color:
                                                                FontColor
                                                                    .FontPrimary,
                                                          ),
                                                        ),
                                                      ),
                                                ],
                                              ),
                                              // FutureBuilder(
                                              //   future: getTranslateWord(
                                              //     itemslistbackcategories[index]
                                              //         .productName,
                                              //   ),
                                              //   builder: (context, snapshot) {
                                              //     if (snapshot.hasData) {
                                              //       return Row(
                                              //         children: [
                                              //           Expanded(
                                              //             child: Text(
                                              //               snapshot.data!,
                                              //               style: customTextStyle(
                                              //                 fontStyle:
                                              //                     FontStyle
                                              //                         .Inter_Medium,
                                              //                 color:
                                              //                     FontColor
                                              //                         .FontPrimary,
                                              //               ),
                                              //             ),
                                              //           ),
                                              //         ],
                                              //       );
                                              //     } else {
                                              //       return Row(
                                              //         children: [
                                              //           Expanded(
                                              //             child: Text(
                                              //               itemslistbackcategories[index]
                                              //                   .productName,
                                              //               style: customTextStyle(
                                              //                 fontStyle:
                                              //                     FontStyle
                                              //                         .Inter_Medium,
                                              //                 color:
                                              //                     FontColor
                                              //                         .FontPrimary,
                                              //               ),
                                              //             ),
                                              //           ),
                                              //         ],
                                              //       );
                                              //     }
                                              //   },
                                              // ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 3.0,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "SKU : ",
                                                      style: customTextStyle(
                                                        fontStyle:
                                                            FontStyle
                                                                .BodyL_SemiBold,
                                                        color:
                                                            FontColor
                                                                .FontTertiary,
                                                      ),
                                                    ),
                                                    Text(
                                                      itemslistbackcategories[index]
                                                          .productSku,
                                                      style: customTextStyle(
                                                        fontStyle:
                                                            FontStyle
                                                                .BodyM_Bold,
                                                        color:
                                                            FontColor
                                                                .FontPrimary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 2.0,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          "Price :",
                                                          style: customTextStyle(
                                                            fontStyle:
                                                                FontStyle
                                                                    .BodyL_SemiBold,
                                                            color:
                                                                FontColor
                                                                    .FontTertiary,
                                                          ),
                                                        ),
                                                        Text(
                                                          double.parse(
                                                            itemslistbackcategories[index]
                                                                .price,
                                                          ).toStringAsFixed(2),
                                                          style: customTextStyle(
                                                            fontStyle:
                                                                FontStyle
                                                                    .Inter_SemiBold,
                                                            color:
                                                                FontColor
                                                                    .FontPrimary,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                left: 5.0,
                                                              ),
                                                          child: Text(
                                                            "QAR",
                                                            style: customTextStyle(
                                                              fontStyle:
                                                                  FontStyle
                                                                      .BodyM_Bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 2.0,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          "Final Price :",
                                                          style: customTextStyle(
                                                            fontStyle:
                                                                FontStyle
                                                                    .BodyL_SemiBold,
                                                            color:
                                                                FontColor
                                                                    .FontTertiary,
                                                          ),
                                                        ),
                                                        Text(
                                                          double.parse(
                                                            itemslistbackcategories[index]
                                                                .finalPrice,
                                                          ).toStringAsFixed(2),
                                                          style: customTextStyle(
                                                            fontStyle:
                                                                FontStyle
                                                                    .Inter_SemiBold,
                                                            color:
                                                                FontColor
                                                                    .FontPrimary,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                left: 5.0,
                                                              ),
                                                          child: Text(
                                                            "QAR",
                                                            style: customTextStyle(
                                                              fontStyle:
                                                                  FontStyle
                                                                      .BodyM_Bold,
                                                            ),
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
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 12.0,
                            right: 1.0,
                            child: Container(
                              height: 40.0,
                              width: 45.0,
                              padding: EdgeInsets.symmetric(
                                vertical: 11.0,
                                horizontal: 8.0,
                              ),
                              decoration: BoxDecoration(
                                color: HexColor("#D66435"),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Center(
                                child: Text(
                                  "${shipped}/${actual}",
                                  style: customTextStyle(
                                    fontStyle: FontStyle.BodyM_SemiBold,
                                    color: FontColor.White,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
