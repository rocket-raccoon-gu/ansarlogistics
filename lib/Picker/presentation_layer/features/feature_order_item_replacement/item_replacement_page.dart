import 'dart:convert';
import 'dart:developer';

import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_inner/bloc/order_item_details_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_replacement/bloc/item_replacement_page_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_replacement/bloc/item_replacement_page_state.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_replacement/ui/db_data_container.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_replacement/ui/dynamic_grid.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_replacement/ui/erp_data_container.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_replacement/ui/manual_form.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_replacement/ui/product_data.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/counter_button.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/custom_text_form_field.dart';
import 'package:ansarlogistics/components/loading_indecator.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:picker_driver_api/responses/order_response.dart';

class ItemReplacementPage extends StatefulWidget {
  EndPicking itemdata;
  ItemReplacementPage({super.key, required this.itemdata});

  @override
  State<ItemReplacementPage> createState() => _ItemReplacementPageState();
}

class _ItemReplacementPageState extends State<ItemReplacementPage> {
  String cancelreason = "Please Select Reason";

  TextEditingController commentcontroller = TextEditingController();

  TextEditingController barcodeController = new TextEditingController();

  late GlobalKey<FormState> idFormKey = GlobalKey<FormState>();

  MobileScannerController cameraController = MobileScannerController();

  int selectedindex = -1;

  bool loading = false;

  int editquantity = 0;

  bool isScanner = false;

  bool producebarcode = false;

  bool istextbarcode = false;

  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> scanBarcodeNormal(String barcodeScanRes) async {
    try {
      // print("${barcodeScanRes} asdfasdfasdfasdfsadasdf");
      String productSku = widget.itemdata.productSku;

      // final cubit = BlocProvider.of<OrderItemDetailsCubit>(context);
      // print("${cubit.orderItem?.productSku} cubit");

      String action = "replace";

      // update barcode log
      await BlocProvider.of<ItemReplacementPageCubit>(
        context,
      ).updateBarcodeLog('', barcodeScanRes);

      // get scanned barcode data
      await BlocProvider.of<ItemReplacementPageCubit>(
        context,
      ).getScannedProductData(
        barcodeScanRes,
        producebarcode,
        productSku,
        action,
      );

      if (mounted) {
        setState(() {
          isScanner = false;
          istextbarcode = false;
        });
        // }
      }
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

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(elevation: 0, backgroundColor: HexColor('#F9FBFF')),
      ),
      backgroundColor: Colors.white,
      body: Builder(
        builder: (context) {
          if (isScanner) {
            return MobileScanner(
              controller: MobileScannerController(facing: CameraFacing.back),
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;

                if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                  final scannedCode = barcodes.first.rawValue!;

                  if (scannedCode != barcodeController.text) {
                    barcodeController.text = scannedCode;

                    for (final barcode in barcodes) {
                      scanBarcodeNormal(barcode.rawValue!);
                    }
                  }
                }
              },
            );
          } else {
            return Column(
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
                              "Available Replacements",
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 8.0,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Why Are You Replacing This Item ?",
                                    textAlign: TextAlign.start,
                                    style: customTextStyle(
                                      fontStyle: FontStyle.BodyL_Bold,
                                      color: FontColor.FontPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 10.0,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    border:
                                        cancelreason == "Please Select Reason"
                                            ? Border.all(
                                              color: customColors().danger,
                                            )
                                            : Border.all(
                                              color: HexColor('#F0F0F0'),
                                            ),
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      // value: true,
                                      items:
                                          replacereasons.map((item) {
                                            return DropdownMenuItem(
                                              value: item,
                                              child: Text(item),
                                            );
                                          }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          cancelreason = value!;
                                        });
                                        // changereasons!(value);
                                      },
                                      hint: Text(
                                        cancelreason,
                                        style: customTextStyle(
                                          fontStyle: FontStyle.BodyM_Bold,
                                          color: FontColor.FontPrimary,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                      style: TextStyle(
                                        color: Colors.black,
                                        decorationColor: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              cancelreason == "Other Reasons"
                                  ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                    ),
                                    child: CustomTextFormField(
                                      context: context,
                                      maxLines: 3,
                                      bordercolor: customColors().fontSecondary,
                                      controller: commentcontroller,
                                      fieldName: "Please fill the reason",
                                      hintText: "Enter Reason..",
                                      validator: Validator.defaultValidator,
                                      onFieldSubmit: (p0) {
                                        if (idFormKey.currentState != null) {
                                          if (!idFormKey.currentState!
                                              .validate())
                                            return "Please fill the reason";
                                        }
                                      },
                                    ),
                                  )
                                  : SizedBox(),
                              BlocConsumer<
                                ItemReplacementPageCubit,
                                ItemReplacementPageState
                              >(
                                listener: (context, state) {
                                  if (state is ItemReplacementInitail) {
                                    setState(() {
                                      loading = false;
                                    });
                                  }
                                },
                                builder: (context, state) {
                                  if (state is ItemReplacementManualState) {
                                    String productSku =
                                        widget.itemdata.productSku;

                                    // final cubit = BlocProvider.of<OrderItemDetailsCubit>(context);
                                    // print("${cubit.orderItem?.productSku} cubit");

                                    String action = "replace";
                                    return ManualForm(
                                      onpress: () async {
                                        await BlocProvider.of<
                                          ItemReplacementPageCubit
                                        >(context).getScannedProductData(
                                          barcodeController.text,
                                          producebarcode,
                                          productSku,
                                          action,
                                        );
                                      },
                                      controller: barcodeController,
                                    );
                                  }

                                  if (state is ItemReplacementInitail) {
                                    if (state.prwork != null) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 275.0,
                                            width: 275.0,
                                            child: Image.network(
                                              noimageurl,
                                              fit: BoxFit.fill,
                                            ),
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16.0,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16.0,
                                                    ),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            state.prwork!.name,
                                                            style: customTextStyle(
                                                              fontStyle:
                                                                  FontStyle
                                                                      .HeaderXS_Bold,
                                                              color:
                                                                  FontColor
                                                                      .FontPrimary,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Text(
                                                                state
                                                                    .prwork!
                                                                    .price,
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
                                                                "  QAR",
                                                                style: customTextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .BodyL_Bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 8.0,
                                                          ),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                // "SKU: ${state.prwork!.sku}",
                                                                "SKU: ${context.read<ItemReplacementPageCubit>().showsku}",
                                                                style: customTextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .HeaderXS_Bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 12.0,
                                                            horizontal: 14.0,
                                                          ),
                                                      child: CounterDropdown(
                                                        initNumber: 1,
                                                        counterCallback: (v) {
                                                          setState(() {
                                                            // editquantity = v;
                                                          });
                                                        },
                                                        maxNumber: 100,
                                                        minNumber: 0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return ProductData(
                                        productResponse: state.itemdata,
                                        editqty: editquantity,
                                      );
                                    }
                                  }

                                  if (state is ItemReplacementLoaded) {
                                    if (state.productDBdata != null) {
                                      return DbDataContainer(
                                        productDBdata: state.productDBdata,
                                        counterCallback: (p0) {
                                          setState(() {
                                            editquantity = p0;
                                          });
                                        },
                                      );
                                    }
                                    if (state.erPdata != null) {
                                      return ErpDataContainer(
                                        erPdata: state.erPdata,
                                        counterCallback: (p0) {
                                          setState(() {
                                            editquantity = p0;
                                          });
                                        },
                                      );
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        top: 250.0,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [Text("No Data Found...!")],
                                      ),
                                    );
                                  } else {
                                    return Column(children: []);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: SizedBox(
        height: screenSize.height * 0.17,
        child: BlocBuilder<ItemReplacementPageCubit, ItemReplacementPageState>(
          builder: (context, state) {
            if (state is ItemReplacementLoaded &&
                (state.erPdata != null || state.productDBdata != null)) {
              return Stack(
                children: [
                  Positioned(
                    child:
                        loading
                            ? LinearProgressIndicator(
                              color: customColors().secretGarden,
                            )
                            : SizedBox(),
                  ),
                  Column(
                    children: [
                      Divider(
                        thickness: 1.0,
                        color: customColors().backgroundTertiary,
                      ),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: BasketButtonwithIcon(
                                onpress: () {
                                  if (cancelreason != "Please Select Reason") {
                                    //
                                    if (editquantity != 0 ||
                                        state.productDBdata?.isProduce == "1") {
                                      final cubit = BlocProvider.of<
                                        ItemReplacementPageCubit
                                      >(context);

                                      setState(() {
                                        loading = true;
                                      });

                                      final isProduce =
                                          cubit.productDBdata?.isProduce
                                              .toString() ??
                                          "null";

                                      if (BlocProvider.of<
                                            ItemReplacementPageCubit
                                          >(context).erPdata !=
                                          null) {
                                        BlocProvider.of<
                                          ItemReplacementPageCubit
                                        >(context).updatereplacement(
                                          selectedindex,
                                          context
                                              .read<ItemReplacementPageCubit>()
                                              .erPdata!
                                              .erpProductName,
                                          cancelreason,
                                          editquantity,
                                          context,
                                          context
                                              .read<ItemReplacementPageCubit>()
                                              .erPdata!
                                              .erpPrice
                                              .toString(),
                                          context
                                              .read<ItemReplacementPageCubit>()
                                              .erPdata!
                                              .erpPrice
                                              .toString(),
                                          context
                                              .read<ItemReplacementPageCubit>()
                                              .erPdata!
                                              .erpPrice
                                              .toString(),
                                          context
                                              .read<ItemReplacementPageCubit>()
                                              .erPdata!
                                              .erpSku,
                                          barcodeController.text,
                                          isProduce,
                                        );
                                      } else if (BlocProvider.of<
                                                ItemReplacementPageCubit
                                              >(context).productDBdata !=
                                              null ||
                                          state.productDBdata?.isProduce ==
                                              "1") {
                                        final cubit =
                                            context
                                                .read<
                                                  ItemReplacementPageCubit
                                                >();
                                        final product = cubit.productDBdata!;

                                        final priceToUse =
                                            product.specialPrice != ""
                                                ? product.specialPrice
                                                    .toString()
                                                : product.regularPrice
                                                    .toString();

                                        BlocProvider.of<
                                          ItemReplacementPageCubit
                                        >(context).updatereplacement(
                                          selectedindex,
                                          product.skuName.toString(),
                                          cancelreason,
                                          editquantity,
                                          context,
                                          priceToUse,
                                          product.erpCurrentPrice,
                                          product.regularPrice,
                                          product.sku.toString(),
                                          barcodeController.text,
                                          isProduce,
                                        );
                                      }
                                    } else {
                                      showSnackBar(
                                        context: context,
                                        snackBar: showErrorDialogue(
                                          errorMessage:
                                              "Please Select the Qty...!",
                                        ),
                                      );
                                    }
                                  } else {
                                    showSnackBar(
                                      context: context,
                                      snackBar: showErrorDialogue(
                                        errorMessage:
                                            "Please Select the Reason",
                                      ),
                                    );
                                  }
                                },
                                textStyle: customTextStyle(
                                  fontStyle: FontStyle.BodyL_Bold,
                                  color: FontColor.White,
                                ),
                                loading: loading,
                                bgcolor: customColors().dodgerBlue,
                                text: "Submit",
                                image: "assets/topick.png",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return Stack(
                children: [
                  Positioned(
                    child:
                        loading
                            ? LinearProgressIndicator(
                              color: customColors().secretGarden,
                            )
                            : SizedBox(),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Divider(
                        thickness: 1.0,
                        color: customColors().backgroundTertiary,
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 12.0,
                      //     vertical: 5.0,
                      //   ),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Text(
                      //         "Produce Barcode",
                      //         style: customTextStyle(
                      //           fontStyle: FontStyle.BodyL_SemiBold,
                      //         ),
                      //       ),
                      //       Checkbox(
                      //         value: producebarcode,
                      //         onChanged: (val) {
                      //           setState(() {
                      //             producebarcode = val!;
                      //           });
                      //         },
                      //       ),
                      //     ],
                      //   ),
                      // ),
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
                              child: LayoutBuilder(
                                builder: (context, constrains) {
                                  bool istablet = constrains.maxWidth > 400;

                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: customColors().fontTertiary,
                                      ),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: BasketButtonwithIcon(
                                      onpress: () async {
                                        // scanBarcodeNormal();

                                        // BlocProvider.of<
                                        //   ItemReplacementPageCubit
                                        // >(context).updateScannerState();

                                        // Check camera permission
                                        var status =
                                            await Permission.camera.status;
                                        if (!status.isGranted) {
                                          await requestCameraPermission();
                                        }

                                        setState(() {
                                          isScanner = true;
                                        });
                                      },
                                      image: "assets/noun_scan.png",
                                      text: "Scan Item",
                                      imagecolor: customColors().dodgerBlue,
                                      textStyle: customTextStyle(
                                        fontStyle: FontStyle.BodyL_Bold,
                                        color: FontColor.FontPrimary,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // submit change to type barcode
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 10.0,
                                right: 15.0,
                              ),
                              child: LayoutBuilder(
                                builder: (context, constrains) {
                                  bool isTablet = constrains.maxWidth > 400;

                                  return BasketButtonwithIcon(
                                    onpress: () {
                                      BlocProvider.of<ItemReplacementPageCubit>(
                                        context,
                                      ).updateManualState();
                                    },
                                    text: "Text Barcode",
                                    image: "assets/font.png",
                                    bgcolor: customColors().pacificBlue,
                                    textStyle: customTextStyle(
                                      fontStyle: FontStyle.BodyL_Bold,
                                      color: FontColor.White,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
