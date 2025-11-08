import 'dart:developer';

import 'package:ansarlogistics/Picker/presentation_layer/features/feature_batch_picking/bloc/item_batch_pickup_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_batch_picking/bloc/item_batch_pickup_state.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ItemBatchPickup extends StatefulWidget {
  const ItemBatchPickup({super.key});

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

  MobileScannerController cameraController = MobileScannerController();

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

          if (isScanner)
            Expanded(
              child: MobileScanner(
                controller: cameraController,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    log('Barcode found! ${barcode.rawValue}');
                    //  scanBarcodeNormal(barcode.rawValue!);
                  }
                },
              ),
            )
          else
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
                                              ? resolve(
                                                imageUrls[selectedindex],
                                              )
                                              : '';

                                      // final String mainUrl = resolve(
                                      //   images[selectedindex.clamp(
                                      //     0,
                                      //     images.length - 1,
                                      //   )],
                                      // );

                                      // final qty = item.totalQuantity ?? 0;
                                      // final rawImg =
                                      //     item.productImages ?? item.imageUrl;

                                      log(mainUrl);
                                      // final imgPath =
                                      //     (rawImg == null || rawImg.isEmpty)
                                      //         ? ''
                                      //         : getFirstImage(rawImg);
                                      // final resolved = resolveImageUrl(imgPath);

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
                                                      .where(
                                                        (e) => e.isNotEmpty,
                                                      ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              fontStyle:
                                                  FontStyle.BodyS_Regular,
                                              color: FontColor.FontSecondary,
                                            ),
                                          ),
                                          const SizedBox(width: 8),

                                          // if ((item.deliveryType ?? '')
                                          //         .toUpperCase() ==
                                          //     'NOL')
                                          //   Container(
                                          //     padding:
                                          //         const EdgeInsets.symmetric(
                                          //           horizontal: 6,
                                          //           vertical: 2,
                                          //         ),
                                          //     decoration: BoxDecoration(
                                          //       border: Border.all(
                                          //         color:
                                          //             customColors().dodgerBlue,
                                          //       ),
                                          //       borderRadius:
                                          //           BorderRadius.circular(6),
                                          //     ),
                                          //     child: Text(
                                          //       'NOL',
                                          //       style: customTextStyle(
                                          //         fontStyle:
                                          //             FontStyle.BodyS_Bold,
                                          //         color: FontColor.Info,
                                          //       ),
                                          //     ),
                                          //   ),
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
                                                  fontStyle:
                                                      FontStyle.BodyM_Bold,
                                                  color: FontColor.FontPrimary,
                                                ),
                                              ),
                                              Text(
                                                (() {
                                                  final p = item.price;
                                                  return 'QAR ${p}';
                                                })(),
                                                style: customTextStyle(
                                                  fontStyle:
                                                      FontStyle.BodyM_Bold,
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
                                                  fontStyle:
                                                      FontStyle.BodyM_Bold,
                                                  color: FontColor.FontPrimary,
                                                ),
                                              ),
                                              Text(
                                                '${double.tryParse('${item.totalQuantity ?? 0}')?.toInt() ?? 0}',
                                                style: customTextStyle(
                                                  fontStyle:
                                                      FontStyle.BodyM_Bold,
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

                                //  item. != "item_not_available"
                                //       ? Padding(
                                //         padding: const EdgeInsets.symmetric(
                                //           horizontal: 16.0,
                                //         ),
                                //         child: Row(
                                //           children: [
                                //             // Stepper (uses existing CounterButton styles)
                                //             item.isProduce == true
                                //                 ? SizedBox()
                                //                 : SizedBox(
                                //                   width: 64,
                                //                   child: CounterDropdown(
                                //                     initNumber: 0,
                                //                     counterCallback: (v) {
                                //                       setState(() {
                                //                         editquantity = v;
                                //                       });
                                //                     },
                                //                     minNumber: 0,
                                //                     maxNumber: 100,
                                //                     showLabel: false,
                                //                   ),
                                //                 ),
                                //             const SizedBox(width: 12),
                                //             // Scan barcode (green)
                                //             !isKeyboard
                                //                 ? Expanded(
                                //                   child: InkWell(
                                //                     onTap: () async {
                                //                       if (editquantity == 0 &&
                                //                           (item.isProduce !=
                                //                               true)) {
                                //                         showSnackBar(
                                //                           context: context,
                                //                           snackBar: showErrorDialogue(
                                //                             errorMessage:
                                //                                 'Please Confirm How Many Qty Picking...!',
                                //                           ),
                                //                         );
                                //                         return;
                                //                       }
                                //                       var status =
                                //                           await Permission
                                //                               .camera
                                //                               .status;
                                //                       if (!status.isGranted) {
                                //                         await requestCameraPermission();
                                //                       }
                                //                       setState(() {
                                //                         isScanner = !isScanner;
                                //                       });
                                //                     },
                                //                     child: Container(
                                //                       height: 44,
                                //                       decoration: BoxDecoration(
                                //                         color:
                                //                             customColors()
                                //                                 .secretGarden,
                                //                         borderRadius:
                                //                             BorderRadius.circular(
                                //                               8,
                                //                             ),
                                //                       ),
                                //                       child: Row(
                                //                         mainAxisAlignment:
                                //                             MainAxisAlignment
                                //                                 .center,
                                //                         children: [
                                //                           Image.asset(
                                //                             'assets/barcode_scan.png',
                                //                             height: 18,
                                //                             color: Colors.white,
                                //                             errorBuilder:
                                //                                 (_, __, ___) =>
                                //                                     const SizedBox(),
                                //                           ),
                                //                           const SizedBox(
                                //                             width: 8,
                                //                           ),
                                //                           Text(
                                //                             'Scan Barcode',
                                //                             style: customTextStyle(
                                //                               fontStyle:
                                //                                   FontStyle
                                //                                       .BodyM_Bold,
                                //                               color:
                                //                                   FontColor.White,
                                //                             ),
                                //                           ),
                                //                         ],
                                //                       ),
                                //                     ),
                                //                   ),
                                //                 )
                                //                 : Expanded(
                                //                   child: Container(
                                //                     padding:
                                //                         const EdgeInsets.symmetric(
                                //                           horizontal: 5.0,
                                //                         ),
                                //                     decoration: BoxDecoration(
                                //                       border: Border.all(
                                //                         color: Colors.grey,
                                //                       ),
                                //                       color: Colors.white,
                                //                       borderRadius:
                                //                           BorderRadius.circular(
                                //                             10,
                                //                           ),
                                //                     ),
                                //                     child: TextFormField(
                                //                       autofocus: true,
                                //                       onFieldSubmitted: (v) {
                                //                         setState(() {
                                //                           isKeyboard = false;
                                //                         });
                                //                       },
                                //                       decoration: InputDecoration(
                                //                         border: InputBorder.none,
                                //                       ),
                                //                     ),
                                //                   ),
                                //                 ),
                                //           ],
                                //         ),
                                //       )
                                //       : Container(),
                                //   const SizedBox(height: 16),
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
