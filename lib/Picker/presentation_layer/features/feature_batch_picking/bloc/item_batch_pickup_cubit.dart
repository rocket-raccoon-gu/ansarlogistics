import 'dart:convert';
import 'dart:developer';

import 'package:ansarlogistics/Picker/presentation_layer/features/feature_batch_picking/bloc/item_batch_pickup_state.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_orders/bloc/picker_orders_cubit.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:picker_driver_api/responses/erp_data_response.dart';
import 'package:picker_driver_api/responses/product_bd_data_response.dart';

class ItemBatchPickupCubit extends Cubit<ItemBatchPickupState> {
  final ServiceLocator serviceLocator;
  final Map<String, dynamic> data;
  final BuildContext context1;
  ItemBatchPickupCubit(this.serviceLocator, this.data, this.context1)
    : super(ItemBatchPickupLoadingState()) {
    updatedata();
  }

  bool _isDialogShowing = false;

  void updatedata() {
    final item = data['items_data'];

    emit(ItemBatchPickupLoadedState(item: item));
  }

  checkitemdb(
    String qty,
    String scannedSku,
    String productSku,
    String action,
    BuildContext context,
    List<int> itemIds,
    String preparationId,
    List<String> orderIds,
  ) async {
    // print("🔍 checkitemdb() called");
    // print("📦 Qty: $qty");
    // print("🔍 Scanned SKU: $scannedSku");
    // print("🏷️ Product SKU: $productSku");
    // print("🔁 Action: $action");

    try {
      final token = await PreferenceUtils.getDataFromShared("usertoken");

      final response = await serviceLocator.tradingApi.checkBarcodeDBService(
        endpoint: scannedSku,
        productSku: productSku,
        action: action,
        token1: token!,
      );

      log(response.body);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        if (data['priority'] == 1) {
          ErPdata erPdata = ErPdata.fromJson(data);

          if (!_isDialogShowing) {
            _isDialogShowing = true;
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder:
                  (context) =>
                      buildPriority1BottomSheet(context, erPdata, () async {
                        if (scannedSku == erPdata.erpSku ||
                            scannedSku == productSku) {
                          //
                          // picking logic here

                          final token = await PreferenceUtils.getDataFromShared(
                            "usertoken",
                          );

                          final response = await serviceLocator.tradingApi
                              .updateBatchPickup(
                                itemids: itemIds,
                                userid: UserController().profile.id.toString(),
                                token1: token!,
                                status: "end_picking",
                                orderIds: orderIds,
                                itemSku: productSku,
                                reason: "",
                              );

                          if (response.statusCode == 200) {
                            Navigator.pop(context);
                            showSnackBar(
                              context: context,
                              snackBar: showSuccessDialogue(
                                message: "Picked Successfully!",
                              ),
                            );

                            context.gNavigationService.openPickerWorkspacePage(
                              context,
                            );

                            // Get the PickerOrdersCubit instance
                            // final pickerOrdersCubit =
                            //     context1.read<PickerOrdersCubit>();
                            // pickerOrdersCubit.loadOrdersNew();
                          } else {
                            Navigator.pop(context);
                            showSnackBar(
                              context: context,
                              snackBar: showErrorDialogue(
                                errorMessage: "Picking Failed!",
                              ),
                            );
                          }
                        } else {
                          showSnackBar(
                            context: context,
                            snackBar: showErrorDialogue(
                              errorMessage: "Barcode Not Matching!",
                            ),
                          );
                        }
                      }),
            ).whenComplete(() {
              _isDialogShowing = false;
            });
          }
        } else if (data['priority'] == 2) {
          ProductDBdata productDBdata = ProductDBdata.fromJson(data);

          if (!_isDialogShowing) {
            _isDialogShowing = true;
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder:
                  (context) => buildPriority2BottomSheet(
                    context,
                    productDBdata,
                    () async {
                      if (scannedSku == productSku ||
                          productDBdata.barcodes.contains(scannedSku)) {
                        //
                        // picking logic here

                        final token = await PreferenceUtils.getDataFromShared(
                          "usertoken",
                        );

                        final response = await serviceLocator.tradingApi
                            .updateBatchPickup(
                              itemids: itemIds,
                              userid: UserController().profile.id.toString(),
                              token1: token!,
                              status: "end_picking",
                              orderIds: orderIds,
                              itemSku: productDBdata.sku,
                              reason: "",
                            );

                        if (response.statusCode == 200) {
                          Navigator.pop(context);
                          showSnackBar(
                            context: context,
                            snackBar: showSuccessDialogue(
                              message: "Picked Successfully!",
                            ),
                          );

                          context.gNavigationService.openPickerWorkspacePage(
                            context,
                          );

                          // Get the PickerOrdersCubit instance
                          // final pickerOrdersCubit =
                          //     context1.read<PickerOrdersCubit>();
                          // pickerOrdersCubit.loadOrdersNew();
                        } else {
                          Navigator.pop(context);
                          showSnackBar(
                            context: context,
                            snackBar: showErrorDialogue(
                              errorMessage: "Picking Failed!",
                            ),
                          );
                        }
                      } else {
                        Navigator.pop(context);
                        showSnackBar(
                          context: context,
                          snackBar: showErrorDialogue(
                            errorMessage: "Barcode Not Matching!",
                          ),
                        );
                      }
                    },
                  ),
            ).whenComplete(() {
              _isDialogShowing = false;
            });
          }
        } else if (data['priority'] == 0) {
          showSnackBar(
            context: context,
            snackBar: showErrorDialogue(errorMessage: "Barcode Not Matching!"),
          );
        }
      } else {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "Barcode Not Scanned Please Retry!",
          ),
        );
      }

      if (!_isDialogShowing) {
        _isDialogShowing = true;
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

  updateitemstatus(
    String status,
    List<int> itemIds,
    List<String> orderIds,
    String itemSku,
    String reason,
  ) async {
    final token = await PreferenceUtils.getDataFromShared("usertoken");
    if (token == null) return;

    final response = await serviceLocator.tradingApi.updateBatchPickup(
      itemids: itemIds,
      userid: UserController().profile.id.toString(),
      token1: token,
      status: status,
      orderIds: orderIds,
      itemSku: itemSku,
      reason: reason,
    );

    if (response.statusCode == 200) {
      if (context1.mounted) {
        showSnackBar(
          context: context1,
          snackBar: showSuccessDialogue(message: "Item Picked Successfully!"),
        );
      }
    } else {
      if (context1.mounted) {
        showSnackBar(
          context: context1,
          snackBar: showErrorDialogue(
            errorMessage: "Item Picking Failed! Please Try Again..!",
          ),
        );
      }
    }

    // Navigate back to workspace
    if (context1.mounted) {
      context1.gNavigationService.openPickerWorkspacePage(context1);
    }
  }

  void showItemNotAvailableConfirmation(
    BuildContext context,
    List<int> itemIds,
    String itemName,
    String itemStatus,
    String itemSku,
    List<String> orderIds,
  ) {
    if (_isDialogShowing) return;

    _isDialogShowing = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Confirm Item Not Available',
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyL_Bold,
                    color: FontColor.FontPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Are you sure you want to mark "$itemName" as not available?',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _isDialogShowing = false;
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          await updateitemstatus(
                            'item_not_available',
                            itemIds,
                            orderIds,
                            itemSku,
                            "",
                          );
                          _isDialogShowing = false;
                        },
                        child: const Text('Confirm'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    ).whenComplete(() {
      _isDialogShowing = false;
    });
  }

  void showItemHoldConfirmation(
    BuildContext context,
    List<int> itemIds,
    String itemName,
    String itemSku,
    List<String> orderIds,
  ) {
    if (_isDialogShowing) return;
    _isDialogShowing = true;

    final TextEditingController reasonController = TextEditingController();
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // title
                  // existing text "Are you sure..."
                  const SizedBox(height: 16),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Reason for hold',
                      hintText: 'Enter reason...',
                      errorText: errorText,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Cancel button as it is
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _isDialogShowing = false;
                          },
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          onPressed: () async {
                            final reason = reasonController.text.trim();
                            if (reason.isEmpty) {
                              setState(() {
                                errorText = 'Please enter a reason';
                              });
                              return;
                            }
                            Navigator.pop(context);
                            await updateitemstatus(
                              'holded',
                              itemIds,
                              orderIds,
                              itemSku,
                              reason, // <‑ pass reason here
                            );
                            _isDialogShowing = false;
                          },
                          child: const Text('Put on Hold'),
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
    ).whenComplete(() {
      _isDialogShowing = false;
    });
  }
}
