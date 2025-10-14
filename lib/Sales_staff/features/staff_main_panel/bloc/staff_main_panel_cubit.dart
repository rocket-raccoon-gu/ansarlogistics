import 'dart:convert';
import 'dart:developer';

import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'staff_main_panel_state.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/utils/utils.dart';

class StaffMainPanelCubit extends Cubit<StaffMainPanelState> {
  final ServiceLocator serviceLocator;
  BuildContext context;
  StaffMainPanelCubit({required this.serviceLocator, required this.context})
    : super(StaffMainPanelInitialState()) {
    loadpage();
  }

  loadpage() {
    emit(StaffMainPanelInitialState());
  }

  checkBarcodeData(String barcode) async {
    try {
      emit(StaffMainPanelLoadingState());
      final response = await serviceLocator.tradingApi
          .checkInventoryBarcodeData(endpoint: barcode);

      if (response.statusCode == 200) {
        log(response.body);

        Map<String, dynamic> data = jsonDecode(response.body);

        if (data['items'].isEmpty) {
          showSnackBar(
            context: context,
            snackBar: showErrorDialogue(errorMessage: data['message']),
          );
          emit(StaffMainPanelErrorState(data['message'] ?? 'No items found'));
        } else {
          // May carry message from API; showing as info if any
          if (data['message'] != null &&
              data['message'].toString().isNotEmpty) {
            showSnackBar(
              context: context,
              snackBar: showSuccessDialogue(message: data['message']),
            );
          }
          emit(StaffMainPanelSuccessState(data));
        }
      } else if (response.statusCode == 404) {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(errorMessage: 'Barcode Not Found'),
        );
        emit(StaffMainPanelErrorState('Barcode Not Found'));
      }
    } catch (e) {
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "Barcode not read please check again...!",
        ),
      );
      emit(StaffMainPanelErrorState('Barcode read error'));
    }
  }

  Future<void> submitScannedItem({
    required String sku,
    required String productName,
    required String uom,
    required num qty,
  }) async {
    try {
      emit(StaffMainPanelLoadingState());

      final body = <String, dynamic>{
        'erp_sku': sku,
        'erp_product_name': productName,
        'uom': uom,
        'erp_qty': qty,
        'branch_code': UserController().profile.branchCode,
        'staff_id': UserController().profile.empId,
        'section': UserController().profile.section,
      };

      final response = await serviceLocator.tradingApi.updateInventoryData(
        body: body,
      );

      if (response.statusCode == 200) {
        showSnackBar(
          context: context,
          snackBar: showSuccessDialogue(message: 'Saved successfully'),
        );
        emit(StaffMainPanelInitialState());
      } else {
        emit(StaffMainPanelErrorState('Save failed'));
      }
    } catch (e) {
      emit(StaffMainPanelErrorState('Save error'));
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(errorMessage: 'Save error'),
      );
    }
  }

  Future<void> submitBulkItems(List<Map<String, dynamic>> items) async {
    try {
      emit(StaffMainPanelLoadingState());

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      deviceInfo.androidInfo.then((value) {
        log(value.model);
      });

      final List<Map<String, dynamic>> payloadItems = [];
      for (final it in items) {
        final sku = (it['erp_sku'] ?? it['sku'] ?? '').toString();
        final uom = (it['uom'] ?? '').toString();
        final qtyNum = it['erp_qty'] ?? it['qty'] ?? 0;
        final num? qty =
            qtyNum is num ? qtyNum : num.tryParse(qtyNum.toString());
        if (sku.isEmpty || uom.isEmpty || (qty == null) || qty <= 0) continue;
        payloadItems.add({
          'erp_sku': sku,
          'erp_qty': qty,
          'staff_id': UserController().profile.empId,
          'branch_code': UserController().profile.branchCode,
          'section_id': UserController().profile.section,
          'device_id': androidInfo.model,
          'uom': uom,
        });
      }

      if (payloadItems.isEmpty) {
        emit(StaffMainPanelErrorState('No valid items to upload'));
        return;
      }

      final response = await serviceLocator.tradingApi.updateInventoryData(
        body: {'items': payloadItems},
      );

      if (response.statusCode == 200) {
        showSnackBar(
          context: context,
          snackBar: showSuccessDialogue(message: 'Bulk upload completed'),
        );
        emit(StaffMainPanelInitialState());
      } else {
        emit(StaffMainPanelErrorState('Bulk upload failed'));
      }
    } catch (e) {
      emit(StaffMainPanelErrorState('Bulk upload error'));
    }
  }
}
