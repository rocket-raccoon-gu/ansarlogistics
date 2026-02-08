// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_inner/bloc/order_item_details_state.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_replacement/bloc/item_replacement_page_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/bloc/picker_orders_cubit.dart';
import 'package:ansarlogistics/Section_In/features/components/section_list_item.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/notifier.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/order_response.dart';
import 'package:picker_driver_api/responses/product_bd_data_response.dart';
import 'package:picker_driver_api/responses/erp_data_response.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/bloc/picker_order_details_cubit.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';
import 'dart:developer';

import 'package:url_launcher/url_launcher.dart';

class OrderItemDetailsCubit extends Cubit<OrderItemDetailsState> {
  ServiceLocator serviceLocator;
  BuildContext context;
  Map<String, dynamic> data;
  PickerOrderDetailsCubit? pickerOrderDetailsCubit;
  OrderItemDetailsCubit({
    required this.serviceLocator,
    required this.context,
    required this.data,
    this.pickerOrderDetailsCubit,
  }) : super(OrderItemDetailLoadingState()) {
    updatedata();
  }

  EndPicking? orderItem;
  OrderItemNew? orderItemNew;

  OrderNew? orderResponseItem;

  bool loading = false;

  String colorOptionId = "";

  String carpetOptionId = "";

  String color = "";

  String carpetSizeValue = "";

  Map<String, dynamic>? productoptions = {};

  ColorInfo? colorInfo;

  CarpetSizeInfo? carpetSizeInfo;

  String preparationLabel = "";

  bool povisvible = false;

  updatedata() {
    if (data.containsKey('itemNew')) {
      orderItemNew = data['itemNew'] as OrderItemNew?;
      // For new flow, emit dedicated state and return

      if (!isClosed && orderItemNew != null) {
        emit(OrderItemDetailInitialNewState(orderItem: orderItemNew!));
        return;
      }
    }

    // orderItem = data['item'];
    // orderResponseItem = data['order'];

    if (data.containsKey('preparationLabel')) {
      preparationLabel = data['preparationLabel'];
    }

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
      emit(OrderItemDetailInitialState(orderItem: orderItemNew!));
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
        user_id: UserController().profile.id.toString(),
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

  updateitemstatuspick(
    String qty,
    String scannedSku,
    String price,
    String preparationLabel1,
  ) async {
    // print("🚀 updateitemstatuspick() called");
    // print("🔢 Qty: $qty");
    // print("🔍 Scanned SKU: $scannedSku");
    // print("💲 Price: $price");

    try {
      String? token = await PreferenceUtils.getDataFromShared("usertoken");
      // print("🔐 Retrieved Token: ${token != null ? 'Exists' : 'Null'}");

      Map<String, dynamic> body = {
        "item_id": orderItemNew!.id,
        "order_number": orderItemNew!.subgroupIdentifier,
        "scanned_sku": scannedSku,
        "status": "end_picking",
        "shipping": double.parse(price),
        "price": double.parse(price),
        // Normalize qty: if produce, treat large values as grams and convert to kg, round to 3 decimals; else 2 decimals
        "qty":
            (() {
              final normalized = qty.replaceAll(',', '.');
              double raw = double.tryParse(normalized) ?? 0.0;
              if (orderItemNew!.isProduce == true) {
                // Heuristic: barcode-derived qty might be grams (e.g., 1200). Convert to kg.
                double kg = raw >= 10 ? (raw / 1000.0) : raw;
                return double.parse(kg.toStringAsFixed(3));
              } else {
                return double.parse(raw.toStringAsFixed(2));
              }
            })(),
        "preparation_id": preparationLabel1,
        "reason": "",
        "picker_id": UserController().profile.id.toString(),
        "is_produce": orderItemNew!.isProduce ?? false ? 1 : 0,
        "qty_orderd": orderItemNew!.qtyOrdered,
      };

      log("📦 Request Body: $body");

      loading = true;

      final response = await serviceLocator.tradingApi.updateItemStatusService(
        body: body,
        token: token!,
      );

      // print("📡 API Response Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        loading = false;

        showSnackBar(
          context: context,
          snackBar: showSuccessDialogue(message: "Status Updated"),
        );

        // Notify dashboard to move the item from ToPick to Picked
        try {
          final String? itemId = orderItemNew?.id;
          if (itemId != null && itemId.isNotEmpty) {
            final int pickedQty =
                (() {
                  final asInt = int.tryParse(qty);
                  if (asInt != null) return asInt;
                  final asDouble = double.tryParse(qty);
                  return asDouble?.toInt() ?? 0;
                })();
            eventBus.fire(
              ItemStatusUpdatedEvent(
                itemId: itemId,
                newStatus: 'end_picking',
                newPrice: price,
                newQty: pickedQty,
              ),
            );
          }
        } catch (_) {}

        if (data.containsKey('from') && data['from'] == "incomplete_orders") {
          context.gNavigationService.openPickerWorkspacePage(context);
        } else {
          // Go back to the dashboard screen
          Future.microtask(() {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          });
        }
      } else {
        loading = false;
        // print("❌ API status update failed: ${response.statusCode}");

        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "status update failed try again..one.",
          ),
        );

        // if (!isClosed) {
        //   emit(
        //     OrderItemDetailErrorState(
        //       loading: loading,
        //       orderItem: orderItemNew!,
        //     ),
        //   );
        // print("⚠️ Error state emitted");
        // }
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

      // if (!isClosed) {
      //   emit(
      //     OrderItemDetailErrorState(loading: loading, orderItem: orderItemNew!),
      //   );
      //   // print("⚠️ Error state emitted after exception");
      // }
    }
  }

  updateitemstatus(
    String item_status,
    String qty,
    String reason,
    String price,
    String preparationLabel1,
    String scannedSku,
  ) async {
    try {
      String? token = await PreferenceUtils.getDataFromShared("usertoken");

      Map<String, dynamic> body = {};

      body = {
        "item_id": orderItemNew!.id,
        "order_number": orderItemNew!.subgroupIdentifier,
        // "scanned_sku": scannedSku,
        "status": item_status,
        "shipping": "",
        "price": double.parse(price),
        // Normalize qty: if produce, treat large values as grams and convert to kg, round to 3 decimals; else 2 decimals
        "qty":
            (() {
              final normalized = qty.replaceAll(',', '.');
              double raw = double.tryParse(normalized) ?? 0.0;
              if (orderItemNew!.isProduce == true) {
                double kg = raw >= 10 ? (raw / 1000.0) : raw;
                return double.parse(kg.toStringAsFixed(3));
              } else {
                return double.parse(raw.toStringAsFixed(2));
              }
            })(),
        "preparation_id": preparationLabel1,
        "reason": reason,
        "picker_id": UserController().profile.id.toString(),
        "is_produce": orderItemNew!.isProduce ?? false ? 1 : 0,
        "qty_orderd": orderItemNew!.qtyOrdered,
      };

      loading = true;

      log(body.toString());

      final response = await serviceLocator.tradingApi.updateItemStatusService(
        body: body,
        token: token!,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        // print("✅ API Response Data: $data");

        if (data['message'] != "Product not found in website or ERP system") {
          try {
            final String? itemId = orderItemNew?.id ?? orderItem?.itemId;
            if (itemId != null && itemId.isNotEmpty) {
              eventBus.fire(
                ItemStatusUpdatedEvent(itemId: itemId, newStatus: item_status),
              );
            }
          } catch (_) {}

          // Go back to dashboard
          Future.microtask(() {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          });
        } else {
          showSnackBar(
            context: context,
            snackBar: showErrorDialogue(
              errorMessage: "status update failed try again.four..",
            ),
          );
        }
      } else {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "status update failed try again.four..",
          ),
        );
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
          OrderItemDetailErrorState(loading: loading, orderItem: orderItemNew!),
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
    OrderItemNew? orderItem,
    String productSku,
    String action,
    String preparationLabel11,
  ) async {
    // print("🔍 checkitemdb() called");
    // print("📦 Qty: $qty");
    // print("🔍 Scanned SKU: $scannedSku");
    // print("🏷️ Product SKU: $productSku");
    // print("🔁 Action: $action");

    try {
      String convertbarcode = '';
      // print("🔧 Checking if item is produce: ${orderItem?.isProduce}");

      if (orderItem!.isProduce == true) {
        convertbarcode = replaceAfterFirstSixWithZero(scannedSku);
        // print("🛠️ Produce item detected. Converted barcode: $convertbarcode");
      } else {
        // print("📌 Non-produce item, using scanned barcode directly.");
      }

      final usedBarcode =
          convertbarcode != '' ? convertbarcode : scannedSku.trim();
      // print("➡️ Using barcode for API call: [$usedBarcode]");
      final token = await PreferenceUtils.getDataFromShared("usertoken");

      final response = await serviceLocator.tradingApi.checkBarcodeDBService(
        endpoint: usedBarcode,
        productSku: productSku,
        action: action,
        token1: token!,
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

                // Validate barcode prefix for produce items: first 6 digits must match
                if (orderItem.isProduce == true) {
                  final String orderPrefix =
                      productSku.length >= 6
                          ? productSku.substring(0, 6)
                          : productSku;
                  final String scanPrefix =
                      scannedSku.length >= 6
                          ? scannedSku.substring(0, 6)
                          : scannedSku;
                  if (orderPrefix != scanPrefix) {
                    showSnackBar(
                      context: context,
                      snackBar: showErrorDialogue(
                        errorMessage: 'Product not same barcode',
                      ),
                    );
                    povisvible = false;
                    return;
                  }
                }

                if (erPdata.erpSku != orderItem.sku ||
                    !erPdata.mergeBarcode.split(',').contains(orderItem.sku)) {
                  showSnackBar(
                    context: context,
                    snackBar: showErrorDialogue(
                      errorMessage: 'Product not same barcode',
                    ),
                  );
                  povisvible = false;
                  return;
                }

                showPickConfirmBottomSheet(
                  name: erPdata.erpProductName ?? '-',
                  sku: erPdata.erpSku ?? '-',
                  imageUrl: orderItem.imageUrl,
                  oldPrice: orderItem.price?.toString(),
                  newPrice:
                      orderItem.isProduce == true
                          ? getPriceFromBarcode(getLastSixDigits(scannedSku))
                          : (erPdata.erpPrice ?? ''),
                  weight:
                      orderItem.isProduce == true
                          ? getWeightFromBarcode(
                            getLastSixDigits(scannedSku),
                            orderItem.price?.toString() ?? '0',
                          )
                          : (erPdata.erpPrice ?? ''),
                  isproduce: orderItem.isProduce ?? false,
                  regularPrice: erPdata.erpPrice,
                  barcodeType: 'EAN-13',
                  onConfirm: () {
                    final calculatedPrice =
                        orderItem.isProduce == true
                            ? getPriceFromBarcode(getLastSixDigits(scannedSku))
                            : erPdata.erpPrice;

                    if (orderItem.price == erPdata.erpPrice) {
                      updateitemstatuspick(
                        // orderItem.isProduce == true
                        //     ? getWeightFromBarcode(
                        //       getLastSixDigits(scannedSku),
                        //       orderItem.price?.toString() ?? '0',
                        //     )
                        //     :
                        qty,
                        scannedSku,
                        calculatedPrice,
                        preparationLabel11,
                      );
                    } else {
                      showSnackBar(
                        context: context,
                        snackBar: showErrorDialogue(
                          errorMessage:
                              "price not same please replace the item",
                        ),
                      );
                    }
                  },
                  onClose: () {
                    // context.gNavigationService.back(context);
                    povisvible = false;
                  },
                );
              }
            } else if (data['priority'] == 2) {
              // print("🏷️ Priority 2 item detected");
              ProductDBdata productDBdata = ProductDBdata.fromJson(data);

              // if (!povisvible) {
              //   povisvible = true;
              // print("🧾 Showing confirmation dialog for ProductDB item");

              // Validate barcode prefix for produce items: first 6 digits must match
              if (orderItem.isProduce == true) {
                final String orderPrefix =
                    productSku.length >= 6
                        ? productSku.substring(0, 6)
                        : productSku;
                final String scanPrefix =
                    scannedSku.length >= 6
                        ? scannedSku.substring(0, 6)
                        : scannedSku;
                if (orderPrefix != scanPrefix) {
                  showSnackBar(
                    context: context,
                    snackBar: showErrorDialogue(
                      errorMessage: 'Product not same barcode',
                    ),
                  );
                  povisvible = false;
                  return;
                }
              }

              if (productDBdata.sku == orderItem.sku ||
                  productDBdata.barcodes.contains(scannedSku)) {
                showPickConfirmBottomSheet(
                  name: productDBdata.skuName ?? '-',
                  sku: productDBdata.sku ?? '-',
                  oldPrice: orderItem.price?.toString(),
                  imageUrl: orderItem.productImage?.split(',').first,
                  newPrice:
                      orderItem.isProduce == true
                          ? getPriceFromBarcode(getLastSixDigits(scannedSku))
                          : double.parse(
                            productDBdata.specialPrice != ""
                                ? productDBdata.specialPrice
                                : productDBdata.regularPrice,
                          ).toStringAsFixed(2),
                  weight:
                      orderItem.isProduce == true
                          ? getWeightFromBarcode(
                            getLastSixDigits(scannedSku),
                            orderItem.price?.toString() ?? '0',
                          )
                          : (productDBdata.specialPrice ??
                              productDBdata.regularPrice),
                  isproduce: orderItem.isProduce ?? false,
                  regularPrice: productDBdata.regularPrice,
                  barcodeType: 'EAN-13',
                  onConfirm: () {
                    final calculatedPrice =
                        orderItem.isProduce == true
                            ? getPriceFromBarcode(getLastSixDigits(scannedSku))
                            : productDBdata.specialPrice != ""
                            ? productDBdata.specialPrice
                            : productDBdata.regularPrice;
                    updateitemstatuspick(
                      // orderItem.isProduce == true
                      //     ? getWeightFromBarcode(
                      //       getLastSixDigits(scannedSku),
                      //       orderItem.price?.toString() ?? '0',
                      //     )
                      //     :
                      qty,
                      scannedSku,
                      calculatedPrice,
                      preparationLabel11,
                    );
                  },
                  onClose: () {
                    // context.gNavigationService.back(context);
                    povisvible = false;
                  },
                );
              } else {
                showSnackBar(
                  context: context,
                  snackBar: showErrorDialogue(
                    errorMessage: "Barcode not Matching....!",
                  ),
                );
              }

              // // }
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
            //   // print("📛 _isDialogShowing was false, now set to true");
            //   // Uncomment if needed
            //   priceMismatchDialog(
            //     context,
            //     orderItem: orderItem,
            //     orderResponseItem: orderResponseItem,
            //     //  cubit.orderItem,
            //     // orderResponseItem: cubit.orderResponseItem,
            //   );
            // }
            showSnackBar(
              context: context,
              snackBar: showErrorDialogue(
                errorMessage: "Barcode Not Matched....",
              ),
            );
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

  void showPickConfirmBottomSheet({
    required String name,
    required String sku,
    String? oldPrice,
    required String newPrice,
    required String regularPrice,
    String? imageUrl,
    String? barcodeType,
    required VoidCallback onConfirm,
    VoidCallback? onClose,
    bool isproduce = false,
    String? weight,
  }) {
    if (_isDialogShowing) return;
    _isDialogShowing = true;

    log(getImageUrlEdited('$mainimageurl$imageUrl'));

    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  Container(
                    width: 96,
                    height: 96,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child:
                        imageUrl == null || imageUrl!.isEmpty
                            ? const Icon(Icons.image, color: Colors.grey)
                            : FutureBuilder(
                              future: Future.wait([
                                getData(), // Firestore document
                                PreferenceUtils.getDataFromShared(
                                  'region',
                                ), // e.g. 'UAE', 'QA', ...
                              ]),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final data =
                                      snapshot.data![0] as Map<String, dynamic>;
                                  final region = snapshot.data![1] as String?;

                                  // Choose which key to use based on region
                                  final imageKey =
                                      region == 'UAE'
                                          ? 'imagepathuae'
                                          : 'imagepath';

                                  return Image.network(
                                    '${data[imageKey]}$imageUrl',
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => const Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                        ),
                                  );
                                } else {
                                  return Image.network(
                                    '$noimageurl',
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => const Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                        ),
                                  );
                                }
                              },
                            ),
                  ),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'SKU: $sku',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Price line
                        FutureBuilder(
                          future: getCurrency(),
                          builder: (context, snapshot) {
                            final currency = snapshot.data ?? 'QAR';

                            return Row(
                              children: [
                                Text(
                                  'Price: $currency ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                if (newPrice != null && newPrice.isNotEmpty)
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 6,
                                        ),
                                        child: Text(
                                          formatPrice(regularPrice),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        formatPrice(newPrice),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFFD32F2F),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Text(
                                    formatPrice(regularPrice),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFFD32F2F),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        if (isproduce)
                          Row(
                            children: [
                              Builder(
                                builder: (_) {
                                  // Parse incoming weight; it may be already in kg or in grams.
                                  double raw =
                                      double.tryParse(weight ?? '') ?? 0.0;
                                  // Heuristic: if value looks like grams (>= 10), convert to kg.
                                  // Receipt-like barcodes often encode ~900-1200 for grams.
                                  final double kg =
                                      raw >= 10 ? (raw / 1000.0) : raw;
                                  final String display =
                                      kg < 1
                                          ? kg.toStringAsFixed(3) // e.g., 0.978
                                          : kg.toStringAsFixed(1); // e.g., 1.2
                                  return Text(
                                    'Weight: $display kg',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.blue.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                },
                              ),
                            ],
                          )
                        else
                          SizedBox(height: 8),
                        // Type and EXP badge
                        Row(
                          children: [
                            Text(
                              'Type: ${barcodeType ?? '-'}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.circle,
                                    color: Color(0xFF2E7D32),
                                    size: 10,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'EXP',
                                    style: TextStyle(
                                      color: Color(0xFF2E7D32),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _isDialogShowing = false;
                        if (onClose != null) onClose();
                        Navigator.of(context).maybePop();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _isDialogShowing = false;
                        Navigator.of(context).maybePop();
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Pickup Item',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      _isDialogShowing = false;
    });
  }
}
