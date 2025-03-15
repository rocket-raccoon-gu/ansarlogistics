import 'dart:convert';

import 'package:ansarlogistics/Picker/presentation_layer/features/feature_item_add/bloc/item_add_page_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_item_add/bloc/item_add_page_state.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/counter_button.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/custom_text_form_field.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  Future<void> scanBarcodeNormal() async {
    // String? barcodeScanRes;
    // ScanResult scanResult;

    // try {
    //   scanResult = await BarcodeScanner.scan(
    //       options: const ScanOptions(
    //           restrictFormat: [BarcodeFormat.code128, BarcodeFormat.ean13]));

    //   barcodeScanRes = scanResult.rawContent;
    // } on PlatformException {
    //   barcodeScanRes = 'Failed to get platform version.';
    // }

    // if (!mounted) return;

    // await BlocProvider.of<ItemReplacementPageCubit>(context)
    //     .getScannedProductData(barcodeScanRes, producebarcode);

    // setState(() {
    //   isScanner = false;
    // });
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
          backgroundColor: HexColor('#F9FBFF'),
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
              if (state is ItemAddPageInitialState &&
                  state.productResponse == null &&
                  !isScanner)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 12.0, vertical: 15.0),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Text(
                      //         "Produce Barcode",
                      //         style: customTextStyle(
                      //             fontStyle: FontStyle.BodyL_SemiBold),
                      //       ),
                      //       Checkbox(
                      //           value: producebarcode,
                      //           onChanged: (val) {
                      //             setState(() {
                      //               producebarcode = val!;
                      //             });
                      //           })
                      //     ],
                      //   ),
                      // ),
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
                                  context.read<ItemAddPageCubit>().updatedata(
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
                  state.productResponse == null &&
                  isScanner)
                Expanded(
                  child: MobileScanner(
                    // allowDuplicates: false,
                    // controller:
                    //     MobileScannerController(facing: CameraFacing.back),
                    // onDetect: (barcode, args) {
                    //   if (barcode.rawValue == null) {
                    //     debugPrint('Failed to scan Barcode');
                    //   } else {
                    //     final String code = barcode.rawValue!;
                    //     debugPrint('Barcode found! $code');
                    //     BlocProvider.of<ItemAddPageCubit>(context)
                    //         .updatedata(code, producebarcode);
                    //   }
                    // }
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
                          debugPrint('Failed to scan Barcode');
                        } else {
                          final String code = barcode.rawValue!;
                          debugPrint('Barcode found! $code');
                          BlocProvider.of<ItemAddPageCubit>(
                            context,
                          ).updatedata(code, producebarcode);
                        }
                      }
                    },
                  ),
                )
              else if (state is ItemAddPageInitialState &&
                  state.productResponse != null)
                Column(
                  children: [
                    state.productResponse!.mediaGalleryEntries.isNotEmpty
                        ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Container(
                            height: 275.0,
                            width: 275.0,
                            child: Center(
                              child: CachedNetworkImage(
                                imageUrl:
                                    "https://www.ansargallery.com/media/catalog/product/cache/d3078668c17a3fcf95f19e6d90a1909e/${state.productResponse!.mediaGalleryEntries[selectedindex].file}",
                                imageBuilder: (context, imageProvider) {
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
                                  return Image.asset('assets/placeholder.png');
                                },
                              ),
                            ),
                          ),
                        )
                        : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Container(
                            height: 275.0,
                            width: 275.0,
                            child: Image.asset("assets/placeholder.png"),
                          ),
                        ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SizedBox(
                        height: 60,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              state.productResponse!.mediaGalleryEntries.length,
                          itemBuilder: (context, index) {
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
                                      imageUrl:
                                          "https://www.ansargallery.com/media/catalog/product/cache/d3078668c17a3fcf95f19e6d90a1909e/${state.productResponse!.mediaGalleryEntries[index].file}",
                                      imageBuilder: (context, imageProvider) {
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
                                        return Image.asset(
                                          'assets/placeholder.png',
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
                        vertical: 16.0,
                        horizontal: 10.0,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  state.productResponse!.name,
                                  style: customTextStyle(
                                    fontStyle: FontStyle.HeaderXS_Bold,
                                    color: FontColor.FontPrimary,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      // double.parse(state.productResponse!.price
                                      //         .toString())
                                      //     .toStringAsFixed(2),
                                      context
                                              .read<ItemAddPageCubit>()
                                              .isSpecialPriceActive
                                          ? context
                                              .read<ItemAddPageCubit>()
                                              .specialPrice
                                              .toString()
                                          : double.parse(
                                            state.productResponse!.price
                                                .toString(),
                                          ).toStringAsFixed(2),

                                      style: customTextStyle(
                                        fontStyle: FontStyle.HeaderXS_Bold,
                                        color: FontColor.FontPrimary,
                                      ),
                                    ),
                                    Text(
                                      "  QAR",
                                      style: customTextStyle(
                                        fontStyle: FontStyle.BodyL_Bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "SKU: ${state.productResponse!.sku}",
                                      style: customTextStyle(
                                        fontStyle: FontStyle.HeaderXS_Bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 14.0,
                            ),
                            child: CounterContainer(
                              initNumber: 1,
                              counterCallback: (v) {
                                setState(() {
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
                        ],
                      ),
                    ),
                  ],
                )
              else if (state is ItemAddPageErrorState)
                Column(
                  children: [
                    state.productResponse!.mediaGalleryEntries.isNotEmpty
                        ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Container(
                            height: 275.0,
                            width: 275.0,
                            child: Center(
                              child: CachedNetworkImage(
                                imageUrl:
                                    "https://media-qatar.ahmarket.com/media/catalog/product/cache/2b71e5a2b5266e17ec3596451a32baea/${state.productResponse!.mediaGalleryEntries[selectedindex].file}",
                                imageBuilder: (context, imageProvider) {
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
                                  return Image.asset('assets/placeholder.png');
                                },
                              ),
                            ),
                          ),
                        )
                        : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Container(
                            height: 275.0,
                            width: 275.0,
                            child: Image.asset("assets/placeholder.png"),
                          ),
                        ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SizedBox(
                        height: 60,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              state.productResponse!.mediaGalleryEntries.length,
                          itemBuilder: (context, index) {
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
                                      imageUrl:
                                          "https://media-qatar.ahmarket.com/media/catalog/product/cache/2b71e5a2b5266e17ec3596451a32baea/${state.productResponse!.mediaGalleryEntries[index].file}",
                                      imageBuilder: (context, imageProvider) {
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
                                        return Image.asset(
                                          'assets/placeholder.png',
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
                        vertical: 16.0,
                        horizontal: 10.0,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  state.productResponse!.name,
                                  style: customTextStyle(
                                    fontStyle: FontStyle.HeaderXS_Bold,
                                    color: FontColor.FontPrimary,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      // double.parse(state.productResponse!.price
                                      //         .toString())
                                      //     .toStringAsFixed(2),
                                      context
                                              .read<ItemAddPageCubit>()
                                              .isSpecialPriceActive
                                          ? context
                                              .read<ItemAddPageCubit>()
                                              .specialPrice
                                              .toString()
                                          : double.parse(
                                            state.productResponse!.price
                                                .toString(),
                                          ).toStringAsFixed(2),

                                      style: customTextStyle(
                                        fontStyle: FontStyle.HeaderXS_Bold,
                                        color: FontColor.FontPrimary,
                                      ),
                                    ),
                                    Text(
                                      "  QAR",
                                      style: customTextStyle(
                                        fontStyle: FontStyle.BodyL_Bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "SKU: ${state.productResponse!.sku}",
                                      style: customTextStyle(
                                        fontStyle: FontStyle.HeaderXS_Bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12.0,
                              horizontal: 14.0,
                            ),
                            child: CounterContainer(
                              initNumber: 1,
                              counterCallback: (v) {
                                setState(() {
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
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          bottomNavigationBar: SizedBox(
            height:
                context.read<ItemAddPageCubit>().productResponse != null
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
                    context.read<ItemAddPageCubit>().productResponse != null
                        ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: BasketButton(
                                  loading: loading,
                                  onpress: () {
                                    setState(() {
                                      loading = true;
                                    });

                                    BlocProvider.of<ItemAddPageCubit>(
                                      context,
                                    ).updateItem(
                                      editquantity,
                                      context,
                                      context
                                              .read<ItemAddPageCubit>()
                                              .isSpecialPriceActive
                                          ? context
                                              .read<ItemAddPageCubit>()
                                              .specialPrice
                                              .toString()
                                          : double.parse(
                                            context
                                                .read<ItemAddPageCubit>()
                                                .productResponse!
                                                .price,
                                          ).toStringAsFixed(2),
                                    );
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
                            ],
                          ),
                        )
                        : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 5.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Produce Barcode",
                                    style: customTextStyle(
                                      fontStyle: FontStyle.BodyL_SemiBold,
                                    ),
                                  ),
                                  Checkbox(
                                    value: producebarcode,
                                    onChanged: (val) {
                                      setState(() {
                                        producebarcode = val!;
                                      });
                                    },
                                  ),
                                ],
                              ),
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
                                      onTap: () async {},
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: customColors().fontTertiary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            5.0,
                                          ),
                                        ),
                                        child: BasketButton(
                                          text: "Type Barcode",
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
                                        // scanBarcodeNormal();
                                        setState(() {
                                          isScanner = true;
                                        });
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
