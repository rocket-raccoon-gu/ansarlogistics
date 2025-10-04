// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:developer';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_inner/bloc/order_item_details_state.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_inner/order_item_details.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_replacement/bloc/item_replacement_page_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/bloc/picker_orders_cubit.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/notifier.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/order_response.dart';
import 'package:picker_driver_api/responses/product_bd_data_response.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:picker_driver_api/responses/erp_data_response.dart';
import 'package:ansarlogistics/utils/price_weight_calculator.dart';

class OrderItemDetailsCubit extends Cubit<OrderItemDetailsState> {
  ServiceLocator serviceLocator;
  BuildContext context;
  Map<String, dynamic> data;
  OrderItemDetailsCubit({
    required this.serviceLocator,
    required this.context,
    required this.data,
  }) : super(OrderItemDetailLoadingState()) {
    updatedata();
  }

  EndPicking? orderItem;

  Order? orderResponseItem;

  bool loading = false;

  String colorOptionId = "";

  String carpetOptionId = "";

  String color = "";

  String carpetSizeValue = "";

  Map<String, dynamic>? productoptions = {};

  ColorInfo? colorInfo;

  CarpetSizeInfo? carpetSizeInfo;

  bool povisvible = false;

  updatedata() {
    orderItem = data['item'];
    orderResponseItem = data['order'];

    if (orderItem!.productOptions.isNotEmpty) {
      productoptions = orderItem!.productOptions;
    }

    if (productoptions!.isNotEmpty &&
        productoptions!.containsKey('attributes_info')) {
      final attributesInfo =
          productoptions!['attributes_info'] as List<dynamic>;

      // 2. Access super_attribute map and get the value using option_id as key
      final superAttributes =
          productoptions!["info_buyRequest"]["super_attribute"]
              as Map<String, dynamic>;

      // Step 2: Find the Color attribute
      final colorAttribute = attributesInfo.firstWhere(
        (attr) => attr['label'] == 'Color',
        orElse: () => null,
      );

      // Step 3: Extract option_id for Color
      if (colorAttribute != null) {
        colorOptionId = colorAttribute['option_value'];
        log('Color Option ID: $colorOptionId'); // Output: 93

        colorInfo = getColorInfo(colorOptionId);
      } else {
        // print('Color attribute not found');
      }

      // 4. Find the Carpet Size attribute
      final carpetSizeAttribute = attributesInfo.firstWhere(
        (attr) => attr['label'] == 'Carpet Size',
        orElse: () => null,
      );

      if (carpetSizeAttribute != null) {
        carpetOptionId = carpetSizeAttribute['option_id'].toString();

        log("Carpet Option ID: $carpetOptionId");

        carpetSizeValue = superAttributes["$carpetOptionId"]; // "856"

        log("Carpet Value: $carpetSizeValue");

        carpetSizeInfo = getCarpetSizeInfo(carpetSizeValue);
      }
    }

    if (!isClosed) {
      emit(OrderItemDetailInitialState(orderItem: orderItem!));
    }
  }

  updateBarcodeLog(String sku, String scannedsku) async {
    // print("📤 Attempting to update barcode log...");
    // print("🆔 Order ID: ${orderResponseItem?.subgroupIdentifier}");
    // print("📦 SKU: $sku");
    // print("🔍 Scanned SKU: $scannedsku");
    // print("👤 User ID: ${UserController().profile.id}");

    try {
      final response = await serviceLocator.tradingApi.updateBarcodeLog(
        orderid: orderResponseItem!.subgroupIdentifier,
        sku: sku,
        scanned_sku: scannedsku,
        user_id: UserController().profile.id,
      );

      if (response.statusCode == 200) {
        // print("✅ Barcode Log Data Updated Successfully");
      } else {
        // print(
        //   "⚠️ Barcode Log Update failed with status: ${response.statusCode}",
        // );
      }
    } catch (e) {
      // print("❌ Barcode Log Update Failed: ${e.toString()}");
    }
  }

  updateitemstatuspick(String qty, String scannedSku, String price) async {
    // print("🚀 updateitemstatuspick() called");
    // print("🔢 Qty: $qty");
    // print("🔍 Scanned SKU: $scannedSku");
    // print("💲 Price: $price");

    try {
      String? token = await PreferenceUtils.getDataFromShared("usertoken");
      // print("🔐 Retrieved Token: ${token != null ? 'Exists' : 'Null'}");

      Map<String, dynamic> body = {
        "item_id": int.parse(orderItem!.itemId),
        "scanned_sku": scannedSku,
        "item_status": "end_picking",
        "shipping": "",
        "price": double.parse(price),
        "qty": double.parse(qty).toInt(),
        "reason": "",
        "picker_id": int.parse(UserController().profile.id),
        "is_produce": int.parse(orderItem!.isproduce),
        "qty_orderd": double.parse(orderItem!.qtyOrdered).toInt(),
      };

      log("📦 Request Body: $body");

      loading = true;

      final response = await serviceLocator.tradingApi.updateItemStatusService(
        body: body,
        token: token,
      );

      // print("📡 API Response Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        loading = false;

        // print("✅ Item status updated successfully");

        UserController.userController.indexlist.add(orderItem!);
        UserController.userController.pickerindexlist.add(orderItem!.itemId);

        // print("📦 Item added to UserController lists");
        // print("💵 Price logged: $price");

        eventBus.fire(
          DataChangedEvent(
            "New Data from Screen B",
          ).updatePriceData(orderResponseItem!.subgroupIdentifier, price),
        );
        // print("📨 EventBus fired with updated price");

        showSnackBar(
          context: context,
          snackBar: showSuccessDialogue(message: "Status Updated"),
        );

        // print("🎉 Showing success dialog and navigating back");

        Navigator.of(context).popUntil((route) => route.isFirst);

        context.gNavigationService.openPickerOrderInnerPage(
          context,
          arg: {'orderitem': orderResponseItem},
        );
      } else {
        loading = false;
        // print("❌ API status update failed: ${response.statusCode}");

        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "status update failed try again..one.",
          ),
        );

        if (!isClosed) {
          emit(
            OrderItemDetailErrorState(loading: loading, orderItem: orderItem!),
          );
          // print("⚠️ Error state emitted");
        }
      }
    } catch (e, stacktrace) {
      loading = false;
      // print("🔥 Exception caught: ${e.toString()}");
      // print("📉 StackTrace: $stacktrace");

      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "status update failed try again..two.",
        ),
      );

      if (!isClosed) {
        emit(
          OrderItemDetailErrorState(loading: loading, orderItem: orderItem!),
        );
        // print("⚠️ Error state emitted after exception");
      }
    }
  }

  updateitemstatus(
    String item_status,
    String qty,
    String reason,
    String price,
  ) async {
    try {
      String? token = await PreferenceUtils.getDataFromShared("usertoken");

      Map<String, dynamic> body = {};

      body = {
        "item_id": orderItem!.itemId,
        "item_status": item_status,
        "shipping": "",
        "price": orderItem!.price,
        "qty": qty,
        "reason": "",
        "picker_id": UserController().profile.id,
        "is_produce": orderItem!.isproduce,
        "qty_orderd": orderItem!.qtyOrdered,
      };

      loading = true;

      final response = await serviceLocator.tradingApi.updateItemStatusService(
        body: body,
        token: token,
      );

      if (response.statusCode == 200) {
        // loading = false;

        // if (item_status == "end_picking") {
        //   UserController.userController.indexlist.add(orderItem!);
        //   UserController.userController.pickerindexlist.add(orderItem!.itemId);
        // } else
        if (item_status == "item_not_available") {
          UserController.userController.itemnotavailablelist.add(orderItem!);
          UserController.userController.notavailableindexlist.add(
            orderItem!.itemId,
          );
        }

        // // UserController.userController.alloworderupdated = true;

        // showSnackBar(
        //   context: context,
        //   snackBar: showSuccessDialogue(message: "status updted"),
        // );

        eventBus.fire(DataChangedEvent("New Data from Screen B"));

        Navigator.of(context).popUntil((route) => route.isFirst);

        // context.read<PickerOrdersCubit>().loadPosts(0, 'all');

        context.gNavigationService.openPickerOrderInnerPage(
          context,
          arg: {'orderitem': orderResponseItem},
        );
      } else {
        loading = false;
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "status update failed try again..three.",
          ),
        );

        if (!isClosed) {
          emit(
            OrderItemDetailErrorState(loading: loading, orderItem: orderItem!),
          );
        }
      }
    } catch (e) {
      loading = false;

      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "status update failed try again.four..",
        ),
      );

      if (!isClosed) {
        emit(
          OrderItemDetailErrorState(loading: loading, orderItem: orderItem!),
        );
      }
    }
  }

  void searchOnGoogle(String keyword) async {
    final searchUrl =
        "https://www.google.com/search?q=${Uri.encodeQueryComponent(keyword)}";
    // ignore: deprecated_member_use
    try {
      if (await canLaunch(searchUrl)) {
        await launch(searchUrl);
      } else {
        throw 'Could not launch $searchUrl';
      }
    } catch (e) {
      // print("Error launching URL: $e");
    }
  }

  bool _isDialogShowing = false;

  checkitemdb(
    String qty,
    String scannedSku,
    EndPicking? orderItem,
    String productSku,
    String action,
  ) async {
    // print("🔍 checkitemdb() called");
    // print("📦 Qty: $qty");
    log("🔍 Scanned SKU: $scannedSku");
    log("🏷️ Product SKU: $productSku");

    final now = DateTime.now();
    final createdAt = orderResponseItem?.createdAt;

    // Compare by local calendar day
    final isSameDayOrder =
        createdAt != null &&
        createdAt.toLocal().year == now.year &&
        createdAt.toLocal().month == now.month &&
        createdAt.toLocal().day == now.day;

    // print("🔁 Action: $action");

    try {
      String convertbarcode = '';
      // print("🔧 Checking if item is produce: ${orderItem?.isproduce}");

      if (orderItem!.isproduce == "1") {
        convertbarcode = replaceAfterFirstSixWithZero(scannedSku);
        // print("🛠️ Produce item detected. Converted barcode: $convertbarcode");
      } else {
        // print("📌 Non-produce item, using scanned barcode directly.");
      }

      final usedBarcode =
          convertbarcode != '' ? convertbarcode : scannedSku.trim();
      // print("➡️ Using barcode for API call: [$usedBarcode]");

      final response = await serviceLocator.tradingApi.checkBarcodeDBService(
        endpoint: usedBarcode,
        productSku: productSku,
        action: action,
      );

      // print("📡 API Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        // print("📬 API call successful. Decoding response...");
        Map<String, dynamic> data = jsonDecode(response.body);
        // print("✅ API Response Data: $data");

        if (data['message'] != "Product not found in website or ERP system") {
          if (data['match'] == "0") {
            // print(
            //   "🔍 Item match not found in current order. Checking priority...",
            // );

            if (data['priority'] == 1) {
              // print("🏷️ Priority 1 item detected");
              ErPdata erPdata = ErPdata.fromJson(data);

              if (!povisvible) {
                povisvible = true;
                // print("🧾 Showing confirmation dialog for ERP item");

                showPickConfirmDialogue(
                  context,
                  '${erPdata.message} $scannedSku',
                  () {
                    // print("🟢 Confirm clicked for ERP item");

                    final calculatedPrice =
                        orderItem.isproduce == "1"
                            ? orderResponseItem?.createdAt != null &&
                                    isSameDayOrder
                                ? getPriceFromBarcode(
                                  getLastSixDigits(scannedSku),
                                )
                                : getPriceFromBarcodeWithWeight(
                                  orderItem.price,
                                  PriceWeightCalculator.getActualWeight(
                                    erPdata.erpPrice,
                                    getPriceFromBarcode(scannedSku),
                                    erPdata.erpProductName,
                                  ),
                                  orderItem.weightUnit,
                                )
                            : double.parse(orderItem.price).toStringAsFixed(2);

                    // print(
                    //   "💰 Order price: ${orderItem.price}, ERP Price: ${erPdata.erpPrice}",
                    // );
                    if (erPdata.erpSku != orderItem.productSku ||
                        !erPdata.mergeBarcode.contains(orderItem.productSku)) {
                      showSnackBar(
                        context: context,
                        snackBar: showErrorDialogue(
                          errorMessage:
                              "barcode not same please replace the item",
                        ),
                      );
                    } else if (orderItem.price == erPdata.erpPrice) {
                      // print("✅ Prices match. Updating item status...");
                      updateitemstatuspick(qty, scannedSku, calculatedPrice);
                    } else {
                      // print("⚠️ Price mismatch detected. Showing error.");
                      showSnackBar(
                        context: context,
                        snackBar: showErrorDialogue(
                          errorMessage:
                              "price not same please replace the item",
                        ),
                      );
                    }
                  },
                  erPdata.erpSku,
                  orderItem.isproduce == "1"
                      ? getPriceFromBarcode(getLastSixDigits(scannedSku))
                      : double.parse(orderItem.price).toStringAsFixed(2),
                  qty,
                  erPdata.erpProductName,
                  () {
                    // print("🔙 Closing ERP dialog");
                    context.gNavigationService.back(context);
                    povisvible = false;
                  },
                );
              }
            } else if (data['priority'] == 2) {
              // print("🏷️ Priority 2 item detected");
              ProductDBdata productDBdata = ProductDBdata.fromJson(data);

              if (!povisvible) {
                povisvible = true;
                // print("🧾 Showing confirmation dialog for ProductDB item");

                if (productDBdata.barcodes.contains(scannedSku.trim())) {
                  // showPickConfirmDialogue(
                  //   context,
                  //   'Barcode Found in System',
                  //   () {
                  //     // print("🟢 Confirm clicked for ProductDB item");
                  //     final calculatedPrice =
                  //         orderItem.isproduce == "1"
                  //             ? getPriceFromBarcode(
                  //               getLastSixDigits(scannedSku),
                  //             )
                  //             : productDBdata.currentPromotionPrice;
                  //     // print("💰 Calculated Price: $calculatedPrice");

                  //     updateitemstatuspick(qty, scannedSku, calculatedPrice);
                  //   },
                  //   productDBdata.sku,
                  //   orderItem.isproduce == "1"
                  //       ? getPriceFromBarcode(getLastSixDigits(scannedSku))
                  //       : double.parse(
                  //         productDBdata.specialPrice ??
                  //             productDBdata.regularPrice,
                  //       ).toStringAsFixed(2),
                  //   qty,
                  //   productDBdata.skuName,
                  //   () {
                  //     // print("🔙 Closing ProductDB dialog");
                  //     context.gNavigationService.back(context);
                  //     povisvible = false;
                  //   },
                  // );

                  showPickConfirmBottomSheet(
                    name: productDBdata.skuName,
                    sku: productDBdata.sku,
                    oldPrice: productDBdata.regularPrice,
                    newPrice:
                        orderItem.isproduce == "1"
                            ? getPriceFromBarcode(getLastSixDigits(scannedSku))
                            : double.parse(orderItem.price).toStringAsFixed(2),
                    regularPrice: productDBdata.regularPrice,
                    imageUrl: "",
                    barcodeType: "",
                    onConfirm: () {
                      updateitemstatuspick(
                        qty,
                        scannedSku,
                        orderItem.isproduce == "1"
                            ? getPriceFromBarcode(getLastSixDigits(scannedSku))
                            : double.parse(orderItem.price).toStringAsFixed(2),
                      );
                    },
                    onClose: () {
                      povisvible = false;
                    },
                    isproduce: orderItem.isproduce == "1",
                    weight: PriceWeightCalculator.getActualWeight(
                      productDBdata.specialPrice ?? productDBdata.regularPrice,
                      getPriceFromBarcode(scannedSku),
                      productDBdata.skuName,
                    ),
                    context: context,
                  );
                } else if (productDBdata.sku == orderItem.productSku) {
                  // showPickConfirmDialogue(
                  //   context,
                  //   'Barcode Found in System',
                  //   () {
                  //     // print("🟢 Confirm clicked for ProductDB item");
                  //     final calculatedPrice =
                  //         orderItem.isproduce == "1"
                  //             ? getPriceFromBarcode(
                  //               getLastSixDigits(scannedSku),
                  //             )
                  //             : double.parse(
                  //               productDBdata.specialPrice ??
                  //                   productDBdata.regularPrice,
                  //             ).toStringAsFixed(2);
                  //     // print("💰 Calculated Price: $calculatedPrice");

                  //     updateitemstatuspick(qty, scannedSku, calculatedPrice);
                  //   },
                  //   productDBdata.sku,
                  //   orderItem.isproduce == "1"
                  //       ? getPriceFromBarcode(getLastSixDigits(scannedSku))
                  //       : double.parse(
                  //         productDBdata.specialPrice ??
                  //             productDBdata.regularPrice,
                  //       ).toStringAsFixed(2),
                  //   qty,
                  //   productDBdata.skuName,
                  //   () {
                  //     // print("🔙 Closing ProductDB dialog");
                  //     context.gNavigationService.back(context);
                  //     povisvible = false;
                  //   },
                  // );

                  showPickConfirmBottomSheet(
                    name: productDBdata.skuName,
                    sku: productDBdata.sku,
                    oldPrice: productDBdata.regularPrice,
                    newPrice:
                        orderItem.isproduce == "1"
                            ? isSameDayOrder
                                ? PriceWeightCalculator.getPriceFromWeight(
                                  productDBdata.specialPrice ??
                                      productDBdata.regularPrice,
                                  PriceWeightCalculator.getWeightFromPrice(
                                    productDBdata.specialPrice ??
                                        productDBdata.regularPrice,
                                    getPriceFromBarcode(
                                      getLastSixDigits(scannedSku),
                                    ),
                                    productDBdata.skuName,
                                  ),
                                  productDBdata.skuName,
                                )
                                : double.parse(
                                  productDBdata.specialPrice ?? "0.00",
                                ).toStringAsFixed(2)
                            : getPriceFromBarcodeWithWeight(
                              orderItem.price,
                              PriceWeightCalculator.getWeightFromPrice(
                                productDBdata.specialPrice ??
                                    productDBdata.regularPrice,
                                getPriceFromBarcode(
                                  getLastSixDigits(scannedSku),
                                ),
                                productDBdata.skuName,
                              ),
                              calculateTotalWeight(
                                qty,
                                PriceWeightCalculator.getWeightFromPrice(
                                  productDBdata.specialPrice ??
                                      productDBdata.regularPrice,
                                  getPriceFromBarcode(
                                    getLastSixDigits(scannedSku),
                                  ),
                                  productDBdata.skuName,
                                ),
                                orderItem.weightUnit,
                              ),
                            ),
                    regularPrice: productDBdata.regularPrice,
                    imageUrl: "",
                    barcodeType: "",
                    onConfirm: () {
                      updateitemstatuspick(
                        qty,
                        scannedSku,
                        orderItem.isproduce == "1"
                            ? PriceWeightCalculator.getPriceFromWeight(
                              productDBdata.specialPrice ??
                                  productDBdata.regularPrice,
                              PriceWeightCalculator.getActualWeight(
                                productDBdata.specialPrice ??
                                    productDBdata.regularPrice,
                                getPriceFromBarcode(
                                  getLastSixDigits(scannedSku),
                                ),
                                productDBdata.skuName,
                              ),
                              productDBdata.skuName,
                            )
                            : double.parse(orderItem.price).toStringAsFixed(2),
                      );
                    },
                    onClose: () {
                      povisvible = false;
                    },
                    isproduce: orderItem.isproduce == "1",
                    weight: PriceWeightCalculator.getActualWeight(
                      productDBdata.specialPrice ?? productDBdata.regularPrice,
                      getPriceFromBarcode(getLastSixDigits(scannedSku)),
                      productDBdata.skuName,
                    ),
                    context: context,
                  );
                } else if (scannedSku.trim() == orderItem.productSku.trim()) {
                  // showPickConfirmDialogue(
                  //   context,
                  //   'Barcode Found in System',
                  //   () {
                  //     // print("🟢 Confirm clicked for ProductDB item");
                  //     final calculatedPrice =
                  //         orderItem.isproduce == "1"
                  //             ? getPriceFromBarcode(
                  //               getLastSixDigits(scannedSku),
                  //             )
                  //             : double.parse(
                  //               productDBdata.specialPrice ??
                  //                   productDBdata.regularPrice,
                  //             ).toStringAsFixed(2);
                  //     // print("💰 Calculated Price: $calculatedPrice");

                  //     updateitemstatuspick(qty, scannedSku, calculatedPrice);
                  //   },
                  //   orderItem.productSku,
                  //   orderItem.isproduce == "1"
                  //       ? getPriceFromBarcode(getLastSixDigits(scannedSku))
                  //       : double.parse(
                  //         productDBdata.specialPrice ??
                  //             productDBdata.regularPrice,
                  //       ).toStringAsFixed(2),
                  //   qty,
                  //   orderItem.productName,
                  //   () {
                  //     // print("🔙 Closing ProductDB dialog");
                  //     context.gNavigationService.back(context);
                  //     povisvible = false;
                  //   },
                  // );
                  showPickConfirmBottomSheet(
                    name: orderItem.productName,
                    sku: orderItem.productSku,
                    oldPrice: orderItem.price,
                    newPrice: orderItem.price,
                    regularPrice: orderItem.price,
                    imageUrl: "",
                    barcodeType: "",
                    onConfirm: () {
                      updateitemstatuspick(
                        qty,
                        scannedSku,
                        double.parse(orderItem.price).toStringAsFixed(2),
                      );
                    },
                    onClose: () {
                      povisvible = false;
                    },
                    isproduce: orderItem.isproduce == "1",
                    weight: PriceWeightCalculator.getActualWeight(
                      orderItem.price,
                      getPriceFromBarcode(scannedSku),
                      orderItem.productName,
                    ),
                    context: context,
                  );
                } else {
                  showSnackBar(
                    context: context,
                    snackBar: showErrorDialogue(
                      errorMessage: "barcode not same please replace the item",
                    ),
                  );
                }
              }
            } else if (data.containsKey('suggestion')) {
              // print("💡 Suggestion found in response: ${data['message']}");
              showSnackBar(
                context: context,
                snackBar: showErrorDialogue(errorMessage: data['message']),
              );
            } else {
              // print("❓ Unrecognized priority or no suggestion in response.");
            }
          } else {
            // print("✅ Item matched in order. No need to show dialog.");
            // if (!_isDialogShowing) {
            //   _isDialogShowing = true;
            // print("📛 _isDialogShowing was false, now set to true");
            // Uncomment if needed
            priceMismatchDialog(
              context,
              orderItem: orderItem,
              orderResponseItem: orderResponseItem,
              //  cubit.orderItem,
              // orderResponseItem: cubit.orderResponseItem,
            );
            // }
          }
        } else {
          String mainMessage = data["message"] + data["suggestion"];
          showSnackBar(
            context: context,
            snackBar: showErrorDialogue(errorMessage: mainMessage),
          );
        }
      } else {
        // print("❌ API call failed with status code: ${response.statusCode}");
        // print("❌ Response body: ${response.body}");
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "Barcode Not Scanned Please Retry!",
          ),
        );
      }
    } catch (e, stacktrace) {
      // print("🔥 Exception in checkitemdb(): ${e.toString()}");
      // print("📉 StackTrace: $stacktrace");
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "Barcode Not Scanned Please Retry!",
        ),
      );
    }
  }
}
