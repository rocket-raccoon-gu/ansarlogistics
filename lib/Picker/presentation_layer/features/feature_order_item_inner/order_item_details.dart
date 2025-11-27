// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_inner/bloc/order_item_details_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_inner/bloc/order_item_details_state.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/counter_button.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_scankit/flutter_scankit.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ansarlogistics/utils/utils.dart';

class OrderItemDetails extends StatefulWidget {
  final Map<String, dynamic> data;
  OrderItemDetails({super.key, required this.data});

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

  MobileScannerController cameraController = MobileScannerController();

  late final ScanKit scanKit;

  String result = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scanKit = ScanKit(
      photoMode: true,
      viewType:
          ScanTypes.qRCode.bit |
          ScanTypes.code128.bit |
          ScanTypes.ean13.bit |
          ScanTypes.code39.bit |
          ScanTypes.code93.bit |
          ScanTypes.aztec.bit |
          ScanTypes.dataMatrix.bit |
          ScanTypes.pdf417.bit |
          ScanTypes.upcCodeA.bit |
          ScanTypes.upcCodeE.bit |
          ScanTypes.ean8.bit |
          ScanTypes.all.bit,
    );
    scanKit.onResult.listen((val) {
      setState(() => result = val.originalValue);
      scanBarcodeNormal(result);
    });
  }

  Future<void> _startScan() async {
    try {
      await scanKit.startScan(
        scanTypes:
            ScanTypes.qRCode.bit | ScanTypes.code128.bit | ScanTypes.all.bit,
      );
    } on PlatformException catch (e) {
      debugPrint('Error: ${e.message}');
    }
  }

  scanBarcodeNormal(String? barcodeScanRes) async {
    try {
      if (barcodeScanRes != null) {
        log('📦 Scanned barcode: $barcodeScanRes');

        final orderItem =
            BlocProvider.of<OrderItemDetailsCubit>(context).orderItemNew;
        final productSku = orderItem?.sku;

        // print('🔍 Found product SKU: $productSku');

        // await BlocProvider.of<OrderItemDetailsCubit>(
        //   context,
        // ).updateBarcodeLog(productSku!, barcodeScanRes);
        // print('✅ Barcode log updated for SKU: $productSku');

        final quantityToCheck =
            editquantity != 0 ? editquantity.toString() : orderItem!.qtyOrdered;

        // print('📊 Quantity to check: $quantityToCheck');

        String action = "pick";

        await BlocProvider.of<OrderItemDetailsCubit>(context).checkitemdb(
          quantityToCheck!,
          barcodeScanRes,
          orderItem!,
          productSku!,
          action,
          widget.data['preparationLabel'],
        );

        // print('✅ checkitemdb completed for barcode: $barcodeScanRes');
      }

      if (!mounted) return;
      setState(() {
        isScanner = false;
        // istextbarcode = false;
      });
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
    final orderItem =
        BlocProvider.of<OrderItemDetailsCubit>(context).orderItemNew;
    final productSku = orderItem?.sku;
    try {
      if (barcode != null) {
        await BlocProvider.of<OrderItemDetailsCubit>(
          context,
        ).updateBarcodeLog(productSku!, barcode);
        String action = "pick";

        await BlocProvider.of<OrderItemDetailsCubit>(context).checkitemdb(
          editquantity != 0
              ? editquantity.toString()
              : BlocProvider.of<OrderItemDetailsCubit>(
                context,
              ).orderItem!.qtyOrdered,
          barcode,
          BlocProvider.of<OrderItemDetailsCubit>(context).orderItemNew!,
          productSku!,
          action,
          widget.data['preparationLabel'],
        );
      }
    } catch (e) {}
  }

  bool isScanner = false;

  bool isTranslate = false;

  bool isKeyboard = false;

  String calculateTotalWeight(
    String qtyOrdered,
    String itemWeight,
    String weightUnit,
  ) {
    if (qtyOrdered.isEmpty || itemWeight.isEmpty) {
      return "0 gm";
    }

    double qty = double.tryParse(qtyOrdered) ?? 0.0;
    double weightPerItem = double.tryParse(itemWeight) ?? 0.0;

    double totalWeightInGrams;

    if (weightUnit.toLowerCase() == "kg") {
      totalWeightInGrams = qty * (weightPerItem * 1000);
    } else {
      totalWeightInGrams = qty * weightPerItem;
    }

    if (totalWeightInGrams >= 1000) {
      double totalInKg = totalWeightInGrams / 1000;
      return "${totalInKg.toStringAsFixed(2)} kg";
    } else {
      return "${totalWeightInGrams.toStringAsFixed(0)} gm";
    }
  }

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
                    mainAxisAlignment: MainAxisAlignment.center,
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
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      isKeyboard = !isKeyboard;
                    });
                  },
                  icon: Icon(
                    Icons.keyboard,
                    size: 30,
                    color: HexColor("#A3A3A3"),
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
                      if (state is OrderItemDetailInitialNewState) {
                        // New model rendering
                        final item = state.orderItem;
                        return Container(
                          color: Colors.white,
                          child: Column(
                            children: [
                              // Main image
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: FutureBuilder<Map<String, dynamic>>(
                                  future: getData(),
                                  builder: (context, snapshot) {
                                    final String base =
                                        snapshot.data != null
                                            ? (snapshot.data!['mediapath'] ??
                                                    '')
                                                .toString()
                                            : '';
                                    // Build images list from imageUrl or productImage (comma separated)
                                    final List<String> images =
                                        (() {
                                          final List<String> acc = [];
                                          if ((item.imageUrl ?? '')
                                              .isNotEmpty) {
                                            acc.add(item.imageUrl!);
                                          }
                                          if ((item.productImage ?? '')
                                              .isNotEmpty) {
                                            acc.addAll(
                                              item.productImage!
                                                  .split(',')
                                                  .map((e) => e.trim())
                                                  .where((e) => e.isNotEmpty),
                                            );
                                          }
                                          return acc.isEmpty
                                              ? [noimageurl]
                                              : acc;
                                        })();
                                    String resolve(String p) {
                                      if (p.startsWith('http')) return p;
                                      return '$base$p';
                                    }

                                    final String mainUrl = resolve(
                                      images[selectedindex.clamp(
                                        0,
                                        images.length - 1,
                                      )],
                                    );
                                    return SizedBox(
                                      height: 275.0,
                                      width: 275.0,
                                      child: Center(
                                        child: CachedNetworkImage(
                                          imageUrl: mainUrl,
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
                                            return Image.network(noimageurl);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Divider(color: customColors().fontTertiary),
                              // Thumbnails
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: SizedBox(
                                  height: 60,
                                  child: FutureBuilder<Map<String, dynamic>>(
                                    future: getData(),
                                    builder: (context, snapshot) {
                                      final String base =
                                          snapshot.data != null
                                              ? (snapshot.data!['mediapath'] ??
                                                      '')
                                                  .toString()
                                              : '';
                                      final List<String> images =
                                          (() {
                                            final List<String> acc = [];
                                            if ((item.imageUrl ?? '')
                                                .isNotEmpty) {
                                              acc.add(item.imageUrl!);
                                            }
                                            if ((item.productImage ?? '')
                                                .isNotEmpty) {
                                              acc.addAll(
                                                item.productImage!
                                                    .split(',')
                                                    .map((e) => e.trim())
                                                    .where((e) => e.isNotEmpty),
                                              );
                                            }
                                            return acc.isEmpty
                                                ? [noimageurl]
                                                : acc;
                                          })();
                                      String resolve(String p) {
                                        if (p.startsWith('http')) return p;
                                        return '$base$p';
                                      }

                                      return ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: images.length + 1,
                                        itemBuilder: (context, index) {
                                          if (index == images.length) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                  ),
                                              child: InkWell(
                                                onTap: () {
                                                  context
                                                      .read<
                                                        OrderItemDetailsCubit
                                                      >()
                                                      .searchOnGoogle(
                                                        "${item.name ?? item.sku ?? ''} images",
                                                      );
                                                },
                                                child: Container(
                                                  height: 60.0,
                                                  width: 60.0,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color:
                                                          customColors()
                                                              .backgroundTertiary,
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
                                          }
                                          final thumbUrl = resolve(
                                            images[index],
                                          );
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
                                                              ? customColors()
                                                                  .backgroundTertiary
                                                              : Colors
                                                                  .transparent,
                                                    ),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: CachedNetworkImage(
                                                    imageUrl: thumbUrl,
                                                    imageBuilder: (
                                                      context,
                                                      imageProvider,
                                                    ) {
                                                      return Container(
                                                        decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                            image:
                                                                imageProvider,
                                                            fit: BoxFit.cover,
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
                                                        noimageurl,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),

                              // Details card (title/SKU/price/qty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 12.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product name
                                    Text(
                                      item.name ?? '-',
                                      style: customTextStyle(
                                        fontStyle: FontStyle.HeaderS_Bold,
                                        color: FontColor.FontPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // SKU + delivery badge (NOL)
                                    Row(
                                      children: [
                                        Text(
                                          'SKU: ${item.sku ?? '-'}',
                                          style: customTextStyle(
                                            fontStyle: FontStyle.BodyM_Bold,
                                            color: FontColor.FontSecondary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if ((item.deliveryType ?? '')
                                                .toUpperCase() ==
                                            'NOL')
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color:
                                                    customColors().dodgerBlue,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'NOL',
                                              style: customTextStyle(
                                                fontStyle: FontStyle.BodyS_Bold,
                                                color: FontColor.Info,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Price and Quantity inline
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Price: ',
                                              style: customTextStyle(
                                                fontStyle: FontStyle.BodyM_Bold,
                                                color: FontColor.FontPrimary,
                                              ),
                                            ),
                                            Text(
                                              (() {
                                                final p = item.price;
                                                if (p == null || p.isEmpty)
                                                  return 'QAR —';
                                                final n = num.tryParse(p);
                                                return 'QAR ${n != null ? n.toStringAsFixed(2) : p}';
                                              })(),
                                              style: customTextStyle(
                                                fontStyle: FontStyle.BodyM_Bold,
                                                color: FontColor.FontPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Quantity  ',
                                              style: customTextStyle(
                                                fontStyle: FontStyle.BodyM_Bold,
                                                color: FontColor.FontPrimary,
                                              ),
                                            ),
                                            Text(
                                              '${double.tryParse('${item.qtyOrdered ?? 0}')?.toInt() ?? 0}',
                                              style: customTextStyle(
                                                fontStyle: FontStyle.BodyM_Bold,
                                                color: FontColor.FontPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Quantity stepper + Scan Barcode button
                              item.itemStatus != "item_not_available"
                                  ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Row(
                                      children: [
                                        // Stepper (uses existing CounterButton styles)
                                        item.isProduce == true
                                            ? SizedBox()
                                            : SizedBox(
                                              width: 64,
                                              child: CounterDropdown(
                                                initNumber: 0,
                                                counterCallback: (v) {
                                                  setState(() {
                                                    editquantity = v;
                                                  });
                                                },
                                                minNumber: 0,
                                                maxNumber: 100,
                                                showLabel: false,
                                              ),
                                            ),
                                        const SizedBox(width: 12),
                                        // Scan barcode (green)
                                        !isKeyboard
                                            ? Expanded(
                                              child: InkWell(
                                                onTap: () async {
                                                  if (editquantity == 0 &&
                                                      (item.isProduce !=
                                                          true)) {
                                                    showSnackBar(
                                                      context: context,
                                                      snackBar: showErrorDialogue(
                                                        errorMessage:
                                                            'Please Confirm How Many Qty Picking...!',
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  var status =
                                                      await Permission
                                                          .camera
                                                          .status;
                                                  if (!status.isGranted) {
                                                    await requestCameraPermission();
                                                  }
                                                  // setState(() {
                                                  //   isScanner = !isScanner;
                                                  // });
                                                  _startScan();
                                                },
                                                child: Container(
                                                  height: 44,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        customColors()
                                                            .secretGarden,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Image.asset(
                                                        'assets/barcode_scan.png',
                                                        height: 18,
                                                        color: Colors.white,
                                                        errorBuilder:
                                                            (_, __, ___) =>
                                                                const SizedBox(),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'Scan Barcode',
                                                        style: customTextStyle(
                                                          fontStyle:
                                                              FontStyle
                                                                  .BodyM_Bold,
                                                          color:
                                                              FontColor.White,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                            : Expanded(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 5.0,
                                                    ),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey,
                                                  ),
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: TextFormField(
                                                  autofocus: true,
                                                  controller: barcodeController,
                                                  onFieldSubmitted: (v) {
                                                    setState(() {
                                                      isKeyboard = false;
                                                    });
                                                  },
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                            ),
                                      ],
                                    ),
                                  )
                                  : Container(),

                              isKeyboard
                                  ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0,
                                      vertical: 6.0,
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        scanBarcodeNormal(
                                          barcodeController.text.trim(),
                                        );
                                        // setState(() {
                                        //   isKeyboard = false;
                                        // });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0,
                                          vertical: 12.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: customColors().accent,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Submit',
                                            style: customTextStyle(
                                              fontStyle: FontStyle.BodyM_Bold,
                                              color: FontColor.FontPrimary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  : Container(),

                              const SizedBox(height: 16),

                              // Actions row
                              item.itemStatus != "item_not_available"
                                  ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 10.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Actions',
                                          style: customTextStyle(
                                            fontStyle: FontStyle.BodyM_Bold,
                                            color: FontColor.FontPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            // Replace
                                            Expanded(
                                              child: SizedBox(
                                                height: 88,
                                                child: ActionChips(
                                                  label1: 'Replace',
                                                  label2: 'Item',
                                                  color:
                                                      customColors()
                                                          .backgroundSecondary,
                                                  textColor:
                                                      customColors().dodgerBlue,
                                                  borderColor:
                                                      customColors().dodgerBlue,
                                                  asset: Icons.swap_horiz,
                                                  onTap: () {
                                                    // Navigate to replacement flow if available in existing app
                                                    // Keeping as no-op if not wired in this screen yet.
                                                    context.gNavigationService
                                                        .openOrderItemReplacementPage(
                                                          context,
                                                          arg: {
                                                            'item': item,
                                                            'preparationId':
                                                                widget
                                                                    .data['preparationLabel'],
                                                          },
                                                        );
                                                  },
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Hold
                                            Expanded(
                                              child: SizedBox(
                                                height: 88,
                                                child: ActionChips(
                                                  label1: 'Hold',
                                                  label2: 'Item',
                                                  color:
                                                      customColors()
                                                          .backgroundSecondary,
                                                  textColor:
                                                      customColors().dodgerBlue,
                                                  borderColor:
                                                      customColors().dodgerBlue,
                                                  asset: Icons.pause,
                                                  // onTap: () {
                                                  //   // Placeholder for hold logic
                                                  //   context
                                                  //       .read<
                                                  //         OrderItemDetailsCubit
                                                  //       >()
                                                  //       .updateitemstatus(
                                                  //         'holded',
                                                  //         '${item.qtyOrdered ?? 0}',
                                                  //         '',
                                                  //         item.price ?? '0',
                                                  //         widget
                                                  //             .data['preparationLabel'],
                                                  //         item.sku ?? '',
                                                  //       );
                                                  // },
                                                  onTap: () {
                                                    final reasonController =
                                                        TextEditingController();

                                                    showModalBottomSheet(
                                                      context: context,
                                                      isScrollControlled: true,
                                                      shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                              top:
                                                                  Radius.circular(
                                                                    16,
                                                                  ),
                                                            ),
                                                      ),
                                                      builder: (ctx) {
                                                        return Padding(
                                                          padding: EdgeInsets.only(
                                                            bottom:
                                                                MediaQuery.of(
                                                                      ctx,
                                                                    )
                                                                    .viewInsets
                                                                    .bottom,
                                                            left: 16,
                                                            right: 16,
                                                            top: 16,
                                                          ),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Hold item?',
                                                                style: customTextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .BodyL_Bold,
                                                                  color:
                                                                      FontColor
                                                                          .FontPrimary,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              TextField(
                                                                controller:
                                                                    reasonController,
                                                                maxLines: 3,
                                                                decoration:
                                                                    const InputDecoration(
                                                                      labelText:
                                                                          'Reason',
                                                                      border:
                                                                          OutlineInputBorder(),
                                                                    ),
                                                              ),
                                                              const SizedBox(
                                                                height: 12,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () =>
                                                                            Navigator.of(
                                                                              ctx,
                                                                            ).pop(),
                                                                    child: const Text(
                                                                      'Cancel',
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  ElevatedButton(
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor:
                                                                          customColors()
                                                                              .primary,
                                                                    ),
                                                                    onPressed: () {
                                                                      final reason =
                                                                          reasonController
                                                                              .text
                                                                              .trim();
                                                                      if (reason
                                                                          .isEmpty) {
                                                                        showSnackBar(
                                                                          context:
                                                                              context,
                                                                          snackBar: showErrorDialogue(
                                                                            errorMessage:
                                                                                'Please enter a reason',
                                                                          ),
                                                                        );
                                                                        return;
                                                                      }

                                                                      Navigator.of(
                                                                        ctx,
                                                                      ).pop(); // close bottom sheet

                                                                      context
                                                                          .read<
                                                                            OrderItemDetailsCubit
                                                                          >()
                                                                          .updateitemstatus(
                                                                            'holded',
                                                                            '${item.qtyOrdered ?? 0}',
                                                                            reason, // <‑ pass reason
                                                                            item.price ??
                                                                                '0',
                                                                            widget.data['preparationLabel'],
                                                                            '', // scannedSku (if unused)
                                                                          );
                                                                    },
                                                                    child: const Text(
                                                                      'Submit',
                                                                      style: TextStyle(
                                                                        color:
                                                                            Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 50,
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Not Available
                                            Expanded(
                                              child: SizedBox(
                                                height: 88,
                                                child: ActionChips(
                                                  label1: 'Not',
                                                  label2: 'Available',
                                                  color: HexColor('#FFF1F1'),
                                                  textColor:
                                                      customColors()
                                                          .carnationRed,
                                                  borderColor:
                                                      Colors.transparent,
                                                  asset: Icons.close,
                                                  // onTap: () {
                                                  //   context
                                                  //       .read<
                                                  //         OrderItemDetailsCubit
                                                  //       >()
                                                  //       .updateitemstatus(
                                                  //         'item_not_available',
                                                  //         '${item.qtyOrdered ?? 0}',
                                                  //         '',
                                                  //         item.price ?? '0',
                                                  //         widget
                                                  //             .data['preparationLabel'],
                                                  //         item.sku ?? '',
                                                  //       );
                                                  // },
                                                  onTap: () {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      isScrollControlled: true,
                                                      shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                              top:
                                                                  Radius.circular(
                                                                    16,
                                                                  ),
                                                            ),
                                                      ),
                                                      builder: (ctx) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets.fromLTRB(
                                                                16,
                                                                16,
                                                                16,
                                                                24,
                                                              ),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Mark item as not available?',
                                                                style: customTextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .BodyL_Bold,
                                                                  color:
                                                                      FontColor
                                                                          .FontPrimary,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 8,
                                                              ),
                                                              Text(
                                                                'This will move the item to the Not Available list.',
                                                                style: customTextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .BodyS_Regular,
                                                                  color:
                                                                      FontColor
                                                                          .FontSecondary,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 16,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () =>
                                                                            Navigator.of(
                                                                              ctx,
                                                                            ).pop(),
                                                                    child: const Text(
                                                                      'Cancel',
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  ElevatedButton(
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor:
                                                                          customColors()
                                                                              .primary,
                                                                    ),
                                                                    onPressed: () {
                                                                      Navigator.of(
                                                                        ctx,
                                                                      ).pop(); // close sheet

                                                                      context
                                                                          .read<
                                                                            OrderItemDetailsCubit
                                                                          >()
                                                                          .updateitemstatus(
                                                                            'item_not_available',
                                                                            '${item.qtyOrdered ?? 0}',
                                                                            '', // reason (empty or add later)
                                                                            item.price ??
                                                                                '0',
                                                                            widget.data['preparationLabel'],
                                                                            item.sku ??
                                                                                '',
                                                                          );
                                                                    },
                                                                    child: const Text(
                                                                      'Confirm',
                                                                      style: TextStyle(
                                                                        color:
                                                                            Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Cancel Item
                                            Expanded(
                                              child: SizedBox(
                                                height: 88,
                                                child: ActionChips(
                                                  label1: 'Cancel',
                                                  label2: 'Item',
                                                  color: Colors.white,
                                                  textColor:
                                                      customColors()
                                                          .carnationRed,
                                                  borderColor:
                                                      customColors()
                                                          .carnationRed,
                                                  asset: Icons.cancel,
                                                  onTap: () {
                                                    context
                                                        .read<
                                                          OrderItemDetailsCubit
                                                        >()
                                                        .updateitemstatus(
                                                          'canceled',
                                                          '${item.qtyOrdered ?? 0}',
                                                          'cancelled_by_picker',
                                                          item.price ?? '0',
                                                          widget
                                                              .data['preparationLabel'],
                                                          item.sku ?? '',
                                                        );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                  : Container(),
                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      }

                      return Container();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: null,
    );
  }
}
