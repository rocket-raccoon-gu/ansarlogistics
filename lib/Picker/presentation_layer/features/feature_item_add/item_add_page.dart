import 'dart:convert';
import 'dart:developer';

import 'package:ansarlogistics/Picker/presentation_layer/features/feature_item_add/bloc/item_add_page_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_item_add/bloc/item_add_page_state.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_replacement/bloc/item_replacement_page_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_replacement/ui/db_data_container.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_replacement/ui/erp_data_container.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/counter_button.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/custom_text_form_field.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:picker_driver_api/responses/product_response.dart';
import 'package:camera/camera.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ItemAddPage extends StatefulWidget {
  const ItemAddPage({super.key});

  @override
  State<ItemAddPage> createState() => _ItemAddPageState();
}

class _ItemAddPageState extends State<ItemAddPage> {
  TextEditingController barcodeController = new TextEditingController();

  int selectedindex = 0;

  bool loading = false;

  bool isScanner = false;

  int editquantity = 1;

  late CameraController _cameraController;
  // late BarcodeScanner _barcodeScanner;
  bool isProcessing = false;
  String scannedBarcode = "";

  MobileScannerController cameraController = MobileScannerController();

  bool producebarcode = false;

  Future<void> scanBarcodeNormal(String barcodeScanRes) async {
    log(barcodeScanRes);

    // print("${barcodeScanRes}barcodeScanResbarcodeScanResbarcodeScanRes");

    if (!mounted) return;

    await BlocProvider.of<ItemAddPageCubit>(
      context,
    ).getScannedProductData(barcodeScanRes, producebarcode);

    setState(() {
      isScanner = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double mheight = MediaQuery.of(context).size.height * 1.222;
    Size screenSize = MediaQuery.of(context).size;

    return BlocConsumer<ItemAddPageCubit, ItemAddPageState>(
      listener: (context, state) {
        if (state is ItemAddPageErrorState) {
          setState(() {
            loading = state.loading;
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            child: AppBar(
              elevation: 0,
              backgroundColor: Color.fromRGBO(183, 214, 53, 1),
            ),
            preferredSize: const Size.fromHeight(0.0),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 2.0,
                      color: customColors().backgroundTertiary,
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: mheight * .012),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            context.gNavigationService.back(context);
                          },
                          icon: Icon(Icons.arrow_back, size: 20.0),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Row(
                            children: [
                              Text(
                                "Add New Item",
                                style: customTextStyle(
                                  fontStyle: FontStyle.BodyL_SemiBold,
                                  color: FontColor.FontPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(),
                      ],
                    ),
                  ),
                ),
              ),
              if (state is ItemAddFormState)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Column(
                          children: [
                            Row(children: [Text("Enter product barcode")]),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextFormField(
                                    keyboardType: TextInputType.number,
                                    bordercolor: customColors().fontTertiary,
                                    context: context,
                                    controller: barcodeController,
                                    fieldName: "",
                                    hintText: "Type here...",
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: BasketButton(
                                onpress: () async {
                                  // context.read<ItemAddPageCubit>().updatedata(
                                  //   barcodeController.text,
                                  //   producebarcode,
                                  // );.
                                  // print(barcodeController.text);

                                  await BlocProvider.of<ItemAddPageCubit>(
                                    context,
                                  ).getScannedProductData(
                                    barcodeController.text,
                                    producebarcode,
                                  );
                                },
                                bgcolor: customColors().dodgerBlue,
                                text: "Enter",
                                textStyle: customTextStyle(
                                  fontStyle: FontStyle.HeaderXS_Bold,
                                  color: FontColor.White,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else if (state is ItemAddPageInitialState &&
                  (state.erPdata != null || state.productDBdata != null))
                Column(
                  children: [
                    if (state.erPdata != null)
                      ErpDataContainer(
                        erPdata: state.erPdata,
                        counterCallback: (v) {
                          setState(() {
                            editquantity = v;
                          });
                        },
                      )
                    else if (state.productDBdata != null)
                      DbDataContainer(
                        productDBdata: state.productDBdata,
                        counterCallback: (v) {
                          setState(() {
                            editquantity = v;
                          });
                        },
                      ),
                  ],
                )
              else if (state is ItemAddPageInitialState &&
                  (state.erPdata == null || state.productDBdata == null))
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text("No Data Found...!")],
                  ),
                )
              else if (state is MobileScannerState1)
                Expanded(
                  child: MobileScanner(
                    controller: cameraController,
                    onDetect: (capture) async {
                      final List<Barcode> barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty &&
                          barcodes.first.rawValue != null) {
                        final scannedCode = barcodes.first.rawValue!;

                        if (scannedCode != barcodeController.text) {
                          barcodeController.text = scannedCode;

                          await BlocProvider.of<ItemAddPageCubit>(
                            context,
                          ).getScannedProductData(scannedCode, producebarcode);

                          // Optionally switch back to form
                          BlocProvider.of<ItemAddPageCubit>(
                            context,
                          ).updateFormState();
                        }
                      }
                    },
                  ),
                ),
            ],
          ),
          bottomNavigationBar: SizedBox(
            height:
                context.read<ItemAddPageCubit>().erPdata != null ||
                        context.read<ItemAddPageCubit>().productDBdata != null
                    ? screenSize.height * 0.1
                    : screenSize.height * 0.18,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Divider(
                      thickness: 1.0,
                      color: customColors().backgroundTertiary,
                    ),
                    context.read<ItemAddPageCubit>().erPdata != null ||
                            context.read<ItemAddPageCubit>().productDBdata !=
                                null
                        ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: BasketButton(
                                  loading: loading,
                                  onpress: () {
                                    // print(
                                    //   "----------------------------------------- submit ----------------------------------------",
                                    // );

                                    if (BlocProvider.of<ItemAddPageCubit>(
                                          context,
                                        ).erPdata !=
                                        null) {
                                      final cubit =
                                          context.read<ItemAddPageCubit>();
                                      final erp = cubit.erPdata!;
                                      final isProduce =
                                          cubit.productDBdata?.isProduce
                                              .toString() ??
                                          "null";

                                      cubit.updateItem(
                                        editquantity,
                                        context,
                                        erp.erpPrice.toString(),
                                        erp.erpPrice.toString(),
                                        erp.erpPrice.toString(),
                                        erp.erpSku.toString(),
                                        erp.erpProductName.toString(),
                                        barcodeController.text,
                                        isProduce,
                                      );
                                    } else if (BlocProvider.of<
                                          ItemAddPageCubit
                                        >(context).productDBdata !=
                                        null) {
                                      final cubit =
                                          context.read<ItemAddPageCubit>();
                                      final product = cubit.productDBdata!;

                                      final priceToUse =
                                          product.specialPrice != ""
                                              ? product.specialPrice.toString()
                                              : product.regularPrice.toString();

                                      // print(
                                      //   "[ItemAddPage] Using Product DB Data:",
                                      // );
                                      // print("  - editquantity: $editquantity");
                                      // print(
                                      //   "  - specialPrice/regular: $priceToUse",
                                      // );
                                      // print(
                                      //   "  - erpCurrentPrice: ${product.erpCurrentPrice}",
                                      // );
                                      // print(
                                      //   "  - regularPrice: ${product.regularPrice}",
                                      // );
                                      // print("  - sku: ${product.sku}");
                                      // print("  - name: ${product.skuName}");
                                      // print(
                                      //   "  - barcode: ${barcodeController.text}",
                                      // );
                                      // print(
                                      //   "  - isProduce: ${product.isProduce}",
                                      // );

                                      cubit.updateItem(
                                        editquantity,
                                        context,
                                        priceToUse,
                                        product.erpCurrentPrice,
                                        product.regularPrice,
                                        product.sku.toString(),
                                        product.skuName.toString(),
                                        barcodeController.text,
                                        product.isProduce.toString(),
                                      );
                                    }

                                    // setState(() {
                                    //   loading = false;
                                    // });
                                  },
                                  text: "Submit",
                                  bgcolor: customColors().dodgerBlue,
                                  textStyle: customTextStyle(
                                    fontStyle: FontStyle.BodyL_Bold,
                                    color: FontColor.White,
                                  ),
                                ),
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //     horizontal: 12.0,
                              //     vertical: 5.0,
                              //   ),
                              //   child: Row(
                              //     mainAxisAlignment:
                              //         MainAxisAlignment.spaceBetween,
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
                            ],
                          ),
                        )
                        : Column(
                          children: [
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(
                            //     horizontal: 12.0,
                            //     vertical: 5.0,
                            //   ),
                            //   child: Row(
                            //     mainAxisAlignment:
                            //         MainAxisAlignment.spaceBetween,
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
                                      left: 15.0,
                                      right: 10.0,
                                    ),
                                    child: InkWell(
                                      onTap: () async {
                                        // scanBarcodeNormal();

                                        var status =
                                            await Permission.camera.status;
                                        if (!status.isGranted) {
                                          await requestCameraPermission();
                                        }

                                        BlocProvider.of<ItemAddPageCubit>(
                                          context,
                                        ).updateScannerState();
                                      },
                                      child: BasketButtonwithIcon(
                                        bgcolor: customColors().dodgerBlue,
                                        text: "Start Scan",
                                        image: "assets/noun_scan.png",
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
                  ],
                ),
                Positioned(
                  child: loading ? LinearProgressIndicator() : SizedBox(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
