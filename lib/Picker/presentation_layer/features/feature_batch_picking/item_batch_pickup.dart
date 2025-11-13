import 'dart:developer';

import 'package:ansarlogistics/Picker/presentation_layer/features/feature_batch_picking/bloc/item_batch_pickup_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_batch_picking/bloc/item_batch_pickup_state.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/counter_button.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_scankit/flutter_scankit.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';

class ItemBatchPickup extends StatefulWidget {
  final Map<String, dynamic> data;
  const ItemBatchPickup({super.key, required this.data});

  @override
  State<ItemBatchPickup> createState() => _ItemBatchPickupState();
}

class _ItemBatchPickupState extends State<ItemBatchPickup> {
  int selectedindex = 0;

  int editquantity = 0;

  bool loading = false;

  bool ismanual = false;

  bool pricechange = false;

  bool isScanner = false;

  bool isKeyboard = false;

  TextEditingController barcodeController = TextEditingController();

  late final ScanKit scanKit;
  String result = '';

  @override
  void initState() {
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
      // log(widget.data['items_data'].toString());

      final item = widget.data['items_data'];

      GroupedProduct groupedProduct = item;

      log(groupedProduct.sku.toString());

      if (barcodeScanRes != null) {
        context.read<ItemBatchPickupCubit>().checkitemdb(
          "",
          barcodeScanRes,
          groupedProduct.sku!,
          "pick",
          context,
          groupedProduct.itemIds,
          "",
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(errorMessage: e.toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              horizontal: 15.0,
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
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Text(
                          "Batch Pickup",
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
                  BlocConsumer<ItemBatchPickupCubit, ItemBatchPickupState>(
                    listener: (context, state) {},
                    builder: (context, state) {
                      if (state is ItemBatchPickupLoadedState) {
                        final item = state.item;

                        return Container(
                          color: Colors.white,
                          child: Column(
                            children: [
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

                                    String resolve(String p) {
                                      if (p.startsWith('http')) return p;
                                      if (p.startsWith('/'))
                                        p = p.substring(
                                          1,
                                        ); // Remove leading slash if present
                                      final baseUrl = base?.trim() ?? '';
                                      if (baseUrl.isEmpty) {
                                        debugPrint(
                                          'Warning: Empty base URL when resolving image path: $p',
                                        );
                                        return p; // Return the path as is if no base URL is available
                                      }
                                      return baseUrl.endsWith('/')
                                          ? '$baseUrl$p'
                                          : '$baseUrl/$p';
                                    }

                                    final List<String> imageUrls =
                                        item.productImages!
                                            .split(',')
                                            .map((e) => e.trim())
                                            .toList();

                                    final String mainUrl =
                                        imageUrls.isNotEmpty
                                            ? resolve(imageUrls[selectedindex])
                                            : '';

                                    log(mainUrl);

                                    return SizedBox(
                                      height: 275.0,
                                      width: 275.0,
                                      child: Center(
                                        child: CachedNetworkImage(
                                          imageUrl: mainUrl,
                                          placeholder:
                                              (context, url) => Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                          errorWidget:
                                              (context, url, error) =>
                                                  Icon(Icons.error),
                                          imageBuilder: (
                                            context,
                                            imageProvider,
                                          ) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                ),
                                              ),
                                            );
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
                                            if ((item.productImages ?? '')
                                                .isNotEmpty) {
                                              acc.addAll(
                                                item.productImages!
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
                                                  // context
                                                  //     .read<
                                                  //       OrderItemDetailsCubit
                                                  //     >()
                                                  //     .searchOnGoogle(
                                                  //       "${item.name ?? item.sku ?? ''} images",
                                                  //     );
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
                                            fontStyle: FontStyle.BodyS_Regular,
                                            color: FontColor.FontSecondary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
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
                                                return 'QAR ${p}';
                                              })(),
                                              style: customTextStyle(
                                                fontStyle: FontStyle.BodyL_Bold,
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
                                              '${double.tryParse('${item.totalQuantity ?? 0}')?.toInt() ?? 0}',
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

                              item.itemStatus != "item_not_available"
                                  ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        !isKeyboard
                                            ? Expanded(
                                              child: InkWell(
                                                onTap: () async {
                                                  var status =
                                                      await Permission
                                                          .camera
                                                          .status;
                                                  if (!status.isGranted) {
                                                    await requestCameraPermission();
                                                  }
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
                                                  onTap: () {
                                                    // Placeholder for hold logic
                                                    // context
                                                    //     .read<
                                                    //       OrderItemDetailsCubit
                                                    //     >()
                                                    //     .updateitemstatus(
                                                    //       'holded',
                                                    //       '${item.qtyOrdered ?? 0}',
                                                    //       '',
                                                    //       item.price ?? '0',
                                                    //       widget
                                                    //           .data['preparationLabel'],
                                                    // );
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
                                                  onTap: () {
                                                    final item =
                                                        widget
                                                            .data['items_data'];

                                                    GroupedProduct
                                                    groupedProduct = item;

                                                    List<String> orderIds =
                                                        groupedProduct.orders
                                                            .map(
                                                              (order) =>
                                                                  order.orderId,
                                                            )
                                                            .toList();

                                                    context
                                                        .read<
                                                          ItemBatchPickupCubit
                                                        >()
                                                        .showItemNotAvailableConfirmation(
                                                          context,
                                                          groupedProduct
                                                              .itemIds,
                                                          groupedProduct.name!,
                                                          'item_not_available',
                                                          groupedProduct.sku!,
                                                          orderIds,
                                                          "",
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
                                                    // context
                                                    //     .read<
                                                    //       OrderItemDetailsCubit
                                                    //     >()
                                                    //     .updateitemstatus(
                                                    //       'canceled',
                                                    //       '${item.qtyOrdered ?? 0}',
                                                    //       'cancelled_by_picker',
                                                    //       item.price ?? '0',
                                                    //       widget
                                                    //           .data['preparationLabel'],
                                                    //     );
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
    );
  }
}
