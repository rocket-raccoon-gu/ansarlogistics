import 'dart:convert';
import 'dart:developer';

import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/common_features/feature_scan_barcode/bloc/new_scan_barcode_page_cubit.dart';
import 'package:ansarlogistics/common_features/feature_scan_barcode/bloc/new_scan_barcode_page_state.dart';
import 'package:ansarlogistics/components/custom_app_components/app_bar/custom_app_bar.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:camera/camera.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:picker_driver_api/responses/product_response.dart';

class NewScanBarcodePage extends StatefulWidget {
  final ServiceLocator serviceLocator;
  NewScanBarcodePage({super.key, required this.serviceLocator});

  @override
  State<NewScanBarcodePage> createState() => _NewScanBarcodePageState();
}

class _NewScanBarcodePageState extends State<NewScanBarcodePage>
    with WidgetsBindingObserver {
  String _scanBarcode = 'Unknown';
  bool stock_stat = false;
  late CarouselSliderController _sliderController;
  ProductResponse? _productResponse;

  List<String> barcodelist = [];

  late CameraController _cameraController;

  bool isScan = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _sliderController = CarouselSliderController();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.status;

    if (status.isGranted) {
      // print("Camera permission already granted.");
      return; // No need to request again
    }

    var newStatus = await Permission.camera.request();
    if (newStatus.isDenied || newStatus.isPermanentlyDenied) {
      openAppSettings(); // Redirect user to app settings
    }
  }

  Future<void> scanBarcodeNormal(BuildContext ctx) async {
    String? barcodescanRes;

    try {
      await requestCameraPermission();

      ScanResult scanResult = await BarcodeScanner.scan();
      setState(() {
        barcodescanRes = scanResult.rawContent;
      });

      log(barcodescanRes!);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          barcodescanRes = 'Camera permission was denied';
        });
      } else {
        setState(() {
          barcodescanRes = 'Unknown error: $e';
        });
      }
    } on FormatException {
      setState(() {
        barcodescanRes = 'Nothing captured.';
      });
    } catch (e) {
      setState(() {
        barcodescanRes = 'Unknown error: $e';
      });
    }

    // // if (!mounted) return;

    if (barcodescanRes == "" || barcodescanRes == "-1") {
      // ignore: use_build_context_synchronously
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "Item Not Scanned Properly Retry...!",
        ),
      );
      return;
    }

    try {
      //   // ignore: use_build_context_synchronously
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0, bottom: 25.0),
                    child: Text(
                      "Fetching data....!",
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyL_Bold,
                        color: FontColor.FontPrimary,
                      ),
                    ),
                  ),
                  Lottie.asset('assets/lottie_files/loading.json'),
                ],
              ),
            ),
          );
        },
      );

      String? token = await PreferenceUtils.getDataFromShared("usertoken");

      String response = await widget.serviceLocator.tradingApi
          .checkbarcodeavailablity(sku: barcodescanRes!);

      log(response);

      Map<String, dynamic> mdata = jsonDecode(response);

      if (mdata['success'] == 1) {
        Navigator.pop(context);

        showGeneralDialog(
          context: context,
          pageBuilder: (context, animation, secondaryanimation) {
            return Container();
          },
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            var curves = Curves.easeInOut.transform(animation.value);

            return Transform.scale(
              scale: curves,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Lottie.asset(
                    //   'assets/animation_list.json',
                    //   height: 100.0,
                    // ),
                    Text(
                      barcodescanRes!.toString(),
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyM_Bold,
                        color: FontColor.FontPrimary,
                      ),
                    ),
                    Text(
                      "Barcode Already Scanned on ${mdata['data']['date']}",
                      style: customTextStyle(fontStyle: FontStyle.BodyL_Bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "Product Upload in Processing...",
                      style: customTextStyle(fontStyle: FontStyle.BodyL_Bold),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 10.0,
                              ),
                              decoration: BoxDecoration(
                                color: customColors().carnationRed,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Center(
                                child: Text(
                                  "OK",
                                  style: customTextStyle(
                                    fontStyle: FontStyle.BodyM_Bold,
                                    color: FontColor.White,
                                  ),
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
            );
          },
        );
      } else {
        final productresponse = await widget.serviceLocator.tradingApi
            .generalProductServiceGet(
              endpoint: barcodescanRes!,
              token11: token!,
            );

        Map<String, dynamic> data = jsonDecode(productresponse.body);

        if (!data.containsKey('message')) {
          Navigator.pop(context);

          log(productresponse.body);

          setState(() {
            _productResponse = ProductResponse.fromJson(data);
          });

          showGeneralDialog(
            context: context,
            pageBuilder: (context, animation, secondaryanimation) {
              return Container();
            },
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              var curves = Curves.easeInOut.transform(animation.value);

              return Transform.scale(
                scale: curves,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  content: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Lottie.asset('assets/animation_list.json', height: 100.0),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                height: 90.0,
                                width: 90.0,
                                child:
                                    _productResponse!
                                            .mediaGalleryEntries
                                            .isEmpty
                                        ? Image.asset('assets/placeholder.png')
                                        : InkWell(
                                          onTap: () {
                                            getImageViewver(
                                              _productResponse!
                                                  .mediaGalleryEntries,
                                              context,
                                              _sliderController,
                                            );
                                          },
                                          child: Image.network(
                                            "${mainimageurl}${_productResponse!.mediaGalleryEntries[0].file}",
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: Text(
                                        _productResponse!.name,
                                        style: customTextStyle(
                                          fontStyle: FontStyle.BodyM_Bold,
                                          color: FontColor.FontPrimary,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 3.0,
                                      ),
                                      child: Text(
                                        "SKU: ${_productResponse!.sku}",
                                        style: customTextStyle(
                                          fontStyle: FontStyle.BodyM_Bold,
                                          color: FontColor.FontPrimary,
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

                      // Text(
                      //   barcodescanRes!.toString(),
                      //   style: customTextStyle(
                      //       fontStyle: FontStyle.BodyM_Bold,
                      //       color: FontColor.FontPrimary),
                      // ),
                      // Text(
                      //   "Barcode Already Scanned on ${mdata['data']['date']}",
                      //   style: customTextStyle(
                      //     fontStyle: FontStyle.BodyL_Bold,
                      //   ),
                      //   textAlign: TextAlign.center,
                      // ),
                      Text(
                        "Do you want to add ...?",
                        style: customTextStyle(fontStyle: FontStyle.BodyL_Bold),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 8.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: customColors().secretGarden,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Ok",
                                      style: customTextStyle(
                                        fontStyle: FontStyle.BodyM_Bold,
                                        color: FontColor.White,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  ctx.read<NewScanBarcodePageCubit>().addtolist(
                                    _productResponse!.sku,
                                    "",
                                    "",
                                    "",
                                  );

                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 8.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: customColors().islandAqua,
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Add This Item",
                                        style: customTextStyle(
                                          fontStyle: FontStyle.BodyM_Bold,
                                          color: FontColor.White,
                                        ),
                                      ),
                                    ),
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
              );
            },
          );
        } else {
          if (context
              .read<NewScanBarcodePageCubit>()
              .skulist
              .where((element) => element.containsValue(barcodescanRes))
              .isEmpty) {
            // ignore: use_build_context_synchronously
            ctx.read<NewScanBarcodePageCubit>().addtolist(
              barcodescanRes!,
              "",
              "",
              "",
            );

            // ignore: use_build_context_synchronously
            showGeneralDialog(
              context: context,
              pageBuilder: (context, animation, secondaryanimation) {
                return Container();
              },
              transitionBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                var curves = Curves.easeInOut.transform(animation.value);

                return Transform.scale(
                  scale: curves,
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Do you Want to Add More...?",
                          textAlign: TextAlign.center,
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyL_Bold,
                            color: FontColor.FontPrimary,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 8.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: customColors().carnationRed,
                                    ),
                                    child: Center(
                                      child: Center(
                                        child: Text(
                                          "No",
                                          style: customTextStyle(
                                            fontStyle: FontStyle.BodyM_Bold,
                                            color: FontColor.White,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    // ctx
                                    //     .read<NewScanBarcodePageCubit>()
                                    //     .addtolist(barcodescanRes);

                                    scanBarcodeNormal(ctx);

                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 8.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: customColors().secretGarden,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Yes",
                                          style: customTextStyle(
                                            fontStyle: FontStyle.BodyM_Bold,
                                            color: FontColor.White,
                                          ),
                                        ),
                                      ),
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
                );
              },
            );
          } else {
            showGeneralDialog(
              context: context,
              pageBuilder: (context, animation, secondaryanimation) {
                return Container();
              },
              transitionBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                var curves = Curves.easeInOut.transform(animation.value);

                return Transform.scale(
                  scale: curves,
                  child: AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          barcodescanRes.toString(),
                          textAlign: TextAlign.center,
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyL_Bold,
                            color: FontColor.FontPrimary,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "You Already Added This Barcode in List...!",
                            textAlign: TextAlign.center,
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyL_Bold,
                              color: FontColor.FontPrimary,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  context.gNavigationService.back(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 35.0,
                                    vertical: 8.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: customColors().carnationRed,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "OK",
                                      style: customTextStyle(
                                        fontStyle: FontStyle.BodyM_Bold,
                                        color: FontColor.White,
                                      ),
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
                );
              },
            );
          }
        }
      }

      // final productresponse = await widget.serviceLocator.tradingApi
      //     .getProductServiceGet(endpoint: barcodescanRes!, token11: token!);

      // if (productresponse.statusCode == 200) {
      //   //     //
      //   //     // Product Avaialable
      //   //     //
      //   Navigator.pop(context);
      //   Map<String, dynamic> data = jsonDecode(productresponse.body);

      //   log(productresponse.body);

      //   if (data.containsKey('message')) {
      //     //       // check barcode avilablity in db

      //     String response = await widget.serviceLocator.tradingApi
      //         .checkbarcodeavailablity(sku: barcodescanRes!);

      //     log(response);

      //     Map<String, dynamic> mdata = jsonDecode(response);

      //     if (mdata['success'] == 1) {
      //       // ignore: use_build_context_synchronously
      //       showGeneralDialog(
      //         context: context,
      //         pageBuilder: (context, animation, secondaryanimation) {
      //           return Container();
      //         },
      //         transitionBuilder: (
      //           context,
      //           animation,
      //           secondaryAnimation,
      //           child,
      //         ) {
      //           var curves = Curves.easeInOut.transform(animation.value);

      //           return Transform.scale(
      //             scale: curves,
      //             child: AlertDialog(
      //               shape: RoundedRectangleBorder(
      //                 borderRadius: BorderRadius.circular(8.0),
      //               ),
      //               content: Column(
      //                 mainAxisAlignment: MainAxisAlignment.center,
      //                 mainAxisSize: MainAxisSize.min,
      //                 children: [
      //                   // Lottie.asset(
      //                   //   'assets/animation_list.json',
      //                   //   height: 100.0,
      //                   // ),
      //                   Text(
      //                     barcodescanRes!.toString(),
      //                     style: customTextStyle(
      //                       fontStyle: FontStyle.BodyM_Bold,
      //                       color: FontColor.FontPrimary,
      //                     ),
      //                   ),
      //                   Text(
      //                     "Barcode Already Scanned on ${mdata['data']['date']}",
      //                     style: customTextStyle(
      //                       fontStyle: FontStyle.BodyL_Bold,
      //                     ),
      //                     textAlign: TextAlign.center,
      //                   ),
      //                   Text(
      //                     "Product Upload in Processing...",
      //                     style: customTextStyle(
      //                       fontStyle: FontStyle.BodyL_Bold,
      //                     ),
      //                     textAlign: TextAlign.center,
      //                   ),
      //                   Padding(
      //                     padding: const EdgeInsets.only(top: 12.0),
      //                     child: Row(
      //                       mainAxisAlignment: MainAxisAlignment.center,
      //                       children: [
      //                         InkWell(
      //                           onTap: () {
      //                             Navigator.pop(context);
      //                           },
      //                           child: Container(
      //                             padding: EdgeInsets.symmetric(
      //                               horizontal: 50,
      //                               vertical: 10.0,
      //                             ),
      //                             decoration: BoxDecoration(
      //                               color: customColors().carnationRed,
      //                               borderRadius: BorderRadius.circular(5.0),
      //                             ),
      //                             child: Center(
      //                               child: Text(
      //                                 "OK",
      //                                 style: customTextStyle(
      //                                   fontStyle: FontStyle.BodyM_Bold,
      //                                   color: FontColor.White,
      //                                 ),
      //                               ),
      //                             ),
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           );
      //         },
      //       );
      //     } else {
      //       //need to add

      //       // ignore: use_build_context_synchronously
      //       if (context
      //           .read<NewScanBarcodePageCubit>()
      //           .skulist
      //           .where((element) => element.containsValue(barcodescanRes))
      //           .isEmpty) {
      //         // adding to list

      //         // ignore: use_build_context_synchronously
      //         ctx.read<NewScanBarcodePageCubit>().addtolist(
      //           barcodescanRes!,
      //           "",
      //           "",
      //           "",
      //         );

      //         // ignore: use_build_context_synchronously
      //         showGeneralDialog(
      //           context: context,
      //           pageBuilder: (context, animation, secondaryanimation) {
      //             return Container();
      //           },
      //           transitionBuilder: (
      //             context,
      //             animation,
      //             secondaryAnimation,
      //             child,
      //           ) {
      //             var curves = Curves.easeInOut.transform(animation.value);

      //             return Transform.scale(
      //               scale: curves,
      //               child: AlertDialog(
      //                 shape: RoundedRectangleBorder(
      //                   borderRadius: BorderRadius.circular(8.0),
      //                 ),
      //                 content: Column(
      //                   mainAxisAlignment: MainAxisAlignment.center,
      //                   mainAxisSize: MainAxisSize.min,
      //                   children: [
      //                     Text(
      //                       "Do you Want to Add More...?",
      //                       textAlign: TextAlign.center,
      //                       style: customTextStyle(
      //                         fontStyle: FontStyle.BodyL_Bold,
      //                         color: FontColor.FontPrimary,
      //                       ),
      //                     ),
      //                     Padding(
      //                       padding: const EdgeInsets.only(top: 15.0),
      //                       child: Row(
      //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                         children: [
      //                           Expanded(
      //                             child: InkWell(
      //                               onTap: () {
      //                                 Navigator.pop(context);
      //                               },
      //                               child: Container(
      //                                 padding: const EdgeInsets.symmetric(
      //                                   horizontal: 8.0,
      //                                   vertical: 8.0,
      //                                 ),
      //                                 decoration: BoxDecoration(
      //                                   color: customColors().carnationRed,
      //                                 ),
      //                                 child: Center(
      //                                   child: Center(
      //                                     child: Text(
      //                                       "No",
      //                                       style: customTextStyle(
      //                                         fontStyle: FontStyle.BodyM_Bold,
      //                                         color: FontColor.White,
      //                                       ),
      //                                     ),
      //                                   ),
      //                                 ),
      //                               ),
      //                             ),
      //                           ),
      //                           Expanded(
      //                             child: InkWell(
      //                               onTap: () {
      //                                 // ctx
      //                                 //     .read<NewScanBarcodePageCubit>()
      //                                 //     .addtolist(barcodescanRes);

      //                                 scanBarcodeNormal(ctx);

      //                                 Navigator.pop(context);
      //                               },
      //                               child: Padding(
      //                                 padding: const EdgeInsets.only(left: 8.0),
      //                                 child: Container(
      //                                   padding: const EdgeInsets.symmetric(
      //                                     horizontal: 8.0,
      //                                     vertical: 8.0,
      //                                   ),
      //                                   decoration: BoxDecoration(
      //                                     color: customColors().secretGarden,
      //                                   ),
      //                                   child: Center(
      //                                     child: Text(
      //                                       "Yes",
      //                                       style: customTextStyle(
      //                                         fontStyle: FontStyle.BodyM_Bold,
      //                                         color: FontColor.White,
      //                                       ),
      //                                     ),
      //                                   ),
      //                                 ),
      //                               ),
      //                             ),
      //                           ),
      //                         ],
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //             );
      //           },
      //         );
      //       } else {
      //         // ignore: use_build_context_synchronously
      //         showGeneralDialog(
      //           context: context,
      //           pageBuilder: (context, animation, secondaryanimation) {
      //             return Container();
      //           },
      //           transitionBuilder: (
      //             context,
      //             animation,
      //             secondaryAnimation,
      //             child,
      //           ) {
      //             var curves = Curves.easeInOut.transform(animation.value);

      //             return Transform.scale(
      //               scale: curves,
      //               child: AlertDialog(
      //                 shape: RoundedRectangleBorder(
      //                   borderRadius: BorderRadius.circular(8.0),
      //                 ),
      //                 content: Column(
      //                   mainAxisAlignment: MainAxisAlignment.center,
      //                   mainAxisSize: MainAxisSize.min,
      //                   children: [
      //                     Text(
      //                       barcodescanRes.toString(),
      //                       textAlign: TextAlign.center,
      //                       style: customTextStyle(
      //                         fontStyle: FontStyle.BodyL_Bold,
      //                         color: FontColor.FontPrimary,
      //                       ),
      //                     ),
      //                     Padding(
      //                       padding: const EdgeInsets.only(top: 8.0),
      //                       child: Text(
      //                         "You Already Added This Barcode in List...!",
      //                         textAlign: TextAlign.center,
      //                         style: customTextStyle(
      //                           fontStyle: FontStyle.BodyL_Bold,
      //                           color: FontColor.FontPrimary,
      //                         ),
      //                       ),
      //                     ),
      //                     Padding(
      //                       padding: EdgeInsets.only(top: 10.0),
      //                       child: Row(
      //                         mainAxisAlignment: MainAxisAlignment.center,
      //                         children: [
      //                           InkWell(
      //                             onTap: () {
      //                               context.gNavigationService.back(context);
      //                             },
      //                             child: Container(
      //                               padding: const EdgeInsets.symmetric(
      //                                 horizontal: 35.0,
      //                                 vertical: 8.0,
      //                               ),
      //                               decoration: BoxDecoration(
      //                                 color: customColors().carnationRed,
      //                                 borderRadius: BorderRadius.circular(5.0),
      //                               ),
      //                               child: Center(
      //                                 child: Text(
      //                                   "OK",
      //                                   style: customTextStyle(
      //                                     fontStyle: FontStyle.BodyM_Bold,
      //                                     color: FontColor.White,
      //                                   ),
      //                                 ),
      //                               ),
      //                             ),
      //                           ),
      //                         ],
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //             );
      //           },
      //         );
      //       }
      //     }
      //   } else {
      //     setState(() {
      //       _productResponse = ProductResponse.fromJson(data);
      //     });

      //     // check barcode avilablity in db

      //     String response = await widget.serviceLocator.tradingApi
      //         .checkbarcodeavailablity(sku: barcodescanRes!);

      //     log(response);

      //     Map<String, dynamic> mdata = jsonDecode(response);

      //     if (mdata['success'] == 1) {
      //       // ignore: use_build_context_synchronously
      //       showGeneralDialog(
      //         context: context,
      //         pageBuilder: (context, animation, secondaryanimation) {
      //           return Container();
      //         },
      //         transitionBuilder: (
      //           context,
      //           animation,
      //           secondaryAnimation,
      //           child,
      //         ) {
      //           var curves = Curves.easeInOut.transform(animation.value);

      //           return Transform.scale(
      //             scale: curves,
      //             child: AlertDialog(
      //               shape: RoundedRectangleBorder(
      //                 borderRadius: BorderRadius.circular(8.0),
      //               ),
      //               content: Column(
      //                 mainAxisAlignment: MainAxisAlignment.center,
      //                 mainAxisSize: MainAxisSize.min,
      //                 children: [
      //                   // Lottie.asset('assets/animation_list.json', height: 100.0),
      //                   Padding(
      //                     padding: const EdgeInsets.only(top: 8.0),
      //                     child: Row(
      //                       children: [
      //                         Padding(
      //                           padding: const EdgeInsets.only(right: 8.0),
      //                           child: Container(
      //                             height: 90.0,
      //                             width: 90.0,
      //                             child:
      //                                 _productResponse!
      //                                         .mediaGalleryEntries
      //                                         .isEmpty
      //                                     ? Image.asset(
      //                                       'assets/placeholder.png',
      //                                     )
      //                                     : InkWell(
      //                                       onTap: () {
      //                                         getImageViewver(
      //                                           _productResponse!
      //                                               .mediaGalleryEntries,
      //                                           context,
      //                                           _sliderController,
      //                                         );
      //                                       },
      //                                       child: Image.network(
      //                                         "${mainimageurl}${_productResponse!.mediaGalleryEntries[0].file}",
      //                                         fit: BoxFit.contain,
      //                                       ),
      //                                     ),
      //                           ),
      //                         ),
      //                         Expanded(
      //                           child: Container(
      //                             child: Column(
      //                               mainAxisAlignment: MainAxisAlignment.center,
      //                               crossAxisAlignment:
      //                                   CrossAxisAlignment.start,
      //                               children: [
      //                                 Padding(
      //                                   padding: const EdgeInsets.symmetric(
      //                                     horizontal: 8.0,
      //                                   ),
      //                                   child: Text(
      //                                     _productResponse!.name,
      //                                     style: customTextStyle(
      //                                       fontStyle: FontStyle.BodyM_Bold,
      //                                       color: FontColor.FontPrimary,
      //                                     ),
      //                                   ),
      //                                 ),
      //                                 Padding(
      //                                   padding: const EdgeInsets.symmetric(
      //                                     horizontal: 8.0,
      //                                     vertical: 3.0,
      //                                   ),
      //                                   child: Text(
      //                                     "SKU: ${_productResponse!.sku}",
      //                                     style: customTextStyle(
      //                                       fontStyle: FontStyle.BodyM_Bold,
      //                                       color: FontColor.FontPrimary,
      //                                     ),
      //                                   ),
      //                                 ),
      //                               ],
      //                             ),
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                   ),

      //                   // Text(
      //                   //   barcodescanRes!.toString(),
      //                   //   style: customTextStyle(
      //                   //       fontStyle: FontStyle.BodyM_Bold,
      //                   //       color: FontColor.FontPrimary),
      //                   // ),
      //                   Text(
      //                     "Barcode Already Scanned on ${mdata['data']['date']}",
      //                     style: customTextStyle(
      //                       fontStyle: FontStyle.BodyL_Bold,
      //                     ),
      //                     textAlign: TextAlign.center,
      //                   ),
      //                   Text(
      //                     "Do you want to add it again...?",
      //                     style: customTextStyle(
      //                       fontStyle: FontStyle.BodyL_Bold,
      //                     ),
      //                     textAlign: TextAlign.center,
      //                   ),
      //                   Padding(
      //                     padding: const EdgeInsets.only(top: 10.0),
      //                     child: Row(
      //                       children: [
      //                         Expanded(
      //                           child: InkWell(
      //                             onTap: () {
      //                               Navigator.pop(context);
      //                             },
      //                             child: Container(
      //                               padding: const EdgeInsets.symmetric(
      //                                 vertical: 8.0,
      //                                 horizontal: 8.0,
      //                               ),
      //                               decoration: BoxDecoration(
      //                                 color: customColors().secretGarden,
      //                                 borderRadius: BorderRadius.circular(5.0),
      //                               ),
      //                               child: Center(
      //                                 child: Text(
      //                                   "Ok",
      //                                   style: customTextStyle(
      //                                     fontStyle: FontStyle.BodyM_Bold,
      //                                     color: FontColor.White,
      //                                   ),
      //                                 ),
      //                               ),
      //                             ),
      //                           ),
      //                         ),
      //                         Expanded(
      //                           child: InkWell(
      //                             onTap: () {
      //                               ctx
      //                                   .read<NewScanBarcodePageCubit>()
      //                                   .addtolist(
      //                                     _productResponse!.sku,
      //                                     "",
      //                                     "",
      //                                     "",
      //                                   );

      //                               Navigator.pop(context);
      //                             },
      //                             child: Padding(
      //                               padding: const EdgeInsets.only(left: 8.0),
      //                               child: Container(
      //                                 padding: const EdgeInsets.symmetric(
      //                                   horizontal: 8.0,
      //                                   vertical: 8.0,
      //                                 ),
      //                                 decoration: BoxDecoration(
      //                                   color: customColors().islandAqua,
      //                                   borderRadius: BorderRadius.circular(
      //                                     5.0,
      //                                   ),
      //                                 ),
      //                                 child: Center(
      //                                   child: Text(
      //                                     "Add This Item",
      //                                     style: customTextStyle(
      //                                       fontStyle: FontStyle.BodyM_Bold,
      //                                       color: FontColor.White,
      //                                     ),
      //                                   ),
      //                                 ),
      //                               ),
      //                             ),
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           );
      //         },
      //       );
      //     } else {
      //       // ignore: use_build_context_synchronously
      //       showGeneralDialog(
      //         context: context,
      //         pageBuilder: (context, animation, secondaryanimation) {
      //           return Container();
      //         },
      //         transitionBuilder: (
      //           context,
      //           animation,
      //           secondaryAnimation,
      //           child,
      //         ) {
      //           var curves = Curves.easeInOut.transform(animation.value);

      //           return Transform.scale(
      //             scale: curves,
      //             child: AlertDialog(
      //               shape: RoundedRectangleBorder(
      //                 borderRadius: BorderRadius.circular(8.0),
      //               ),
      //               content: Column(
      //                 mainAxisAlignment: MainAxisAlignment.center,
      //                 mainAxisSize: MainAxisSize.min,
      //                 children: [
      //                   // Lottie.asset('assets/animation_list.json', height: 100.0),
      //                   Padding(
      //                     padding: const EdgeInsets.only(top: 8.0),
      //                     child: Row(
      //                       children: [
      //                         Padding(
      //                           padding: const EdgeInsets.only(right: 8.0),
      //                           child: Container(
      //                             height: 90.0,
      //                             width: 90.0,
      //                             child:
      //                                 _productResponse!
      //                                         .mediaGalleryEntries
      //                                         .isEmpty
      //                                     ? Image.asset(
      //                                       'assets/placeholder.png',
      //                                     )
      //                                     : InkWell(
      //                                       onTap: () {
      //                                         getImageViewver(
      //                                           _productResponse!
      //                                               .mediaGalleryEntries,
      //                                           context,
      //                                           _sliderController,
      //                                         );
      //                                       },
      //                                       child: Image.network(
      //                                         "${mainimageurl}${_productResponse!.mediaGalleryEntries[0].file}",
      //                                         fit: BoxFit.contain,
      //                                       ),
      //                                     ),
      //                           ),
      //                         ),
      //                         Expanded(
      //                           child: Container(
      //                             child: Column(
      //                               mainAxisAlignment: MainAxisAlignment.center,
      //                               crossAxisAlignment:
      //                                   CrossAxisAlignment.start,
      //                               children: [
      //                                 Padding(
      //                                   padding: const EdgeInsets.symmetric(
      //                                     horizontal: 8.0,
      //                                   ),
      //                                   child: Text(
      //                                     _productResponse!.name,
      //                                     style: customTextStyle(
      //                                       fontStyle: FontStyle.BodyM_Bold,
      //                                       color: FontColor.FontPrimary,
      //                                     ),
      //                                   ),
      //                                 ),
      //                                 Padding(
      //                                   padding: const EdgeInsets.symmetric(
      //                                     horizontal: 8.0,
      //                                     vertical: 3.0,
      //                                   ),
      //                                   child: Text(
      //                                     "SKU: ${_productResponse!.sku}",
      //                                     style: customTextStyle(
      //                                       fontStyle: FontStyle.BodyM_Bold,
      //                                       color: FontColor.FontPrimary,
      //                                     ),
      //                                   ),
      //                                 ),
      //                               ],
      //                             ),
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                   ),

      //                   Text(
      //                     barcodescanRes!.toString(),
      //                     style: customTextStyle(
      //                       fontStyle: FontStyle.BodyM_Bold,
      //                       color: FontColor.FontPrimary,
      //                     ),
      //                   ),
      //                   Text(
      //                     "This Product is not in the List...!",
      //                     style: customTextStyle(
      //                       fontStyle: FontStyle.BodyL_Bold,
      //                     ),
      //                     textAlign: TextAlign.center,
      //                   ),
      //                   Text(
      //                     "Do you want to Add ?",
      //                     style: customTextStyle(
      //                       fontStyle: FontStyle.BodyL_Bold,
      //                     ),
      //                     textAlign: TextAlign.center,
      //                   ),
      //                   Padding(
      //                     padding: const EdgeInsets.only(top: 10.0),
      //                     child: Row(
      //                       children: [
      //                         Expanded(
      //                           child: InkWell(
      //                             onTap: () {
      //                               Navigator.pop(context);
      //                             },
      //                             child: Container(
      //                               padding: const EdgeInsets.symmetric(
      //                                 vertical: 8.0,
      //                                 horizontal: 8.0,
      //                               ),
      //                               decoration: BoxDecoration(
      //                                 color: customColors().secretGarden,
      //                                 borderRadius: BorderRadius.circular(5.0),
      //                               ),
      //                               child: Center(
      //                                 child: Text(
      //                                   "Ok",
      //                                   style: customTextStyle(
      //                                     fontStyle: FontStyle.BodyM_Bold,
      //                                     color: FontColor.White,
      //                                   ),
      //                                 ),
      //                               ),
      //                             ),
      //                           ),
      //                         ),
      //                         Expanded(
      //                           child: InkWell(
      //                             onTap: () {
      //                               ctx
      //                                   .read<NewScanBarcodePageCubit>()
      //                                   .addtolist(
      //                                     _productResponse!.sku,
      //                                     "",
      //                                     "",
      //                                     "",
      //                                   );

      //                               Navigator.pop(context);
      //                             },
      //                             child: Padding(
      //                               padding: const EdgeInsets.only(left: 8.0),
      //                               child: Container(
      //                                 padding: const EdgeInsets.symmetric(
      //                                   horizontal: 8.0,
      //                                   vertical: 8.0,
      //                                 ),
      //                                 decoration: BoxDecoration(
      //                                   color: customColors().islandAqua,
      //                                   borderRadius: BorderRadius.circular(
      //                                     5.0,
      //                                   ),
      //                                 ),
      //                                 child: Center(
      //                                   child: Text(
      //                                     "Add This Item",
      //                                     style: customTextStyle(
      //                                       fontStyle: FontStyle.BodyM_Bold,
      //                                       color: FontColor.White,
      //                                     ),
      //                                   ),
      //                                 ),
      //                               ),
      //                             ),
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           );
      //         },
      //       );
      //     }
      //   }
      // } else {
      //   //
      //   // Product Not Available
      //   //
      //   // ignore: use_build_context_synchronously
      //   Navigator.pop(context);

      //   // ignore: use_build_context_synchronously
      //   showGeneralDialog(
      //     context: context,
      //     pageBuilder: (context, animation, secondaryanimation) {
      //       return Container();
      //     },
      //     transitionBuilder: (context, animation, secondaryAnimation, child) {
      //       var curves = Curves.easeInOut.transform(animation.value);

      //       return Transform.scale(
      //         scale: curves,
      //         child: AlertDialog(
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(8.0),
      //           ),
      //           content: Column(
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               Text(
      //                 "Product Not Found in Our Record Do you want to Add...?",
      //                 style: customTextStyle(
      //                   fontStyle: FontStyle.BodyL_Bold,
      //                   color: FontColor.FontPrimary,
      //                 ),
      //               ),
      //               Padding(
      //                 padding: const EdgeInsets.only(top: 15.0),
      //                 child: Row(
      //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                   children: [
      //                     Expanded(
      //                       child: InkWell(
      //                         onTap: () {
      //                           Navigator.pop(context);
      //                         },
      //                         child: Container(
      //                           padding: const EdgeInsets.symmetric(
      //                             horizontal: 8.0,
      //                             vertical: 8.0,
      //                           ),
      //                           decoration: BoxDecoration(
      //                             color: customColors().carnationRed,
      //                           ),
      //                           child: Center(
      //                             child: Center(
      //                               child: Text(
      //                                 "No",
      //                                 style: customTextStyle(
      //                                   fontStyle: FontStyle.BodyM_Bold,
      //                                   color: FontColor.White,
      //                                 ),
      //                               ),
      //                             ),
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                     Expanded(
      //                       child: Padding(
      //                         padding: const EdgeInsets.only(left: 8.0),
      //                         child: InkWell(
      //                           onTap: () {
      //                             print(barcodescanRes);
      //                             Navigator.pop(context);
      //                             ctx.read<NewScanBarcodePageCubit>().addtolist(
      //                               barcodescanRes!,
      //                               "",
      //                               "",
      //                               "",
      //                             );
      //                           },
      //                           child: Container(
      //                             padding: const EdgeInsets.symmetric(
      //                               horizontal: 8.0,
      //                               vertical: 8.0,
      //                             ),
      //                             decoration: BoxDecoration(
      //                               color: customColors().secretGarden,
      //                             ),
      //                             child: Center(
      //                               child: Text(
      //                                 "Yes",
      //                                 style: customTextStyle(
      //                                   fontStyle: FontStyle.BodyM_Bold,
      //                                   color: FontColor.White,
      //                                 ),
      //                               ),
      //                             ),
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //       );
      //     },
      //   );
      // }
    } catch (e) {
      //   // log(e.toString(), stackTrace: StackTrace.current);
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "Item Not Scanned Properly Retry...!",
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double mheight = MediaQuery.of(context).size.height * 1.222;
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(
          elevation: 0,
          backgroundColor: customColors().backgroundPrimary,
        ),
      ),
      backgroundColor: customColors().backgroundPrimary,
      body: BlocBuilder<NewScanBarcodePageCubit, NewScanBarcodePageState>(
        builder: (context, state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              UserController().profile.role == "5"
                  ? CustomAppBar(
                    onpressfind: () {},
                    ispicker: true,
                    isphoto: true,
                  )
                  : Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
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
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: InkWell(
                              onTap: () {
                                context.gNavigationService.back(context);
                              },
                              child: Icon(Icons.arrow_back_ios, size: 17.0),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: Text(
                              "Report Missing Products",
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyL_Bold,
                                color: FontColor.FontSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

              if (isScan)
                Expanded(
                  child: MobileScanner(
                    controller: MobileScannerController(
                      facing: CameraFacing.back,
                    ),
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        // print('Barcode found! ${barcode.rawValue}');
                      }
                    },
                  ),
                )
              else
                Expanded(
                  child:
                      context.read<NewScanBarcodePageCubit>().skulist.isEmpty
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  Center(
                                    child: Image.asset(
                                      'assets/barcode_scan.png',
                                      height: 120.0,
                                    ),
                                  ),
                                  Positioned(
                                    child: Center(
                                      child: Container(
                                        height: 120,
                                        width: 120,
                                        decoration: BoxDecoration(
                                          color: customColors()
                                              .backgroundPrimary
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Text(
                                  "Tap To Scan For Add Barcodes...",
                                  style: customTextStyle(
                                    fontStyle: FontStyle.BodyM_Bold,
                                    color: FontColor.FontTertiary,
                                  ),
                                ),
                              ),
                            ],
                          )
                          : ListView.builder(
                            itemCount:
                                context
                                    .read<NewScanBarcodePageCubit>()
                                    .skulist
                                    .length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 5.0,
                                ),
                                child: ExpandableNotifier(
                                  // initialExpanded: context
                                  //     .read<NewScanBarcodePageCubit>()
                                  //     .alwaysopenpanel,
                                  child: ScrollOnExpand(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16.0,
                                        horizontal: 3.0,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: customColors().grey,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          5.0,
                                        ),
                                      ),
                                      child: Builder(
                                        builder: (context) {
                                          var controller =
                                              ExpandableController.of(
                                                context,
                                                required: true,
                                              );

                                          return InkWell(
                                            onTap: () {
                                              controller!.toggle();
                                            },
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8.0,
                                                      ),
                                                  child: Container(
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets.only(
                                                                      left: 8.0,
                                                                    ),
                                                                child:
                                                                // SizedBox(
                                                                //   child:
                                                                //       TextFormField(
                                                                //     initialValue: context
                                                                //             .read<
                                                                //                 NewScanBarcodePageCubit>()
                                                                //             .skulist[
                                                                //         index]['sku'],
                                                                //     onChanged:
                                                                //         (value) {
                                                                //       setState(
                                                                //           () {
                                                                //         context
                                                                //             .read<
                                                                //                 NewScanBarcodePageCubit>()
                                                                //             .skulist[index]['sku'] = value;
                                                                //       });
                                                                //     },
                                                                //   ),
                                                                // )
                                                                Text(
                                                                  context
                                                                      .read<
                                                                        NewScanBarcodePageCubit
                                                                      >()
                                                                      .skulist[index]['sku'],
                                                                  style: customTextStyle(
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .BodyL_Bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Row(
                                                              children: [
                                                                InkWell(
                                                                  onTap: () {
                                                                    controller!
                                                                        .toggle();
                                                                  },
                                                                  child: Padding(
                                                                    padding:
                                                                        const EdgeInsets.only(
                                                                          right:
                                                                              8.0,
                                                                        ),
                                                                    child: Image.asset(
                                                                      'assets/edit.png',
                                                                      height:
                                                                          21.0,
                                                                    ),
                                                                  ),
                                                                ),
                                                                InkWell(
                                                                  onTap: () {
                                                                    BlocProvider.of<
                                                                      NewScanBarcodePageCubit
                                                                    >(
                                                                      context,
                                                                    ).removefromlist(
                                                                      context
                                                                          .read<
                                                                            NewScanBarcodePageCubit
                                                                          >()
                                                                          .skulist[index]['sku'],
                                                                    );
                                                                  },
                                                                  child: Icon(
                                                                    Icons
                                                                        .delete_sharp,
                                                                    size: 20.0,
                                                                    color:
                                                                        customColors()
                                                                            .carnationRed,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                ExpandableSection(
                                                  index: index,
                                                  skulist:
                                                      context
                                                          .read<
                                                            NewScanBarcodePageCubit
                                                          >()
                                                          .skulist,
                                                  trigger: () {
                                                    controller!.toggle();
                                                  },
                                                  removetrigger: () {
                                                    BlocProvider.of<
                                                      NewScanBarcodePageCubit
                                                    >(context).removefromlist(
                                                      context
                                                          .read<
                                                            NewScanBarcodePageCubit
                                                          >()
                                                          .skulist[index]['sku'],
                                                    );
                                                  },
                                                  sliderController:
                                                      _sliderController,
                                                ),
                                              ],
                                            ),
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
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: customColors().backgroundTertiary,
        elevation: 10.0,
        onPressed: () async {
          int sdkVersion = await getAndroidSdkVersion();

          log('Android SDK version: $sdkVersion');

          // scanBarcodeNormal(context);

          if (sdkVersion > 29) {
            scanBarcodeNormal(context);
          } else {
            setState(() {
              isScan = true;
            });
          }
        },
        child: Image.asset('assets/barcode_scan.png', height: 25.0),
      ),

      bottomNavigationBar: Container(
        height: screenSize.height * 0.12,
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Divider(thickness: 1.0, color: customColors().backgroundTertiary),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (context
                            .read<NewScanBarcodePageCubit>()
                            .skulist
                            .isNotEmpty) {
                          context
                              .read<NewScanBarcodePageCubit>()
                              .updatetoproductList();
                        } else {
                          showGeneralDialog(
                            context: context,
                            pageBuilder: (
                              context,
                              animation,
                              secondaryanimation,
                            ) {
                              return Container();
                            },
                            transitionBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              var curve = Curves.easeInOut.transform(
                                animation.value,
                              );

                              return Transform.scale(
                                scale: curve,
                                child: AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  content: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Lottie.asset(
                                      //   'assets/update_error.json',
                                      //   height: 100.0,
                                      // ),
                                      Text(
                                        "Product Lists Are Empty..!",
                                        textAlign: TextAlign.center,
                                        style: customTextStyle(
                                          fontStyle: FontStyle.BodyL_Bold,
                                          color: FontColor.FontPrimary,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 10.0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 28.0,
                                                      vertical: 8.0,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      customColors()
                                                          .secretGarden,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        5.0,
                                                      ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "Ok",
                                                    style: customTextStyle(
                                                      fontStyle:
                                                          FontStyle.BodyL_Bold,
                                                      color: FontColor.White,
                                                    ),
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
                              );
                            },
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        decoration: BoxDecoration(
                          color:
                              context
                                      .read<NewScanBarcodePageCubit>()
                                      .skulist
                                      .isNotEmpty
                                  ? Color.fromRGBO(159, 194, 20, 1)
                                  : Color.fromRGBO(183, 214, 53, 0.5),
                        ),
                        child: Center(
                          child: Text(
                            "Add To Product Report",
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyL_Bold,
                              color:
                                  context
                                          .read<NewScanBarcodePageCubit>()
                                          .skulist
                                          .isEmpty
                                      ? FontColor.White
                                      : FontColor.FontPrimary,
                            ),
                          ),
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
    );
  }

  getImageViewver(
    List<MediaGalleryEntry1> mediaGalleryEntries,
    context,
    CarouselSliderController sliderController,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "",
      pageBuilder: (ctx, a1, a2) {
        return Container();
      },
      transitionBuilder: (ctx, a1, a2, child) {
        var curve = Curves.easeInOut.transform(a1.value);
        return Transform.scale(
          scale: curve,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            content: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.close, color: customColors().fontPrimary),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0, bottom: 25.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Image Viewer",
                              textAlign: TextAlign.center,
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyL_Bold,
                                color: FontColor.Primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: 250,
                          width: 300,
                          child: CarouselSlider.builder(
                            itemCount: mediaGalleryEntries.length,
                            options: CarouselOptions(height: 400.0),
                            itemBuilder:
                                (
                                  BuildContext context,
                                  int itemIndex,
                                  int pageViewIndex,
                                ) => Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                  ),
                                  child: Image.network(
                                    "${mainimageurl}${mediaGalleryEntries[itemIndex].file.toString()}",
                                    fit: BoxFit.fill,
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
          ),
        );
      },
    );
  }
}

class ExpandableSection extends StatefulWidget {
  int index;
  List<Map<String, dynamic>> skulist;
  final VoidCallback trigger;
  final VoidCallback removetrigger;
  CarouselSliderController sliderController;
  ExpandableSection({
    super.key,
    required this.index,
    required this.skulist,
    required this.trigger,
    required this.removetrigger,
    required this.sliderController,
  });

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> {
  TextEditingController namecontroller1 = TextEditingController();
  TextEditingController pricecontroller1 = TextEditingController();
  TextEditingController qtycontroller1 = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Expandable(
      collapsed: Container(),
      expanded: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    widget.skulist[widget.index]['title'] == ""
                        ? Expanded(
                          child: Container(
                            child: TextFormField(
                              // autoFocus: true,
                              initialValue:
                                  widget.skulist[widget.index]['sku'] != null
                                      ? widget.skulist[widget.index]['sku']
                                          .toString()
                                      : "",
                              keyboardType: TextInputType.name,
                              // controller: namecontroller1,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: customColors().backgroundTertiary,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: customColors().backgroundTertiary,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: customColors().backgroundTertiary,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 10,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  widget.skulist[widget.index]['sku'] = value;
                                });
                              },
                            ),
                          ),
                        )
                        : Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 8.0,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: customColors().grey),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Text(
                              widget.skulist[widget.index]['title'],
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyM_Bold,
                                color: FontColor.FontPrimary,
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),

              // Padding(
              //   padding: const EdgeInsets.symmetric(
              //       horizontal: 12.0, vertical: 7.0),
              //   child: Row(
              //     children: [
              //       // widget.skulist[widget.index]['qty'] == ""
              //       // ? Expanded(
              //       //     child: CustomTextFormFieldReport(
              //       //         enabled:
              //       //             widget.skulist[widget.index]['qty'] == "",
              //       //         context: context,
              //       //         keyboardType: TextInputType.number,
              //       //         controller: qtycontroller1,
              //       //         fieldName: 'Qty'))
              //       // : Expanded(
              //       //     child: Container(
              //       //         padding: EdgeInsets.symmetric(
              //       //             horizontal: 8.0, vertical: 8.0),
              //       //         decoration: BoxDecoration(
              //       //             border: Border.all(
              //       //                 color: customColors().grey),
              //       //             borderRadius: BorderRadius.circular(5.0)),
              //       //         child: Text(
              //       //           widget.skulist[widget.index]['qty'],
              //       //           style: customTextStyle(
              //       //               fontStyle: FontStyle.BodyM_Bold,
              //       //               color: FontColor.FontPrimary),
              //       //         ))),
              //       widget.skulist[widget.index]['price'] == ""
              //           ? Expanded(
              //               child: Padding(
              //                 padding: const EdgeInsets.only(left: 8.0),
              //                 child: CustomTextFormFieldReport(
              //                     enabled: widget.skulist[widget.index]
              //                             ['price'] ==
              //                         "",
              //                     context: context,
              //                     controller: pricecontroller1,
              //                     fieldName: 'Price (QAR)'),
              //               ),
              //             )
              //           : Expanded(
              //               child: Padding(
              //               padding: const EdgeInsets.only(left: 8.0),
              //               child: Container(
              //                   padding: EdgeInsets.symmetric(
              //                       horizontal: 8.0, vertical: 8.0),
              //                   decoration: BoxDecoration(
              //                       border: Border.all(
              //                           color: customColors().grey),
              //                       borderRadius: BorderRadius.circular(5.0)),
              //                   child: Text(
              //                     widget.skulist[widget.index]['price'],
              //                     style: customTextStyle(
              //                         fontStyle: FontStyle.BodyM_Bold,
              //                         color: FontColor.FontPrimary),
              //                   )),
              //             ))
              //     ],
              //   ),
              // ),
              SizedBox(height: 15.0),
              widget.skulist[widget.index]['title'] == ""
                  ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: InkWell(
                            onTap: () {
                              widget.removetrigger();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 26.0,
                                vertical: 10.0,
                              ),
                              decoration: BoxDecoration(
                                color: customColors().carnationRed,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Center(
                                child: Text(
                                  "Remove",
                                  style: customTextStyle(
                                    fontStyle: FontStyle.BodyM_Bold,
                                    color: FontColor.White,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            BlocProvider.of<NewScanBarcodePageCubit>(
                              context,
                            ).updatelist(
                              widget.skulist[widget.index]['sku'],
                              namecontroller1.text,
                              qtycontroller1.text,
                              pricecontroller1.text,
                              widget.index,
                              widget.sliderController,
                            );
                            widget.trigger();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 26.0,
                              vertical: 10.0,
                            ),
                            decoration: BoxDecoration(
                              color: customColors().pacificBlue,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Center(
                              child: Text(
                                "Check",
                                style: customTextStyle(
                                  fontStyle: FontStyle.BodyM_Bold,
                                  color: FontColor.White,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  : Row(mainAxisAlignment: MainAxisAlignment.end, children: []),
            ],
          ),
        ),
      ),
    );
  }
}
