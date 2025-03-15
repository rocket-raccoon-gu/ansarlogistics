import 'dart:developer';
import 'dart:typed_data';

import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_inner/bloc/order_item_details_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_inner/bloc/order_item_details_state.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/bloc/picker_orders_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/bloc/picker_order_details_cubit.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/counter_button.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/barcode_change_sheet.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/price_change_sheet.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/scrollable_bottomsheet.dart';
import 'package:ansarlogistics/components/loading_indecator.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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

  bool pricechange = false;

  scanBarcodeNormal(String? barcodeScanRes) async {
    //   String barcodeScanRes;

    //   ScanResult scanResult;
    try {
      int actualquantity =
          double.parse(
            BlocProvider.of<OrderItemDetailsCubit>(
              context,
            ).orderItem!.qtyOrdered,
          ).toInt() -
          double.parse(
            BlocProvider.of<OrderItemDetailsCubit>(
              context,
            ).orderItem!.qtyCanceled,
          ).toInt();

      if (pricechange &&
          BlocProvider.of<OrderItemDetailsCubit>(
                context,
              ).orderItem!.isproduce ==
              "1") {
        String first7 = barcodeScanRes!.substring(0, 7);

        if (BlocProvider.of<OrderItemDetailsCubit>(
          context,
        ).orderItem!.productSku.startsWith(first7)) {
          //barcode matching

          setState(() {
            isScanner = false;
          });

          String lastsix = barcodeScanRes.toString().substring(
            barcodeScanRes.toString().length - 6,
          );
          if (barcodeScanRes != null) {
            onTapScan(barcodeScanRes, getPrice(lastsix), true);
          }
        } else {
          // onTapScan(barcodeScanRes, "", false);
          showSnackBar(
            context: context,
            snackBar: showErrorDialogue(
              errorMessage: "Barcode not matching ...!",
            ),
          );
        }
      } else {
        log(barcodeScanRes.toString());

        log("scanned barcode.............");

        if (barcodeScanRes.toString().startsWith(']C1')) {
          log('contains c1');
          barcodeScanRes = barcodeScanRes.toString().replaceAll(']C1', '');
        } else if (barcodeScanRes.toString().startsWith('C1')) {
          barcodeScanRes = barcodeScanRes.toString().replaceAll('C1', '');
        }

        if (barcodeScanRes.toString().trim() ==
            BlocProvider.of<OrderItemDetailsCubit>(
              context,
            ).orderItem!.productSku.toString()) {
          if (mounted) {
            if (editquantity != 0) {
              BlocProvider.of<OrderItemDetailsCubit>(context).updateitemstatus(
                "end_picking",
                editquantity.toString(),
                "",
                BlocProvider.of<OrderItemDetailsCubit>(
                  context,
                ).orderItem!.price,
              );
            } else {
              BlocProvider.of<OrderItemDetailsCubit>(context).updateitemstatus(
                "end_picking",
                actualquantity.toString(),
                "",
                BlocProvider.of<OrderItemDetailsCubit>(
                  context,
                ).orderItem!.price,
              );
            }
          }

          // BlocProvider.of<PickerOrdersCubit>(
          //   context,
          // ).loadPosts(1, statuslist[UserController().selectedindex]['status']);

          // setState(() {
          //   isScanner = false;
          // });

          // showQuantityCheckDialogue(
          //     editquantity != 0 ? editquantity : actualquantity);

          showSnackBar(
            context: context,
            snackBar: showSuccessDialogue(message: "Barcode Matching.."),
          );
        } else if (BlocProvider.of<OrderItemDetailsCubit>(
          context,
        ).orderItem!.productSku.contains(barcodeScanRes!)) {
          setState(() {
            isScanner = false;
          });

          showBarcodeChangeDialogue(
            BlocProvider.of<OrderItemDetailsCubit>(
              context,
            ).orderItem!.productSku,
            actualquantity,
            BlocProvider.of<OrderItemDetailsCubit>(context).orderItem!.price,
          );
        } else {
          showSnackBar(
            context: context,
            snackBar: showErrorDialogue(errorMessage: "Barcode Not Matching"),
          );
        }
      }
    } catch (e) {
      log(e.toString(), stackTrace: StackTrace.current);
    }
  }

  /// price change dialogue

  onTapScan(String barcode, String price, bool matching) {
    showPriceChangeDialogue(
      barcode,
      price,
      BlocProvider.of<OrderItemDetailsCubit>(context).orderItem!,
      BlocProvider.of<OrderItemDetailsCubit>(context).orderResponseItem!,
      matching,
      double.parse(
        BlocProvider.of<OrderItemDetailsCubit>(context).orderItem!.qtyOrdered,
      ).toInt(),
    );
  }

  ////

  //// barcode change dialogue
  ///
  showBarcodeChangeDialogue(String barcode, int mainqty, String price) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "",
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context0, animation, secondaryAnimation, child) {
        var curve = Curves.easeInOut.transform(animation.value);

        return BarcodeChangeSheet(
          curve: curve,
          scannedbarcode: barcode,
          confirmTap: (bar) {
            // load = true;

            log(bar);

            log(barcode);
            if (bar == barcode) {
              double pr = double.parse(price) / mainqty;

              print(pr);

              print(mainqty);

              if (editquantity != 0) {
                BlocProvider.of<OrderItemDetailsCubit>(
                  context,
                ).updateitemstatus(
                  "end_picking",
                  editquantity.toString(),
                  "",
                  pr.toString(),
                );
              } else {
                BlocProvider.of<OrderItemDetailsCubit>(
                  context,
                ).updateitemstatus(
                  "end_picking",
                  mainqty.toString(),
                  "",
                  pr.toString(),
                );
              }

              showSnackBar(
                context: context,
                snackBar: showSuccessDialogue(message: "Barcode Matching"),
              );
            }
          },
        );
      },
    );
  }

  showPriceChangeDialogue(
    String barcode,
    String price,
    EndPicking data,
    Order order,
    bool matching,
    int mainqty,
  ) {
    if (matching) {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: "",
        pageBuilder: (context, animation, secondaryAnimation) {
          return Container();
        },
        transitionBuilder: (context0, animation, secondaryAnimation, child) {
          var curve = Curves.easeInOut.transform(animation.value);

          return PriceChangeSheet(
            mediaGalleryEntries: data.productImages,
            data: data,
            curve: curve,
            price: price,
            scannedbarcode: barcode,
            confirmTap: (qty) {
              // load = true;

              double pr = double.parse(price) / mainqty;

              print(pr);

              print(mainqty);

              if (editquantity != 0) {
                BlocProvider.of<OrderItemDetailsCubit>(
                  context,
                ).updateitemstatus(
                  "end_picking",
                  editquantity.toString(),
                  "",
                  pr.toString(),
                );
              } else {
                BlocProvider.of<OrderItemDetailsCubit>(
                  context,
                ).updateitemstatus(
                  "end_picking",
                  mainqty.toString(),
                  "",
                  pr.toString(),
                );
              }
            },
          );
        },
      );
    } else {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: "",
        pageBuilder: (context, animation, secondaryAnimation) {
          return Container();
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          var curve = Curves.easeInOut.transform(animation.value);

          return Transform.scale(
            scale: curve,
            child: AlertDialog(
              content: StatefulBuilder(
                builder: (context, StateSetter state) {
                  return SizedBox(
                    width: 100,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            Column(
                              children: [
                                // Lottie.asset('assets/update_error.json'),
                                LoadingIndecator(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                  ),
                                  child: Text(
                                    "Scanned Barcode Not Matching Please Check...!",
                                    textAlign: TextAlign.center,
                                    style: customTextStyle(
                                      fontStyle: FontStyle.BodyL_Bold,
                                      color: FontColor.FontPrimary,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        context.gNavigationService.back(
                                          context,
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0,
                                          vertical: 10.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: customColors().accent,
                                          borderRadius: BorderRadius.circular(
                                            8.0,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Ok",
                                            style: customTextStyle(
                                              fontStyle: FontStyle.BodyM_Bold,
                                              color: FontColor.FontPrimary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Positioned(
                              right: 2.0,
                              child: InkWell(
                                onTap: () {
                                  context.gNavigationService.back(context);
                                },
                                child: Icon(Icons.close),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
    }
  }

  showQuantityCheckDialogue(int mainqty) {
    showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: "",
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        var curve = Curves.easeInOut.transform(animation.value);

        return Transform.scale(
          scale: curve,
          child: AlertDialog(
            content: StatefulBuilder(
              builder: (context, StateSetter state) {
                return SizedBox(
                  height: 150,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Confirm Quantity",
                        style: customTextStyle(fontStyle: FontStyle.BodyL_Bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: CounterContainer(
                          initNumber: mainqty,
                          counterCallback: (v) {
                            setState(() {
                              // qtylist[index]['qty'] = v;
                              // editquantity = v;

                              editquantity = v;
                            });
                          },
                          increaseCallback: () {},
                          decreaseCallback: () {
                            print("mm");
                            // stateSetter(() => op = true);
                          },
                          minNumber: 0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: BasketButton(
                                  bgcolor: customColors().carnationRed,
                                  text: "Confirm",
                                  textStyle: customTextStyle(
                                    fontStyle: FontStyle.BodyL_Bold,
                                    color: FontColor.White,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
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
      body:
          !isScanner
              ? Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 10.0,
                    ),
                    decoration: BoxDecoration(
                      color: HexColor('#F9FBFF'),
                      border: Border(
                        bottom: BorderSide(
                          width: 2.0,
                          color: customColors().backgroundTertiary,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: customColors().backgroundTertiary.withOpacity(
                            1.0,
                          ),
                          spreadRadius: 3,
                          blurRadius: 5,
                          // offset: Offset(0, 3), // changes the position of the shadow
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Product Details",
                                style: customTextStyle(
                                  fontStyle: FontStyle.BodyL_Bold,
                                  color: FontColor.FontPrimary,
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
                          BlocConsumer<
                            OrderItemDetailsCubit,
                            OrderItemDetailsState
                          >(
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

                                return Container(
                                  color: HexColor('#F9FBFF'),
                                  child: Column(
                                    children: [
                                      state.orderItem.productImages.isNotEmpty
                                          ? Padding(
                                            padding: const EdgeInsets.only(
                                              top: 6.0,
                                            ),
                                            child: FutureBuilder<
                                              Map<String, dynamic>
                                            >(
                                              future: getData(),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  Map<String, dynamic> data =
                                                      snapshot.data!;

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
                                                  );
                                                } else {
                                                  return SizedBox(
                                                    height: 275.0,
                                                    width: 275.0,
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
                                              child: Image.network(
                                                "${noimageurl}",
                                              ),
                                            ),
                                          ),
                                      Divider(
                                        color: customColors().fontTertiary,
                                      ),
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
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount:
                                                      state
                                                          .orderItem
                                                          .productImages
                                                          .length +
                                                      1,
                                                  itemBuilder: (
                                                    context,
                                                    index,
                                                  ) {
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
                                                            >(
                                                              context,
                                                            ).searchOnGoogle(
                                                              "${state.orderItem.productName} images",
                                                            );
                                                          },
                                                          child: Container(
                                                            height: 60.0,
                                                            width: 60.0,
                                                            decoration: BoxDecoration(
                                                              border: Border.all(
                                                                color:
                                                                    Color.fromRGBO(
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
                                                              selectedindex =
                                                                  index;
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
                                                                            BoxFit.cover,
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
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount:
                                                      state
                                                          .orderItem
                                                          .productImages
                                                          .length +
                                                      1,
                                                  itemBuilder: (
                                                    context,
                                                    index,
                                                  ) {
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
                                                            >(
                                                              context,
                                                            ).searchOnGoogle(
                                                              "${state.orderItem.productName} images",
                                                            );
                                                          },
                                                          child: Container(
                                                            height: 60.0,
                                                            width: 60.0,
                                                            decoration: BoxDecoration(
                                                              border: Border.all(
                                                                color:
                                                                    Color.fromRGBO(
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
                                                              selectedindex =
                                                                  index;
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
                                                                            BoxFit.cover,
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
                                                  fontStyle:
                                                      FontStyle.HeaderS_Bold,
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
                                            state.orderItem.itemStatus ==
                                                        "end_picking" ||
                                                    state
                                                            .orderItem
                                                            .itemStatus ==
                                                        "item_not_available"
                                                ? Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
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
                                                              FontStyle
                                                                  .HeaderXS_Bold,
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
                                                                FontStyle
                                                                    .BodyL_Bold,
                                                            color:
                                                                FontColor
                                                                    .FontPrimary,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                                : Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12.0,
                                                      ),
                                                  child: CounterContainer(
                                                    initNumber:
                                                        double.parse(
                                                          state
                                                              .orderItem
                                                              .qtyOrdered,
                                                        ).toInt(),
                                                    counterCallback: (v) {
                                                      setState(() {
                                                        // qtylist[index]['qty'] = v;
                                                        // editquantity = v;

                                                        editquantity = v;
                                                      });
                                                    },
                                                    increaseCallback: () {},
                                                    decreaseCallback: () {
                                                      print("mm");
                                                      // stateSetter(() => op = true);
                                                    },
                                                    minNumber: 0,
                                                  ),
                                                ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12.0,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Price",
                                                    style: customTextStyle(
                                                      fontStyle:
                                                          FontStyle
                                                              .HeaderXS_Bold,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 5.0,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          double.parse(
                                                            state
                                                                .orderItem
                                                                .price,
                                                          ).toStringAsFixed(2),
                                                          style: customTextStyle(
                                                            fontStyle:
                                                                FontStyle
                                                                    .HeaderXS_Bold,
                                                            color:
                                                                FontColor
                                                                    .FontPrimary,
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
                                                        .contains(
                                                          state.orderItem,
                                                        ) &&
                                                    !UserController
                                                        .userController
                                                        .indexlist
                                                        .contains(
                                                          state.orderItem,
                                                        ) &&
                                                    state.orderItem.isproduce ==
                                                        "1"
                                                ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 5.0,
                                                      ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Price Change ?",
                                                        style: customTextStyle(
                                                          fontStyle:
                                                              FontStyle
                                                                  .HeaderXS_Bold,
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
                              } else if (state is OrderItemDetailErrorState) {
                                return Container(
                                  color: HexColor('#F9FBFF'),
                                  child: Column(
                                    children: [
                                      state.orderItem.productImages.isNotEmpty
                                          ? Padding(
                                            padding: const EdgeInsets.only(
                                              top: 6.0,
                                            ),
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
                                          )
                                          : Container(
                                            height: 275.0,
                                            width: 275.0,
                                            child: Center(
                                              child: Image.network(
                                                "${noimageurl}",
                                              ),
                                            ),
                                          ),
                                      Divider(
                                        color: customColors().fontTertiary,
                                      ),
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
                                                state
                                                    .orderItem
                                                    .productImages
                                                    .length,
                                            itemBuilder: (context, index) {
                                              // return Text(state.datalist[index]['file']);
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
                                                  fontStyle:
                                                      FontStyle.HeaderS_Bold,
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
                                            state.orderItem.itemStatus ==
                                                        "end_picking" ||
                                                    state
                                                            .orderItem
                                                            .itemStatus ==
                                                        "item_not_available"
                                                ? Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
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
                                                              FontStyle
                                                                  .HeaderXS_Bold,
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
                                                                FontStyle
                                                                    .BodyL_Bold,
                                                            color:
                                                                FontColor
                                                                    .FontPrimary,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                                : Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12.0,
                                                      ),
                                                  child: CounterContainer(
                                                    initNumber:
                                                        double.parse(
                                                          state
                                                              .orderItem
                                                              .qtyOrdered,
                                                        ).toInt() -
                                                        double.parse(
                                                          state
                                                              .orderItem
                                                              .qtyCanceled,
                                                        ).toInt(),
                                                    counterCallback: (v) {
                                                      setState(() {
                                                        // qtylist[index]['qty'] = v;
                                                        // editquantity = v;

                                                        editquantity = v;
                                                      });
                                                    },
                                                    increaseCallback: () {},
                                                    decreaseCallback: () {
                                                      print("mm");
                                                      // stateSetter(() => op = true);
                                                    },
                                                    minNumber: 0,
                                                  ),
                                                ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12.0,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Price",
                                                    style: customTextStyle(
                                                      fontStyle:
                                                          FontStyle
                                                              .HeaderXS_Bold,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 5.0,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          double.parse(
                                                            state
                                                                .orderItem
                                                                .price,
                                                          ).toStringAsFixed(2),
                                                          style: customTextStyle(
                                                            fontStyle:
                                                                FontStyle
                                                                    .HeaderXS_Bold,
                                                            color:
                                                                FontColor
                                                                    .FontPrimary,
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
                                                    "end_picking"
                                                ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 5.0,
                                                      ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Update Price",
                                                        style: customTextStyle(
                                                          fontStyle:
                                                              FontStyle
                                                                  .HeaderXS_Bold,
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          // scanBarcodeNormal();
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
              )
              : MobileScanner(
                controller: MobileScannerController(
                  detectionSpeed: DetectionSpeed.normal,
                  returnImage: true,
                  facing: CameraFacing.back,
                ),
                onDetect: (barcode) {
                  final List<Barcode> barcodes = barcode.barcodes;
                  final Uint8List? image = barcode.image;

                  for (final barcode in barcodes) {
                    print(barcode.rawValue ?? "No Data found in QR");

                    if (barcode.rawValue == null) {
                      showSnackBar(
                        context: context,
                        snackBar: showErrorDialogue(
                          errorMessage: "Please Scan accurate...!",
                        ),
                      );
                    } else {
                      final String code = barcode.rawValue!;
                      showSnackBar(
                        context: context,
                        snackBar: showSuccessDialogue(message: code),
                      );
                      scanBarcodeNormal(code);
                    }
                  }
                },

                // controller: MobileScannerController(facing: CameraFacing.back),
                // onDetect: (barcode, args) {
                //
                // }
              ),
      bottomNavigationBar:
          BlocProvider.of<OrderItemDetailsCubit>(
                        context,
                      ).orderItem!.itemStatus ==
                      "end_picking" ||
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
                  ) ||
                  UserController.userController.indexlist.contains(
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
                                            title: Text("Alert..!"),
                                            backgroundColor:
                                                customColors().carnationRed,
                                            description: Text(
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
                                          title: Text(
                                            "Alert..!",
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
                                setState(() {
                                  isScanner = true;
                                });

                                // setState(() {
                                //   loading = true;
                                // });

                                // int actualquantity = double.parse(BlocProvider.of<
                                //                 OrderItemDetailsCubit>(context)
                                //             .orderItem!
                                //             .qtyOrdered)
                                //         .toInt() -
                                //     double.parse(BlocProvider.of<
                                //                 OrderItemDetailsCubit>(context)
                                //             .orderItem!
                                //             .qtyCanceled)
                                //         .toInt();

                                // if (editquantity == 0) {
                                //   log("pick");

                                //   if (BlocProvider.of<OrderItemDetailsCubit>(
                                //                   context)
                                //               .orderItem!
                                //               .itemStatus ==
                                //           'assigned_picker' ||
                                //       BlocProvider.of<OrderItemDetailsCubit>(
                                //                   context)
                                //               .orderItem!
                                //               .itemStatus ==
                                //           'start_picking') {
                                //     BlocProvider.of<OrderItemDetailsCubit>(
                                //             context)
                                //         .updateitemstatus(
                                //             "end_picking",
                                //             actualquantity.toString(),
                                //             "",
                                //             BlocProvider.of<
                                //                         OrderItemDetailsCubit>(
                                //                     context)
                                //                 .orderItem!
                                //                 .price);
                                //   } else {
                                //     BlocProvider.of<OrderItemDetailsCubit>(
                                //             context)
                                //         .updateitemstatus(
                                //             "end_picking",
                                //             actualquantity.toString(),
                                //             "",
                                //             BlocProvider.of<
                                //                         OrderItemDetailsCubit>(
                                //                     context)
                                //                 .orderItem!
                                //                 .price);
                                //   }
                                // } else {
                                //   // quantity change

                                //   // int actualquantity = double.parse(BlocProvider
                                //   //                 .of<OrderItemDetailsCubit>(
                                //   //                     context)
                                //   //             .orderItem!
                                //   //             .qtyOrdered)
                                //   //         .toInt() -
                                //   //     editquantity;

                                //   BlocProvider.of<OrderItemDetailsCubit>(context)
                                //       .updateitemstatus(
                                //           "end_picking",
                                //           editquantity.toString(),
                                //           "",
                                //           BlocProvider.of<OrderItemDetailsCubit>(
                                //                   context)
                                //               .orderItem!
                                //               .price);
                                // }

                                // BlocProvider.of<PickerOrdersCubit>(context)
                                //     .loadPosts(
                                //         1,
                                //         statuslist[UserController().selectedindex]
                                //             ['status']);
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
