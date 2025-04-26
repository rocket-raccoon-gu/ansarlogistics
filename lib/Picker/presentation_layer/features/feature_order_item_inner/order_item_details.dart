import 'dart:developer';
import 'dart:typed_data';

import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_inner/bloc/order_item_details_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_inner/bloc/order_item_details_state.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_inner/ui/manual_pick.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/bloc/picker_order_details_cubit.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/counter_button.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/price_change_sheet.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/scrollable_bottomsheet.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/components/loading_indecator.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/order_response.dart';
import 'package:toastification/toastification.dart';

class OrderItemDetails extends StatefulWidget {
  OrderItemDetails({super.key});

  @override
  State<OrderItemDetails> createState() => _OrderItemDetailsState();
}

class _OrderItemDetailsState extends State<OrderItemDetails> {
  int selectedindex = 0;

  int editquantity = 0;

  bool loading = false;

  bool ismanual = false;

  bool pricechange = false;

  TextEditingController barcodeController = new TextEditingController();

  scanBarcodeNormal() async {
    String? barcodeScanRes;

    ScanResult scanResult;
    try {
      await requestCameraPermission();

      scanResult = await BarcodeScanner.scan();
      setState(() {
        barcodeScanRes = scanResult.rawContent;
      });

      log(barcodeScanRes!);

      if (barcodeScanRes != null) {
        await BlocProvider.of<OrderItemDetailsCubit>(context).updateBarcodeLog(
          BlocProvider.of<OrderItemDetailsCubit>(context).orderItem!.productSku,
          barcodeScanRes!,
        );

        await BlocProvider.of<OrderItemDetailsCubit>(context).checkitemdb(
          editquantity != 0
              ? editquantity.toString()
              : BlocProvider.of<OrderItemDetailsCubit>(
                context,
              ).orderItem!.qtyOrdered,
          barcodeScanRes!,
          BlocProvider.of<OrderItemDetailsCubit>(context).orderItem!,
        );
      }

      // }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          barcodeScanRes = 'Camera permission was denied';
        });
      } else {
        setState(() {
          barcodeScanRes = 'Unknown error: $e';
        });
      }
    } on FormatException {
      setState(() {
        barcodeScanRes = 'Nothing captured.';
      });
    } catch (e) {
      log(e.toString(), stackTrace: StackTrace.current);
    }
  }

  updateManualScan(String barcode) async {
    try {
      if (barcode != null) {
        await BlocProvider.of<OrderItemDetailsCubit>(context).updateBarcodeLog(
          BlocProvider.of<OrderItemDetailsCubit>(context).orderItem!.productSku,
          barcode,
        );

        await BlocProvider.of<OrderItemDetailsCubit>(context).checkitemdb(
          editquantity != 0
              ? editquantity.toString()
              : BlocProvider.of<OrderItemDetailsCubit>(
                context,
              ).orderItem!.qtyOrdered,
          barcode,
          BlocProvider.of<OrderItemDetailsCubit>(context).orderItem!,
        );
      }
    } catch (e) {}
  }

  bool isScanner = false;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(
          elevation: 0,
          backgroundColor: Color.fromRGBO(183, 214, 53, 1),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(
              vertical: 15.0,
              horizontal: 10.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  width: 2.0,
                  color: customColors().backgroundTertiary,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: customColors().backgroundTertiary.withOpacity(1.0),
                  spreadRadius: 3,
                  blurRadius: 5,
                  // offset: Offset(0, 3), // changes the position of the shadow
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    context.gNavigationService.back(context);

                    //
                  },
                  child: Icon(
                    Icons.arrow_back,
                    size: 23,
                    color: HexColor("#A3A3A3"),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Text(
                          "Product Details",
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyL_Bold,
                            color: FontColor.FontPrimary,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              ismanual = !ismanual;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5.0,
                              vertical: 5.0,
                            ),
                            decoration: BoxDecoration(
                              color: customColors().accent,
                            ),
                            child: Center(
                              child: Icon(Icons.shopify_outlined, size: 30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  BlocConsumer<OrderItemDetailsCubit, OrderItemDetailsState>(
                    listener: (context, state) {
                      if (state is OrderItemDetailErrorState) {
                        setState(() {
                          loading = state.loading;
                        });
                      }
                    },
                    builder: (context, state) {
                      if (state is OrderItemDetailInitialState) {
                        // setState(() {

                        // });

                        if (ismanual) {
                          return ManualPick(
                            orderItem: state.orderItem,
                            counterCallback: (p0) {
                              setState(() {
                                editquantity = p0;
                              });
                            },
                            barcodeController: barcodeController,
                          );
                        } else {
                          return Container(
                            color: Colors.white,
                            child: Column(
                              children: [
                                state.orderItem.productImages.isNotEmpty
                                    ? Padding(
                                      padding: const EdgeInsets.only(top: 6.0),
                                      child: FutureBuilder<
                                        Map<String, dynamic>
                                      >(
                                        future: getData(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            Map<String, dynamic> data =
                                                snapshot.data!;

                                            log(data['mediapath']);

                                            log(
                                              state
                                                  .orderItem
                                                  .productImages[selectedindex],
                                            );

                                            return SizedBox(
                                              height: 275.0,
                                              width: 275.0,
                                              child: Center(
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      "${data['mediapath']}${state.orderItem.productImages[selectedindex]}",
                                                  imageBuilder: (
                                                    context,
                                                    imageProvider,
                                                  ) {
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  placeholder:
                                                      (context, url) => Center(
                                                        child: Image.asset(
                                                          'assets/Iphone_spinner.gif',
                                                        ),
                                                      ),
                                                  errorWidget: (
                                                    context,
                                                    url,
                                                    error,
                                                  ) {
                                                    return Image.network(
                                                      '${noimageurl}',
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          } else {
                                            return SizedBox(
                                              height: 275.0,
                                              width: 275.0,
                                              child: Center(
                                                child: CachedNetworkImage(
                                                  imageUrl: "${noimageurl}",
                                                  imageBuilder: (
                                                    context,
                                                    imageProvider,
                                                  ) {
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  placeholder:
                                                      (context, url) => Center(
                                                        child: Image.asset(
                                                          'assets/Iphone_spinner.gif',
                                                        ),
                                                      ),
                                                  errorWidget: (
                                                    context,
                                                    url,
                                                    error,
                                                  ) {
                                                    return Image.network(
                                                      '$noimageurl{}',
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    )
                                    : Container(
                                      height: 275.0,
                                      width: 275.0,
                                      child: Center(
                                        child: Image.network("${noimageurl}"),
                                      ),
                                    ),
                                Divider(color: customColors().fontTertiary),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: SizedBox(
                                    height: 60,
                                    child: FutureBuilder(
                                      future: getData(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          Map<String, dynamic> data =
                                              snapshot.data!;
                                          return ListView.builder(
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                state
                                                    .orderItem
                                                    .productImages
                                                    .length +
                                                1,
                                            itemBuilder: (context, index) {
                                              // return Text(state.datalist[index]['file']);

                                              if (index ==
                                                  state
                                                      .orderItem
                                                      .productImages
                                                      .length) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8.0,
                                                      ),
                                                  child: InkWell(
                                                    onTap: () {
                                                      BlocProvider.of<
                                                        OrderItemDetailsCubit
                                                      >(context).searchOnGoogle(
                                                        "${state.orderItem.productName} images",
                                                      );
                                                    },
                                                    child: Container(
                                                      height: 60.0,
                                                      width: 60.0,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Color.fromRGBO(
                                                            183,
                                                            214,
                                                            53,
                                                            1,
                                                          ),
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          "More",
                                                          style: customTextStyle(
                                                            fontStyle:
                                                                FontStyle
                                                                    .BodyL_Bold,
                                                            color:
                                                                FontColor
                                                                    .FontPrimary,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8.0,
                                                      ),
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedindex = index;
                                                      });
                                                    },
                                                    child: Container(
                                                      height: 60.0,
                                                      width: 60.0,
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                          bottom: BorderSide(
                                                            width: 3.0,
                                                            color:
                                                                selectedindex ==
                                                                        index
                                                                    ? Color.fromRGBO(
                                                                      183,
                                                                      214,
                                                                      53,
                                                                      1,
                                                                    )
                                                                    : Colors
                                                                        .transparent,
                                                          ),
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: CachedNetworkImage(
                                                          imageUrl:
                                                              "${data['mediapath']}${state.orderItem.productImages[index]}",
                                                          imageBuilder: (
                                                            context,
                                                            imageProvider,
                                                          ) {
                                                            return Container(
                                                              decoration: BoxDecoration(
                                                                image: DecorationImage(
                                                                  image:
                                                                      imageProvider,
                                                                  fit:
                                                                      BoxFit
                                                                          .cover,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          placeholder:
                                                              (
                                                                context,
                                                                url,
                                                              ) => Center(
                                                                child: Image.asset(
                                                                  'assets/Iphone_spinner.gif',
                                                                ),
                                                              ),
                                                          errorWidget: (
                                                            context,
                                                            url,
                                                            error,
                                                          ) {
                                                            return Image.network(
                                                              '${noimageurl}',
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          );
                                        } else {
                                          return ListView.builder(
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                state
                                                    .orderItem
                                                    .productImages
                                                    .length +
                                                1,
                                            itemBuilder: (context, index) {
                                              // return Text(state.datalist[index]['file']);

                                              if (index ==
                                                  state
                                                      .orderItem
                                                      .productImages
                                                      .length) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8.0,
                                                      ),
                                                  child: InkWell(
                                                    onTap: () {
                                                      BlocProvider.of<
                                                        OrderItemDetailsCubit
                                                      >(context).searchOnGoogle(
                                                        "${state.orderItem.productName} images",
                                                      );
                                                    },
                                                    child: Container(
                                                      height: 60.0,
                                                      width: 60.0,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Color.fromRGBO(
                                                            183,
                                                            214,
                                                            53,
                                                            1,
                                                          ),
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          "More",
                                                          style: customTextStyle(
                                                            fontStyle:
                                                                FontStyle
                                                                    .BodyL_Bold,
                                                            color:
                                                                FontColor
                                                                    .FontPrimary,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8.0,
                                                      ),
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedindex = index;
                                                      });
                                                    },
                                                    child: Container(
                                                      height: 60.0,
                                                      width: 60.0,
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                          bottom: BorderSide(
                                                            width: 3.0,
                                                            color:
                                                                selectedindex ==
                                                                        index
                                                                    ? Color.fromRGBO(
                                                                      183,
                                                                      214,
                                                                      53,
                                                                      1,
                                                                    )
                                                                    : Colors
                                                                        .transparent,
                                                          ),
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: CachedNetworkImage(
                                                          imageUrl:
                                                              "${noimageurl}",
                                                          imageBuilder: (
                                                            context,
                                                            imageProvider,
                                                          ) {
                                                            return Container(
                                                              decoration: BoxDecoration(
                                                                image: DecorationImage(
                                                                  image:
                                                                      imageProvider,
                                                                  fit:
                                                                      BoxFit
                                                                          .cover,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          placeholder:
                                                              (
                                                                context,
                                                                url,
                                                              ) => Center(
                                                                child: Image.asset(
                                                                  'assets/Iphone_spinner.gif',
                                                                ),
                                                              ),
                                                          errorWidget: (
                                                            context,
                                                            url,
                                                            error,
                                                          ) {
                                                            return Image.network(
                                                              '${noimageurl}',
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0,
                                    vertical: 10.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          state.orderItem.productName,
                                          style: customTextStyle(
                                            fontStyle: FontStyle.HeaderS_Bold,
                                            color: FontColor.FontPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "SKU: ${state.orderItem.productSku}",
                                            style: customTextStyle(
                                              fontStyle:
                                                  FontStyle.HeaderXS_Bold,
                                            ),
                                          ),
                                        ],
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              "Qty Ordered : ${double.parse(state.orderItem.qtyOrdered).toInt()}",
                                              style: customTextStyle(
                                                fontStyle: FontStyle.BodyL_Bold,
                                                color: FontColor.FontPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      context
                                              .read<OrderItemDetailsCubit>()
                                              .productoptions!
                                              .isNotEmpty
                                          ? Column(
                                            children: [
                                              Row(
                                                children: [
                                                  if (context
                                                          .read<
                                                            OrderItemDetailsCubit
                                                          >()
                                                          .colorOptionId !=
                                                      "")
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Color",
                                                          style: customTextStyle(
                                                            fontStyle:
                                                                FontStyle
                                                                    .BodyL_Bold,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 8.0,
                                                              ),
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                height: 20,
                                                                width: 50,
                                                                decoration: BoxDecoration(
                                                                  color: HexColor(
                                                                    context
                                                                        .read<
                                                                          OrderItemDetailsCubit
                                                                        >()
                                                                        .colorInfo!
                                                                        .colorCode,
                                                                  ),
                                                                ),
                                                              ),
                                                              Text(
                                                                context
                                                                    .read<
                                                                      OrderItemDetailsCubit
                                                                    >()
                                                                    .colorInfo!
                                                                    .label,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  else
                                                    SizedBox(),

                                                  if (context
                                                          .read<
                                                            OrderItemDetailsCubit
                                                          >()
                                                          .carpetOptionId !=
                                                      "")
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 8.0,
                                                              ),
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          3.0,
                                                                      vertical:
                                                                          3.0,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                    color:
                                                                        customColors()
                                                                            .fontPrimary,
                                                                  ),
                                                                ),
                                                                child: Center(
                                                                  child: Text(
                                                                    context
                                                                        .read<
                                                                          OrderItemDetailsCubit
                                                                        >()
                                                                        .carpetSizeInfo!
                                                                        .label,
                                                                  ),
                                                                ),
                                                              ),
                                                              Text("Size"),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  else
                                                    SizedBox(),
                                                ],
                                              ),
                                            ],
                                          )
                                          : SizedBox(),

                                      // state.orderItem.itemStatus ==
                                      //             "end_picking" ||
                                      state.orderItem.itemStatus ==
                                              "item_not_available"
                                          ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12.0,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Quantity",
                                                  style: customTextStyle(
                                                    fontStyle:
                                                        FontStyle.HeaderXS_Bold,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 15,
                                                      ),
                                                  child: Text(
                                                    (double.parse(
                                                              state
                                                                  .orderItem
                                                                  .qtyOrdered,
                                                            ).toInt() -
                                                            double.parse(
                                                              state
                                                                  .orderItem
                                                                  .qtyCanceled,
                                                            ).toInt())
                                                        .toString(),
                                                    style: customTextStyle(
                                                      fontStyle:
                                                          FontStyle.BodyL_Bold,
                                                      color:
                                                          FontColor.FontPrimary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                          : Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12.0,
                                            ),
                                            child: CounterDropdown(
                                              initNumber:
                                                  (double.parse(
                                                        state
                                                            .orderItem
                                                            .qtyOrdered,
                                                      ).toInt() -
                                                      double.parse(
                                                        state
                                                            .orderItem
                                                            .qtyCanceled,
                                                      ).toInt()),
                                              counterCallback: (v) {
                                                setState(() {
                                                  // qtylist[index]['qty'] = v;
                                                  // editquantity = v;

                                                  editquantity = v;
                                                });
                                              },
                                              maxNumber: 100,
                                              minNumber: 0,
                                            ),
                                          ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12.0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Price",
                                              style: customTextStyle(
                                                fontStyle:
                                                    FontStyle.HeaderXS_Bold,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 5.0,
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    double.parse(
                                                      state.orderItem.price,
                                                    ).toStringAsFixed(2),
                                                    style: customTextStyle(
                                                      fontStyle:
                                                          FontStyle
                                                              .HeaderXS_Bold,
                                                      color:
                                                          FontColor.FontPrimary,
                                                    ),
                                                  ),
                                                  Text(
                                                    " QAR",
                                                    style: customTextStyle(
                                                      fontStyle:
                                                          FontStyle
                                                              .HeaderXS_Bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // widget.data['condition'] &&
                                      state.orderItem.itemStatus !=
                                                  "end_picking" &&
                                              !UserController
                                                  .userController
                                                  .itemnotavailablelist
                                                  .contains(state.orderItem) &&
                                              !UserController
                                                  .userController
                                                  .indexlist
                                                  .contains(state.orderItem) &&
                                              state.orderItem.isproduce == "1"
                                          ? Padding(
                                            padding: const EdgeInsets.only(
                                              top: 5.0,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Is Produce ?",
                                                  style: customTextStyle(
                                                    fontStyle:
                                                        FontStyle.HeaderXS_Bold,
                                                  ),
                                                ),
                                                Checkbox(
                                                  value: pricechange,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      pricechange = val!;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          )
                                          : SizedBox(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      } else if (state is OrderItemDetailErrorState) {
                        return Container(
                          color: HexColor('#F9FBFF'),
                          child: Column(
                            children: [
                              state.orderItem.productImages.isNotEmpty
                                  ? Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Container(
                                      height: 275.0,
                                      width: 275.0,
                                      child: Center(
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              "${mainimageurl}${state.orderItem.productImages[selectedindex]}",
                                          imageBuilder: (
                                            context,
                                            imageProvider,
                                          ) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            );
                                          },
                                          placeholder:
                                              (context, url) => Center(
                                                child: Image.asset(
                                                  'assets/Iphone_spinner.gif',
                                                ),
                                              ),
                                          errorWidget: (context, url, error) {
                                            return Image.network(
                                              '${noimageurl}',
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  )
                                  : Container(
                                    height: 275.0,
                                    width: 275.0,
                                    child: Center(
                                      child: Image.network("${noimageurl}"),
                                    ),
                                  ),
                              Divider(color: customColors().fontTertiary),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: SizedBox(
                                  height: 60,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        state.orderItem.productImages.length,
                                    itemBuilder: (context, index) {
                                      // return Text(state.datalist[index]['file']);
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedindex = index;
                                            });
                                          },
                                          child: Container(
                                            height: 60.0,
                                            width: 60.0,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  width: 3.0,
                                                  color:
                                                      selectedindex == index
                                                          ? Color.fromRGBO(
                                                            183,
                                                            214,
                                                            53,
                                                            1,
                                                          )
                                                          : Colors.transparent,
                                                ),
                                              ),
                                            ),
                                            child: Center(
                                              child: CachedNetworkImage(
                                                imageUrl: "${noimageurl}",
                                                imageBuilder: (
                                                  context,
                                                  imageProvider,
                                                ) {
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                placeholder:
                                                    (context, url) => Center(
                                                      child: Image.asset(
                                                        'assets/Iphone_spinner.gif',
                                                      ),
                                                    ),
                                                errorWidget: (
                                                  context,
                                                  url,
                                                  error,
                                                ) {
                                                  return Image.network(
                                                    '${noimageurl}',
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                  vertical: 10.0,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        state.orderItem.productName,
                                        style: customTextStyle(
                                          fontStyle: FontStyle.HeaderS_Bold,
                                          color: FontColor.FontPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.0,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "SKU: ${state.orderItem.productSku}",
                                          style: customTextStyle(
                                            fontStyle: FontStyle.HeaderXS_Bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    state.orderItem.itemStatus ==
                                                "end_picking" ||
                                            state.orderItem.itemStatus ==
                                                "item_not_available"
                                        ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12.0,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Quantity",
                                                style: customTextStyle(
                                                  fontStyle:
                                                      FontStyle.HeaderXS_Bold,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                    ),
                                                child: Text(
                                                  (double.parse(
                                                            state
                                                                .orderItem
                                                                .qtyOrdered,
                                                          ).toInt() -
                                                          double.parse(
                                                            state
                                                                .orderItem
                                                                .qtyCanceled,
                                                          ).toInt())
                                                      .toString(),
                                                  style: customTextStyle(
                                                    fontStyle:
                                                        FontStyle.BodyL_Bold,
                                                    color:
                                                        FontColor.FontPrimary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                        : Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12.0,
                                          ),
                                          child: CounterDropdown(
                                            initNumber: 0,
                                            counterCallback: (v) {
                                              setState(() {
                                                // qtylist[index]['qty'] = v;
                                                // editquantity = v;

                                                editquantity = v;
                                              });
                                            },
                                            maxNumber: 100,
                                            minNumber: 0,
                                          ),
                                        ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Price",
                                            style: customTextStyle(
                                              fontStyle:
                                                  FontStyle.HeaderXS_Bold,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 5.0,
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  double.parse(
                                                    state.orderItem.price,
                                                  ).toStringAsFixed(2),
                                                  style: customTextStyle(
                                                    fontStyle:
                                                        FontStyle.HeaderXS_Bold,
                                                    color:
                                                        FontColor.FontPrimary,
                                                  ),
                                                ),
                                                Text(
                                                  " QAR",
                                                  style: customTextStyle(
                                                    fontStyle:
                                                        FontStyle.HeaderXS_Bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // widget.data['condition'] &&
                                    state.orderItem.itemStatus != "end_picking"
                                        ? Padding(
                                          padding: const EdgeInsets.only(
                                            top: 5.0,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Update Price",
                                                style: customTextStyle(
                                                  fontStyle:
                                                      FontStyle.HeaderXS_Bold,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  scanBarcodeNormal();
                                                },
                                                child: Image.asset(
                                                  "assets/scanner_icon.png",
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                        : SizedBox(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar:
          BlocProvider.of<OrderItemDetailsCubit>(
                        context,
                      ).orderItem!.itemStatus ==
                      "item_not_available" ||
                  BlocProvider.of<OrderItemDetailsCubit>(
                        context,
                      ).orderItem!.itemStatus ==
                      "canceled" ||
                  UserController.userController.itemnotavailablelist.contains(
                    BlocProvider.of<OrderItemDetailsCubit>(context).orderItem!,
                  )
              ? SizedBox()
              : SizedBox(
                height: screenSize.height * 0.095,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Divider(
                      thickness: 1.0,
                      color: customColors().backgroundTertiary,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 10.0,
                              right: 15.0,
                            ),
                            child: InkWell(
                              onTap: () async {
                                customShowModalBottomSheetEg(
                                  context: context,
                                  inputWidget: OutOfStockBottomSheet(
                                    orderItemsResponse:
                                        BlocProvider.of<OrderItemDetailsCubit>(
                                          context,
                                        ).orderResponseItem,
                                    itemdata:
                                        BlocProvider.of<OrderItemDetailsCubit>(
                                          context,
                                        ).orderItem,
                                    onTapitemcancel: (String value) {
                                      if (value.isNotEmpty) {
                                        if (BlocProvider.of<
                                                  PickerOrderDetailsCubit
                                                >(
                                                  context,
                                                ).orderItem.itemCount ==
                                                1 &&
                                            BlocProvider.of<
                                                  PickerOrderDetailsCubit
                                                >(context).topickitems.length ==
                                                1) {
                                          log("only one item");

                                          toastification.show(
                                            autoCloseDuration: Duration(
                                              seconds: 5,
                                            ),
                                            title: TranslatedText(
                                              text: "Alert..!",
                                            ),
                                            backgroundColor:
                                                customColors().carnationRed,
                                            description: TranslatedText(
                                              text:
                                                  "Only One Item You Can Cancel this order !",
                                              style: customTextStyle(
                                                fontStyle: FontStyle.BodyM_Bold,
                                                color: FontColor.White,
                                              ),
                                            ),
                                          );
                                        } else {
                                          BlocProvider.of<
                                            OrderItemDetailsCubit
                                          >(context).updateitemstatus(
                                            "canceled",
                                            BlocProvider.of<
                                              OrderItemDetailsCubit
                                            >(context).orderItem!.qtyOrdered,
                                            value,
                                            BlocProvider.of<
                                              OrderItemDetailsCubit
                                            >(context).orderItem!.price,
                                          );
                                        }
                                      }

                                      //
                                      // item cancel option
                                    },
                                    onTapoutofstock: () async {
                                      if (BlocProvider.of<
                                                PickerOrderDetailsCubit
                                              >(context).orderItem.itemCount ==
                                              1 &&
                                          BlocProvider.of<
                                                PickerOrderDetailsCubit
                                              >(context).topickitems.length ==
                                              1) {
                                        log("only one item");

                                        toastification.show(
                                          autoCloseDuration: Duration(
                                            seconds: 5,
                                          ),
                                          backgroundColor:
                                              customColors().carnationRed,
                                          title: TranslatedText(
                                            text: "Alert..!",
                                            style: customTextStyle(
                                              fontStyle: FontStyle.BodyM_Bold,
                                              color: FontColor.White,
                                            ),
                                          ),
                                          description: Text(
                                            "Only One Item You Can Cancel this order !",
                                            style: customTextStyle(
                                              fontStyle: FontStyle.BodyM_Bold,
                                              color: FontColor.White,
                                            ),
                                          ),
                                        );
                                      } else {
                                        BlocProvider.of<OrderItemDetailsCubit>(
                                          context,
                                        ).updateitemstatus(
                                          "item_not_available",
                                          BlocProvider.of<
                                            OrderItemDetailsCubit
                                          >(context).orderItem!.qtyOrdered,
                                          "",
                                          BlocProvider.of<
                                            OrderItemDetailsCubit
                                          >(context).orderItem!.price,
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: customColors().fontTertiary,
                                  ),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: BasketButton(
                                  text: "OUT OF STOCK",
                                  textStyle: customTextStyle(
                                    fontStyle: FontStyle.BodyL_Bold,
                                    color: FontColor.FontPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 15.0,
                              right: 10.0,
                            ),
                            child: InkWell(
                              onTap: () async {
                                if (editquantity != 0) {
                                  if (ismanual) {
                                    updateManualScan(
                                      barcodeController.text.toString(),
                                    );
                                  } else {
                                    scanBarcodeNormal();
                                  }
                                } else {
                                  showSnackBar(
                                    context: context,
                                    snackBar: showErrorDialogue(
                                      errorMessage:
                                          "Please Confirm How Many Qty Picking...!",
                                    ),
                                  );
                                }
                              },
                              child: BasketButtonwithIcon(
                                loading: loading,
                                bgcolor: customColors().dodgerBlue,
                                text: "PICK UP",
                                image: "assets/pickup.png",
                                textStyle: customTextStyle(
                                  fontStyle: FontStyle.BodyL_Bold,
                                  color: FontColor.White,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}
