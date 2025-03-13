import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/bloc/picker_order_details_state.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/barcode_change_sheet.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/price_change_sheet.dart';
import 'package:ansarlogistics/components/loading_indecator.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:picker_driver_api/responses/order_response.dart';

class PickerOrderDetailsCubit extends Cubit<PickerOrderDetailsState> {
  final ServiceLocator serviceLocator;
  BuildContext context;
  Order orderItem;
  PickerOrderDetailsCubit({
    required this.serviceLocator,
    required this.context,
    required this.orderItem,
  }) : super(PickerOrderDetailsLoadingState()) {
    if (UserController.userController.alloworderupdated) {
      UserController.userController.alloworderupdated = false;

      getrefreshedData(orderItem.subgroupIdentifier);
    } else {
      itemslist = orderItem.items;

      updateSelectedItem(0);
    }
  }

  List<String> catlist = [];

  Items? itemslist;

  List<EndPicking> topickitems = [];

  List<EndPicking> pickeditems = [];

  List<EndPicking> notfounditems = [];

  List<EndPicking> canceleditems = [];

  int tabindex = 0;

  bool loading = false;

  // Group items by category
  Map<String, List<EndPicking>> groupedItems = {};

  int page = 1;

  updateSelectedItem(int index) async {
    groupedItems.clear();

    topickitems.clear();
    pickeditems.clear();
    notfounditems.clear();
    canceleditems.clear();
    tabindex = index;

    List.generate(itemslist!.assignedPicker!.length, (index) {
      if (!catlist.contains(itemslist!.assignedPicker![index].catename)) {
        catlist.add(itemslist!.assignedPicker![index].catename);
      }

      if ((UserController.userController.indexlist.isNotEmpty &&
              UserController.userController.indexlist.contains(
                itemslist!.assignedPicker![index],
              )) ||
          UserController.userController.pickerindexlist.contains(
            itemslist!.assignedPicker![index].itemId,
          )) {
        pickeditems.add(itemslist!.assignedPicker![index]);
      } else if ((UserController
                  .userController
                  .itemnotavailablelist
                  .isNotEmpty &&
              UserController.userController.itemnotavailablelist.contains(
                itemslist!.assignedPicker![index],
              )) ||
          UserController.userController.notavailableindexlist.contains(
            itemslist!.assignedPicker![index].itemId,
          )) {
        notfounditems.add(itemslist!.assignedPicker![index]);
      } else {
        topickitems.add(itemslist!.assignedPicker![index]);
      }
    });

    List.generate(itemslist!.startPicking!.length, (index) {
      if (!catlist.contains(itemslist!.startPicking![index].catename)) {
        catlist.add(itemslist!.startPicking![index].catename);
      }

      topickitems.add(itemslist!.startPicking![index]);
    });

    List.generate(itemslist!.endPicking.length, (index) {
      if (!catlist.contains(itemslist!.endPicking[index].catename)) {
        catlist.add(itemslist!.endPicking[index].catename);
      }

      pickeditems.add(itemslist!.endPicking[index]);
    });

    List.generate(itemslist!.itemNotAvailable!.length, (index) {
      if (!catlist.contains(itemslist!.itemNotAvailable![index].catename)) {
        catlist.add(itemslist!.itemNotAvailable![index].catename);
      }

      notfounditems.add(itemslist!.itemNotAvailable![index]);
    });

    List.generate(itemslist!.canceled!.length, (index) {
      if (!catlist.contains(itemslist!.canceled![index].catename)) {
        catlist.add(itemslist!.canceled![index].catename);
      }

      canceleditems.add(itemslist!.canceled![index]);
    });

    List.generate(itemslist!.holded!.length, (index) {
      if (!catlist.contains(itemslist!.holded![index].catename)) {
        catlist.add(itemslist!.holded![index].catename);
      }

      topickitems.add(itemslist!.holded![index]);
    });

    List.generate(itemslist!.materialRequest!.length, (index) {
      if (!catlist.contains(itemslist!.materialRequest![index].catename)) {
        catlist.add(itemslist!.materialRequest![index].catename);
      }

      topickitems.add(itemslist!.materialRequest![index]);
    });

    // try {
    //   // if (state is PickerOrderDetailsLoadingState) return;

    //   if (!isClosed) {
    //     emit(PickerOrderDetailsLoadingState());
    //   }

    // final response = await serviceLocator.tradingApi.orderItemRequestService(
    //     orderid: orderItem.subgroupIdentifier,
    //     pagesize: count,
    //     currentpage: 1,
    //     status: status,
    //     token: token);

    // if (response != null && response.statusCode == 200) {
    //   Map<String, dynamic> data = jsonDecode(response.body);

    //   if (data.containsKey('success') && data['success'] == 0) {
    //     showSnackBar(
    //         context: context,
    //         snackBar: showErrorDialogue(
    //             errorMessage: "Token got expired try again..."));
    //   } else {
    //     ItemListResponse itemListResponse =
    //         ItemListResponse.fromJson(jsonDecode(response.body));
    //     log("ok");

    // log(itemslist.toString());

    // splititems(itemslist!, index);
    // } catch (e) {
    //   log(e.toString());
    //   if (!isClosed) {
    //     emit(PickerOrderDetailsInitialState(index, catlist, groupedItems));
    //   }

    if (!isClosed) {
      emit(
        PickerOrderDetailsInitialState(
          index,
          catlist,
          topickitems,
          pickeditems,
          notfounditems,
          canceleditems,
        ),
      );
    }
    // }
  }

  getrefreshedData(String orderid) async {
    try {
      String? token = await PreferenceUtils.getDataFromShared("usertoken");

      if (!isClosed) {
        emit(PickerOrderDetailsLoadingState());
      }

      final response = await serviceLocator.tradingApi.orderItemRequestService(
        orderid: orderid,
        token: token,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        itemslist = Items.fromJson(data['items']);

        log(itemslist.toString());

        updateSelectedItem(tabindex);
      } else {
        updateSelectedItem(tabindex);
      }
    } on TimeoutException catch (_) {
      emit(PickerOrderDetailsErrorState());
    } catch (e) {
      log(e.toString());
      emit(PickerOrderDetailsErrorState());
    }
  }

  updateMainOrderStat(String orderid) async {
    try {
      loading = true;

      final resp = await serviceLocator.tradingApi.updateMainOrderStat(
        orderid: orderid,
        orderstatus: "end_picking",
        comment:
            "${UserController().profile.name.toString()} (${UserController().profile.empId}) is end picked the order",
        userid: UserController().profile.id,
        latitude: UserController.userController.locationlatitude,
        longitude: UserController.userController.locationlongitude,
      );

      if (resp.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(resp.body);

        if (data['message'] == "Please check all items.") {
          loading = false;

          showSnackBar(
            context: context,
            snackBar: showErrorDialogue(
              errorMessage: "Please check all items.",
            ),
          );

          emit(
            PickerOrderDetailsInitialState(
              1,
              catlist,
              topickitems,
              pickeditems,
              notfounditems,
              canceleditems,
            ),
          );
        } else {
          loading = false;

          Navigator.of(context).popUntil((route) => route.isFirst);

          context.gNavigationService.openPickerWorkspacePage(context);
        }
      } else {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "Status Update Failed Please Try Again",
          ),
        );
      }
    } catch (e) {
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "Status Update Failed Please Try Again",
        ),
      );
    }
  }

  // scanNormlBarcode(EndPicking endpicking) async {
  //   ScanResult scanResult;

  //   String? barcodeScanRes;

  //   try {
  //     scanResult = await BarcodeScanner.scan(
  //         options: ScanOptions(
  //             restrictFormat: [BarcodeFormat.code128, BarcodeFormat.ean13]));
  //     print(scanResult.rawContent.toString() +
  //         "------------------------------------------------------------------------");
  //     barcodeScanRes = scanResult.rawContent;

  //     if (barcodeScanRes.toString().startsWith(']C1')) {
  //       log('contains c1');
  //       barcodeScanRes = barcodeScanRes.toString().replaceAll(']C1', '');
  //     } else if (barcodeScanRes.toString().startsWith('C1')) {
  //       barcodeScanRes = barcodeScanRes.toString().replaceAll('C1', '');
  //     }

  //     log(barcodeScanRes + "---------------------");

  //     String first7 = barcodeScanRes.substring(0, 7);

  //     // if (endpicking.isproduce == "1" &&
  //     //     endpicking.productSku.startsWith(first7)) {
  //     //   // Produce Barcodes.....

  //     //   String lastsix = barcodeScanRes
  //     //       .toString()
  //     //       .substring(barcodeScanRes.toString().length - 6);

  //     //   if (barcodeScanRes != null) {
  //     //     onTapScan(barcodeScanRes, getPrice(lastsix), true, endpicking);
  //     //   }
  //     // } else {
  //     // Normal Barcodes......

  //     if (barcodeScanRes.toString().trim() ==
  //         endpicking.productSku.toString()) {
  //       //barcode Matching....

  //       showSnackBar(
  //           context: context,
  //           snackBar: showSuccessDialogue(message: "barcode matching"));

  //       updateitemstatus('end_picking', endpicking, "0");
  //     } else {
  //       // barcode Not Matching...

  //       showSnackBar(
  //           context: context,
  //           snackBar: showErrorDialogue(errorMessage: "Barcode Not Matching"));
  //     }
  //     // }
  //   } catch (e) {
  //     showSnackBar(
  //         context: context,
  //         snackBar: showErrorDialogue(
  //             errorMessage: "Something went wrong please try again...!"));
  //   }
  // }

  onTapScan(String barcode, String price, bool matching, EndPicking end) {
    showPriceChangeDialogue(
      barcode,
      price,
      end,
      orderItem,
      matching,
      double.parse(end.qtyOrdered).toInt(),
    );
  }

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

              // if (editquantity != 0) {
              //   BlocProvider.of<OrderItemDetailsCubit>(context)
              //       .updateitemstatus("end_picking", editquantity.toString(),
              //           "", pr.toString());
              // } else {
              //   BlocProvider.of<OrderItemDetailsCubit>(context)
              //       .updateitemstatus(
              //           "end_picking", mainqty.toString(), "", pr.toString());
              // }

              // updateitemstatus("end_picking", endpicking, pr.toString());

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

              // if (editquantity != 0) {
              //   BlocProvider.of<OrderItemDetailsCubit>(context)
              //       .updateitemstatus("end_picking", editquantity.toString(),
              //           "", pr.toString());
              // } else {
              //   BlocProvider.of<OrderItemDetailsCubit>(context)
              //       .updateitemstatus(
              //           "end_picking", mainqty.toString(), "", pr.toString());
              // }

              updateitemstatus("end_picking", data, pr.toString());
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

  updateitemstatus(
    String item_status,
    EndPicking endpicking,
    String price,
  ) async {
    String? token = await PreferenceUtils.getDataFromShared("usertoken");

    Map<String, dynamic> body = {};

    body = {
      "item_id": endpicking.itemId,
      "item_status": item_status,
      "shipping": "0",
      "price": price != "0" ? price : endpicking.price,
      "qty": endpicking.qtyOrdered,
      "reason": "",
      "picker_id": UserController.userController.profile.id,
    };

    loading = true;

    final response = await serviceLocator.tradingApi.updateItemStatusService(
      body: body,
      token: token,
    );

    if (response.statusCode == 200) {
      loading = false;

      if (item_status == "end_picking") {
        UserController.userController.indexlist.add(endpicking);
        UserController.userController.pickerindexlist.add(endpicking.itemId);
      } else if (item_status == "item_not_available") {
        UserController.userController.itemnotavailablelist.add(endpicking);
        UserController.userController.notavailableindexlist.add(
          endpicking.itemId,
        );
      }

      UserController.userController.alloworderupdated = true;

      showSnackBar(
        context: context,
        snackBar: showSuccessDialogue(message: "status updted"),
      );

      // Navigator.of(context).popUntil((route) => route.isFirst);

      // context.read<PickerOrdersCubit>().loadPosts(0, 'all');

      // context.gNavigationService.back(context);

      // getrefreshedData(orderItem.subgroupIdentifier);

      topickitems.remove(endpicking);

      if (!isClosed) {
        emit(
          PickerOrderDetailsInitialState(
            0,
            catlist,
            topickitems,
            pickeditems,
            notfounditems,
            canceleditems,
          ),
        );
      }
    } else {
      loading = false;
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "status update failed try again...",
        ),
      );

      getrefreshedData(orderItem.subgroupIdentifier);

      if (!isClosed) {
        // emit(OrderItemDetailErrorState(
        //     loading: loading, orderItem: orderItem!));
      }
    }
  }
}
