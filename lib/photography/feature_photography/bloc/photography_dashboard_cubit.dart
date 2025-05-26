import 'dart:convert';
import 'dart:developer';

import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/photography/feature_photography/bloc/photography_dashboard_state.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:picker_driver_api/responses/add_sku_list_response.dart';
import 'package:picker_driver_api/responses/product_response.dart';

class PhotographyDashboardCubit extends Cubit<PhotographyDashboardState> {
  final ServiceLocator serviceLocator;
  BuildContext context;

  PhotographyDashboardCubit({
    required this.serviceLocator,
    required this.context,
  }) : super(PhotogrpahyDashboardLoadingState()) {
    updatedata();
  }

  List<Map<String, dynamic>> skulist = [];
  List<Map<String, dynamic>> dynamiclist = [];

  bool alwaysopenpanel = true;

  ProductResponse? _productResponse;

  int onlinestatus = int.parse(
    UserController.userController.profile.availabilityStatus,
  );

  updatedata() async {
    List<dynamic> data = await PreferenceUtils.getstoremap('productlist');

    // skulist = List<Map<String, dynamic>>.from(json.decode(datalist!).cast<Map<String,dynamic>);

    skulist =
        data.map((e) {
          return e as Map<String, dynamic>;
        }).toList();

    emit(PhotographyDashboardInitialState());
  }

  addtolist(String sku, String title, String qty, String price) {
    // Check if the map already exists before adding
    // if (!isMapAlreadyExist(sku)) {
    Map<String, dynamic> newdata = {
      'sku': sku,
      'title': "",
      'price': "",
      'qty': "",
      'user_id': UserController().profile.id,
    };

    if (skulist.where((element) => element.containsValue(sku)).isEmpty) {
      skulist.add(newdata);
    }

    // }
    // print(skulist);
    PreferenceUtils.storeListmap('productlist', skulist);

    emit(PhotographyDashboardInitialState());
  }

  updatelist(
    String sku,
    String title,
    String qty,
    String price,
    int index,
    CarouselSliderController _sliderController,
  ) async {
    try {
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

      // check in products magento db

      final productresponse = await serviceLocator.tradingApi
          .generalProductServiceGet(endpoint: sku, token11: token!);

      if (productresponse.statusCode == 200) {
        //
        // Product Available
        //
        Navigator.pop(context);
        Map<String, dynamic> data = jsonDecode(productresponse);

        log(productresponse);

        if (data.containsKey('message')) {
          // check in scanned sku list db

          String response = await serviceLocator.tradingApi
              .checkbarcodeavailablity(sku: sku);

          log(response);

          Map<String, dynamic> mdata = jsonDecode(response);

          // available in scanned sku list db

          if (mdata['success'] == 1) {
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
                        // Lottie.asset(
                        //   'assets/animation_list.json',
                        //   height: 100.0,
                        // ),
                        Text(
                          sku.toString(),
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyM_Bold,
                            color: FontColor.FontPrimary,
                          ),
                        ),
                        Text(
                          "Barcode Already Scanned on ${mdata['data']['date']}",
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyL_Bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Product Upload in Processing...",
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyL_Bold,
                          ),
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
                                  padding: const EdgeInsets.symmetric(
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

            // allready in list
            //
          } else {
            // check in current list

            if (skulist
                .where((element) => element.containsValue(sku))
                .isEmpty) {
              // not available in current list

              skulist[index]['sku'] = sku;
              skulist[index]['title'] = title;
              skulist[index]['price'] = price;
              skulist[index]['qty'] = qty;
              skulist[index]['user_id'] = UserController().profile.id;

              // print(skulist);
              alwaysopenpanel = false;

              //  int index1 = skulist.indexWhere((element) => element['sku'] == prevsku);

              //  if (index1 != -1) {
              //    skulist[index1]
              //  }

              PreferenceUtils.storeListmap('productlist', skulist);

              emit(PhotographyDashboardInitialState());
            } else {
              // available in current list

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
                            sku.toString(),
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
        } else {
          // available in products magento db

          _productResponse = ProductResponse.fromJson(data);

          // check barcode avilablity in scanned list db

          String response = await serviceLocator.tradingApi
              .checkbarcodeavailablity(sku: sku);

          log(response);

          Map<String, dynamic> mdata = jsonDecode(response);

          if (mdata['success'] == 1) {
            //avaialable in scanned list db

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
                                          ? Image.asset(
                                            'assets/placeholder.png',
                                          )
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                        Text(
                          "Barcode Already Scanned on ${mdata['data']['date']}",
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyL_Bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Do you want to add it again...?",
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyL_Bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    skulist.removeWhere(
                                      (element) => element['sku'] == sku,
                                    );
                                    Navigator.pop(context);

                                    emit(PhotographyDashboardInitialState());
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal: 8.0,
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
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    // ctx.read<NewScanBarcodePageCubit>().addtolist(
                                    //     _productResponse!.sku, "", "", "");

                                    skulist[index]['sku'] = sku;
                                    skulist[index]['title'] = title;
                                    skulist[index]['price'] = price;
                                    skulist[index]['qty'] = qty;
                                    skulist[index]['user_id'] =
                                        UserController().profile.id;

                                    // print(skulist);
                                    alwaysopenpanel = false;

                                    //  int index1 = skulist.indexWhere((element) => element['sku'] == prevsku);

                                    //  if (index1 != -1) {
                                    //    skulist[index1]
                                    //  }

                                    PreferenceUtils.storeListmap(
                                      'productlist',
                                      skulist,
                                    );
                                    Navigator.pop(context);

                                    emit(PhotographyDashboardInitialState());
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
                                        borderRadius: BorderRadius.circular(
                                          5.0,
                                        ),
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
            //not available in scanned list db

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
                                          ? Image.asset(
                                            'assets/placeholder.png',
                                          )
                                          : InkWell(
                                            onTap: () {
                                              // getImageViewver(
                                              //     _productResponse!
                                              //         .mediaGalleryEntries,
                                              //     context,
                                              //     _sliderController);
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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

                        Text(
                          "This Product is not in the List...!",
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyL_Bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Do you want to Add ?",
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyL_Bold,
                          ),
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
                                    // ctx.read<NewScanBarcodePageCubit>().addtolist(
                                    //     _productResponse!.sku, "", "", "");

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
                                        borderRadius: BorderRadius.circular(
                                          5.0,
                                        ),
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
          }
        }
      } else {
        //
        // Product Not Available
        //
      }
    } catch (e) {
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "Item Not Scanned Properly Retry...!",
        ),
      );
    }
  }

  removefromlist(String sku) {
    // Remove all maps where the 'name' is equal to the specified name

    if (isMapAlreadyExist(sku)) {
      skulist.removeWhere((element) => element['sku'] == sku);
    }
    PreferenceUtils.storeListmap('productlist', skulist);

    emit(PhotographyDashboardInitialState());
  }

  clearsharedlist() async {
    PreferenceUtils.storeListmap('productlist', skulist);
    emit(PhotographyDashboardInitialState());
    context.gNavigationService.back(context);
  }

  updatetoproductList() async {
    dynamiclist.clear();

    try {
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
                      "Products Uploading....!",
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
      final response = await serviceLocator.tradingApi.addtoProductList(
        dynamiclist: skulist,
      );
      if (response.toString() == "Retry") {
        // print("Failed");
        //   // ignore: use_build_context_synchronously
        Navigator.pop(context);
        // ignore: use_build_context_synchronously
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: 'Poor Server Connection Please Try Again...!',
          ),
        );
      } else {
        Map<String, dynamic> data = json.decode(response.body.toString());

        if (data['status'] == 200) {
          //success
          AddSkuListResponce addSkuListResponce = AddSkuListResponce.fromJson(
            data,
          );

          // print("Success");
          // ignore: use_build_context_synchronously
          Navigator.pop(context);

          // ignore: use_build_context_synchronously
          showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel: "",
            pageBuilder: (context, animation, secondaryanimation) {
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Lottie.asset(
                      //   'assets/lottie_files/animation_order_update.json',
                      // ),
                      Text(
                        "Products Added SuccessFull",
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyM_Bold,
                          color: FontColor.FontPrimary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: InkWell(
                          onTap: () {
                            skulist.clear();

                            clearsharedlist();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 8.0,
                            ),
                            decoration: BoxDecoration(
                              color: customColors().secretGarden,
                            ),
                            child: Center(
                              child: Text(
                                "Ok",
                                style: customTextStyle(
                                  fontStyle: FontStyle.BodyL_Bold,
                                  color: FontColor.White,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          // failure

          // print("Success");
          // ignore: use_build_context_synchronously
          Navigator.pop(context);

          showSnackBar(
            context: context,
            snackBar: showErrorDialogue(
              errorMessage: "Something Went Wrong Please Try Again...",
            ),
          );
        }
      }

      // }
    } catch (e) {
      log(e.toString(), stackTrace: StackTrace.current);
      // print(e.toString());
    }
  }

  bool isMapAlreadyExist(String sku) {
    for (var i = 0; i < skulist.length; i++) {
      if (skulist[i]['sku'] == sku) {
        return true;
      }
    }
    return false;
  }

  scanBarcode(BuildContext context) async {}

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
                          width: 250,

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
