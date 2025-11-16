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
import 'package:flutter_scankit/flutter_scankit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:picker_driver_api/responses/order_response.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';

class ItemReplacementPage extends StatefulWidget {
  OrderItemNew itemdata;
  ItemReplacementPage({super.key, required this.itemdata});

  @override
  State<ItemReplacementPage> createState() => _ItemReplacementPageState();
}

class _ItemReplacementPageState extends State<ItemReplacementPage> {
  String cancelreason = "Please Select Reason";

  TextEditingController commentcontroller = TextEditingController();

  TextEditingController barcodeController = new TextEditingController();

  late GlobalKey<FormState> idFormKey = GlobalKey<FormState>();

  final _scankit = ScanKit();

  int selectedindex = -1;

  bool loading = false;

  int editquantity = 0;

  bool isScanner = false;

  bool producebarcode = false;

  bool istextbarcode = false;

  late final ScanKit scanKit;

  String result = '';

  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

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

  Future<void> scanBarcodeNormal(String barcodeScanRes) async {
    try {
      // print("${barcodeScanRes} asdfasdfasdfasdfsadasdf");
      String productSku = widget.itemdata.sku!;

      // final cubit = BlocProvider.of<OrderItemDetailsCubit>(context);
      // print("${cubit.orderItem?.productSku} cubit");

      String action = "replace";

      log("${barcodeScanRes} barcodeScanRes");

      // update barcode log
      // await BlocProvider.of<ItemReplacementPageCubit>(
      //   context,
      // ).updateBarcodeLog('', barcodeScanRes);

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
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(errorMessage: e.toString()),
      );
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
                      color: customColors().backgroundTertiary.withOpacity(1.0),
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
                            "Replace Item",
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _orderedItemCard(context),
                            const SizedBox(height: 12),
                            BlocBuilder<
                              ItemReplacementPageCubit,
                              ItemReplacementPageState
                            >(
                              builder: (context, state) {
                                final bool hideScan =
                                    state is ItemReplacementLoaded &&
                                    (state.productDBdata != null ||
                                        state.erPdata != null);
                                return hideScan
                                    ? const SizedBox.shrink()
                                    : _scanOrEnterSection(context);
                              },
                            ),
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
                                  String productSku = widget.itemdata.sku!;

                                  // final cubit = BlocProvider.of<OrderItemDetailsCubit>(context);
                                  // print("${cubit.orderItem?.productSku} cubit");

                                  String action = "replace";

                                  // update barcode log
                                  // BlocProvider.of<ItemReplacementPageCubit>(
                                  //   context,
                                  // ).updateBarcodeLog('', barcodeScanRes);

                                  // get scanned barcode data
                                  BlocProvider.of<ItemReplacementPageCubit>(
                                    context,
                                  ).getScannedProductData(
                                    barcodeController.text,
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
                                }

                                if (state is ItemReplacementLoaded) {
                                  // Compute ordered and replacement pricing for comparison
                                  final double orderedPrice = _safeToDouble(
                                    '${widget.itemdata.price ?? '0'}',
                                  );
                                  double? replacementPrice;
                                  String? repName;
                                  String? repSku;
                                  String? repImageUrl;

                                  Widget? productBlock;
                                  if (state.productDBdata != null) {
                                    final p = state.productDBdata!;
                                    replacementPrice = _safeToDouble(
                                      (p.specialPrice != null &&
                                              p.specialPrice
                                                  .toString()
                                                  .isNotEmpty)
                                          ? p.specialPrice.toString()
                                          : p.regularPrice.toString(),
                                    );
                                    repName = p.skuName;
                                    repSku = p.sku;
                                    if ((p.images ?? '').isNotEmpty) {
                                      final imgPath = getFirstImage(p.images);
                                      repImageUrl = resolveImageUrl(imgPath);
                                    }
                                    productBlock = const SizedBox.shrink();
                                  } else if (state.erPdata != null) {
                                    final e = state.erPdata!;
                                    replacementPrice = _safeToDouble(
                                      e.erpPrice,
                                    );
                                    repName = e.erpProductName;
                                    repSku = e.erpSku;
                                    repImageUrl = noimageurl;
                                    productBlock = ErpDataContainer(
                                      erPdata: state.erPdata,
                                      counterCallback: (p0) {
                                        setState(() => editquantity = p0);
                                      },
                                    );
                                  }

                                  if (replacementPrice != null &&
                                      productBlock != null) {
                                    final diff =
                                        replacementPrice - orderedPrice;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // Replacement product detail with quantity (existing blocks)
                                        productBlock,
                                        const SizedBox(height: 12),
                                        // Price comparison card
                                        _priceComparisonCard(
                                          orderedPrice: orderedPrice,
                                          replacementPrice: replacementPrice,
                                        ),
                                        const SizedBox(height: 12),
                                        // Compact replacement item card
                                        if (repName != null && repSku != null)
                                          _replacementCompactCard(
                                            name: repName!,
                                            sku: repSku!,
                                            price: replacementPrice,
                                            imageUrl: repImageUrl,
                                          ),
                                        const SizedBox(height: 12),
                                        _quantitySelector(),
                                        const SizedBox(height: 16),
                                        // Reason selector
                                        _reasonSelector(
                                          selected: cancelreason,
                                          onChanged: (val) {
                                            setState(() => cancelreason = val);
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                        // Bill adjustment summary
                                        _billAdjustmentCard(
                                          orderedPrice: orderedPrice,
                                          replacementPrice: replacementPrice,
                                          difference: diff,
                                        ),
                                      ],
                                    );
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 250.0),
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
        },
      ),
      bottomNavigationBar: SizedBox(
        height: 96,
        child: BlocBuilder<ItemReplacementPageCubit, ItemReplacementPageState>(
          builder: (context, state) {
            final isLoaded =
                state is ItemReplacementLoaded &&
                (state.erPdata != null || state.productDBdata != null);
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Divider(
                  thickness: 1.0,
                  color: customColors().backgroundTertiary,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Row(
                    children: [
                      // Cancel
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              () => context.gNavigationService.back(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: customColors().fontSecondary,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'Cancel',
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyM_Bold,
                              color: FontColor.FontPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Confirm
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              isLoaded
                                  ? () {
                                    // Reason is mandatory: guard if not selected
                                    if (cancelreason ==
                                        'Please Select Reason') {
                                      showSnackBar(
                                        context: context,
                                        snackBar: showErrorDialogue(
                                          errorMessage: 'Please select reason',
                                        ),
                                      );
                                      return;
                                    }
                                    // Reuse existing add-to-basket logic when a product is loaded
                                    final st = state as ItemReplacementLoaded;
                                    setState(() => loading = true);
                                    if (context
                                            .read<ItemReplacementPageCubit>()
                                            .erPdata !=
                                        null) {
                                      final erp =
                                          context
                                              .read<ItemReplacementPageCubit>()
                                              .erPdata!;
                                      context
                                          .read<ItemReplacementPageCubit>()
                                          .updatereplacement(
                                            selectedindex,
                                            erp.erpProductName,
                                            cancelreason,
                                            (editquantity == 0
                                                ? 1
                                                : editquantity),
                                            context,
                                            erp.erpPrice.toString(),
                                            erp.erpPrice.toString(),
                                            erp.erpPrice.toString(),
                                            erp.erpSku,
                                            barcodeController.text,
                                            (context
                                                        .read<
                                                          ItemReplacementPageCubit
                                                        >()
                                                        .productDBdata
                                                        ?.isProduce ??
                                                    '')
                                                .toString(),
                                            erp.erpId.toString(),
                                          );
                                    } else if (context
                                            .read<ItemReplacementPageCubit>()
                                            .productDBdata !=
                                        null) {
                                      final product =
                                          context
                                              .read<ItemReplacementPageCubit>()
                                              .productDBdata!;
                                      final priceToUse =
                                          product.specialPrice != ""
                                              ? product.specialPrice.toString()
                                              : product.regularPrice.toString();
                                      context
                                          .read<ItemReplacementPageCubit>()
                                          .updatereplacement(
                                            selectedindex,
                                            product.skuName.toString(),
                                            cancelreason,
                                            (editquantity == 0
                                                ? 1
                                                : editquantity),
                                            context,
                                            priceToUse,
                                            product.erpCurrentPrice,
                                            product.regularPrice,
                                            product.sku.toString(),
                                            barcodeController.text,
                                            (product.isProduce ?? '0')
                                                .toString(),
                                            product.productId.toString(),
                                          );
                                    }
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isLoaded
                                    ? customColors().fontPrimary
                                    : Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'Confirm',
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyM_Bold,
                              color:
                                  isLoaded
                                      ? FontColor.White
                                      : FontColor.FontSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- UI helpers to match new design ---
  Widget _orderedItemCard(BuildContext context) {
    final String name = widget.itemdata.name ?? '-';
    final String sku = widget.itemdata.sku ?? '-';
    final String priceStr = widget.itemdata.price?.toString() ?? '';
    final int qty = int.tryParse('${widget.itemdata.qtyOrdered ?? '1'}') ?? 1;

    final rawImg = widget.itemdata.productImage;
    final imgPath =
        (rawImg == null || rawImg.isEmpty) ? '' : getFirstImage(rawImg);
    final resolved = resolveImageUrl(imgPath);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: customColors().backgroundTertiary),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: customColors().backgroundSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.network(resolved, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyM_Bold,
                    color: FontColor.FontPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SKU: $sku',
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyS_Regular,
                    color: FontColor.FontSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                if (priceStr.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: HexColor('#E8F4FF'),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: HexColor('#2D7EFF')),
                    ),
                    child: Text(
                      'QAR ${num.tryParse(priceStr)?.toStringAsFixed(2) ?? priceStr}',
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyS_Bold,
                        color: FontColor.Info,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: HexColor('#FFE9E0'),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$qty',
              style: customTextStyle(
                fontStyle: FontStyle.BodyM_Bold,
                color: FontColor.FontPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scanOrEnterSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Scan or enter barcode to add replacement item',
          style: customTextStyle(
            fontStyle: FontStyle.BodyM_Bold,
            color: FontColor.FontPrimary,
          ),
        ),
        const SizedBox(height: 10),
        // Scan button (subtle)
        SizedBox(
          height: 44,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              var status = await Permission.camera.status;
              if (!status.isGranted) {
                await requestCameraPermission();
              }
              // setState(() => isScanner = true);
              _startScan();
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan Barcode'),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'OR',
            style: customTextStyle(
              fontStyle: FontStyle.BodyM_Bold,
              color: FontColor.FontSecondary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Enter product barcode',
          style: customTextStyle(
            fontStyle: FontStyle.BodyS_Regular,
            color: FontColor.FontSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: barcodeController,
          decoration: InputDecoration(
            hintText: 'Type here...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final productSku = widget.itemdata.sku!;
              await context
                  .read<ItemReplacementPageCubit>()
                  .getScannedProductData(
                    barcodeController.text,
                    producebarcode,
                    productSku,
                    'replace',
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: HexColor('#4C6EF5'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Submit barcode',
              style: customTextStyle(
                fontStyle: FontStyle.BodyM_Bold,
                color: FontColor.White,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Parses a string to double safely
  double _safeToDouble(String s) {
    return double.tryParse(s.trim()) ?? 0.0;
  }

  // Price comparison card
  Widget _priceComparisonCard({
    required double orderedPrice,
    required double replacementPrice,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: HexColor('#D9E6FF')),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.price_change, color: HexColor('#E91E63')),
              const SizedBox(width: 8),
              Text(
                'Price Comparison',
                style: customTextStyle(
                  fontStyle: FontStyle.BodyM_Bold,
                  color: FontColor.FontPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _chipPrice('Ordered price', orderedPrice, HexColor('#2D7EFF')),
              const Icon(Icons.arrow_forward, color: Colors.grey),
              _chipPrice(
                'Replacement price',
                replacementPrice,
                HexColor('#E91E63'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chipPrice(String label, double price, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: customTextStyle(
            fontStyle: FontStyle.BodyS_Regular,
            color: FontColor.FontSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color),
          ),
          child: Text(
            'QAR ${price.toStringAsFixed(2)}',
            style: customTextStyle(
              fontStyle: FontStyle.BodyS_Bold,
              color: FontColor.Info,
            ),
          ),
        ),
      ],
    );
  }

  // Compact replacement item card
  Widget _replacementCompactCard({
    required String name,
    required String sku,
    required double price,
    String? imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: customColors().backgroundTertiary),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: customColors().backgroundSecondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                (imageUrl == null || imageUrl.isEmpty)
                    ? const Icon(Icons.image, color: Colors.grey)
                    : Image.network(imageUrl, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyM_Bold,
                    color: FontColor.FontPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SKU: $sku',
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyS_Regular,
                    color: FontColor.FontSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: HexColor('#FFE0F0'),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'QAR ${price.toStringAsFixed(2)}',
              style: customTextStyle(
                fontStyle: FontStyle.BodyM_Bold,
                color: FontColor.Info,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Quantity selector UI
  Widget _quantitySelector() {
    final int displayQty = editquantity == 0 ? 1 : editquantity;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quantity',
            style: customTextStyle(
              fontStyle: FontStyle.BodyM_Bold,
              color: FontColor.FontPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Decrement
              SizedBox(
                height: 36,
                width: 36,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: BorderSide(color: customColors().backgroundTertiary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      final next = displayQty - 1;
                      editquantity = next < 1 ? 1 : next;
                    });
                  },
                  child: const Icon(Icons.remove, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              // Current qty box
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: customColors().backgroundTertiary),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Text(
                  '$displayQty',
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyM_Bold,
                    color: FontColor.FontPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Increment
              SizedBox(
                height: 36,
                width: 36,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: BorderSide(color: customColors().backgroundTertiary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      editquantity = displayQty + 1;
                    });
                  },
                  child: const Icon(Icons.add, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Reason selector
  Widget _reasonSelector({
    required String selected,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: customColors().backgroundTertiary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select a reason',
            style: customTextStyle(
              fontStyle: FontStyle.BodyM_Bold,
              color: FontColor.FontPrimary,
            ),
          ),
          const SizedBox(height: 8),
          RadioListTile<String>(
            value: 'Customer Suggestion',
            groupValue: selected,
            title: Text('Customer Suggestion'),
            onChanged: (v) => onChanged(v!),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<String>(
            value: 'Item out of stock',
            groupValue: selected,
            title: Text('Item out of stock'),
            onChanged: (v) => onChanged(v!),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  // Bill adjustment summary
  Widget _billAdjustmentCard({
    required double orderedPrice,
    required double replacementPrice,
    required double difference,
  }) {
    final isNegative = difference < 0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HexColor('#FFFBE6'),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: HexColor('#FFECB3')),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bill Adjustment',
            style: customTextStyle(
              fontStyle: FontStyle.BodyM_Bold,
              color: FontColor.FontPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _billRow('Ordered price', orderedPrice),
          _billRow('Replacement price', replacementPrice),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price Difference',
                style: customTextStyle(fontStyle: FontStyle.BodyM_Bold),
              ),
              Text(
                'QAR ${difference.toStringAsFixed(2)}',
                style: customTextStyle(
                  fontStyle: FontStyle.BodyM_Bold,
                  color: isNegative ? FontColor.Danger : FontColor.Success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _billRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: customTextStyle(
              fontStyle: FontStyle.BodyS_Regular,
              color: FontColor.FontSecondary,
            ),
          ),
          Text(
            'QAR ${value.toStringAsFixed(2)}',
            style: customTextStyle(
              fontStyle: FontStyle.BodyS_Bold,
              color: FontColor.FontPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
