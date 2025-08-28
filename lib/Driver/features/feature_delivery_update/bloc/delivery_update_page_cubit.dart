import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:ansarlogistics/Driver/features/feature_delivery_update/bloc/delivery_update_page_state.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:picker_driver_api/picker_driver_api.dart';
import 'package:picker_driver_api/responses/order_response.dart';
import 'package:toastification/toastification.dart';

class DeliveryUpdatePageCubit extends Cubit<DeliveryUpdatePageState> {
  final ServiceLocator serviceLocator;
  BuildContext context;
  Map<String, dynamic> data;
  DeliveryUpdatePageCubit({
    required this.serviceLocator,
    required this.context,
    required this.data,
  }) : super(DeliveryUpdatePageInitial()) {
    updateOrder();
  }

  Order? orderResponseItem;

  updateOrder() {
    orderResponseItem = data['order'];

    emit(DeliveryUpdatePageInitial());
  }

  String? imageurl;

  double uploadprogress = 0.0;

  bool updatestat = false;

  uploadimage(File billfile) async {
    try {
      final response = await serviceLocator.tradingApi.pickerDriverApi
          .uploadBillService(billfile, orderResponseItem!.subgroupIdentifier);

      if (response.statusCode == 200) {
        log("success");

        uploadprogress = 100;

        emit(DeliveryBillUpdatedState(true));
      } else {
        log("failed");
        emit(DeliveryBillUpdateErrorState());
      }
    } catch (e) {
      emit(DeliveryBillUpdateErrorState());
    }
  }

  // uploadimage(
  //   File billfile,
  // ) async {
  //   Reference referenceRoot = FirebaseStorage.instance.ref();

  //   Reference referenceDirImages = referenceRoot.child('delivery_slips');

  //   Reference referenceImageUpload =
  //       referenceDirImages.child("${orderResponseItem!.subgroupIdentifier}");

  //   try {
  //     final metadata = SettableMetadata(contentType: 'image/jpeg');

  //     final uploadTask = referenceImageUpload.putFile(billfile, metadata);

  //     imageurl = await referenceImageUpload.getDownloadURL();

  //     uploadTask.snapshotEvents.listen((event) {
  //       uploadprogress =
  //           event.bytesTransferred.toDouble() / event.totalBytes.toDouble();

  //       if (event.state == TaskState.success) {
  //         uploadprogress = 100;

  //         emit(DeliveryBillUpdatedState(true));

  //         showSnackBar(
  //             context: context,
  //             // ignore: use_build_context_synchronously
  //             snackBar: showSuccessDialogue(message: "Upload Success"));
  //       }
  //     }).onError((error) {
  //       showSnackBar(
  //           context: context,
  //           // ignore: use_build_context_synchronously
  //           snackBar: showErrorDialogue(
  //               errorMessage: 'Poor Server Connection Please Try Again...!'));
  //     });
  //   } catch (e) {
  //     showSnackBar(
  //         context: context,
  //         // ignore: use_build_context_synchronously
  //         snackBar: showErrorDialogue(
  //             errorMessage: 'Poor Server Connection Please Try Again...!'));
  //   }
  // }

  updateMainOrderStat(String status) async {
    try {
      // Step 1: Get current position
      Position position = await Geolocator.getCurrentPosition();

      // Step 2: Store lat & long in shared preferences
      String lat = position.latitude.toString();
      String long = position.longitude.toString();

      await PreferenceUtils.storeDataToShared("driverlat", lat);
      await PreferenceUtils.storeDataToShared("driverlong", long);

      final resp = await serviceLocator.tradingApi.updateMainOrderStat(
        orderid: orderResponseItem!.subgroupIdentifier,
        orderstatus: status,
        comment:
            "${UserController().profile.name.toString()} (${UserController().profile.empId}) is Delivered This Order",
        userid: UserController().profile.id.toString(),
        latitude: lat,
        longitude: long,
      );

      // final resp = await serviceLocator.tradingApi.updateMainOrderStat(
      //   orderid: orderResponseItem!.subgroupIdentifier,
      //   orderstatus: status,
      //   comment:
      //       "${UserController().profile.name.toString()} (${UserController().profile.empId}) is Delivered This Order",
      //   userid: UserController().profile.id,
      //   latitude: '25.22018977162075',
      //   longitude: '51.49574356933962',
      // );

      if (resp.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(resp.body);

        if (data['message'].contains(
          "Please mark order from delivered location",
        )) {
          toastification.show(
            backgroundColor: customColors().warning,
            title: TranslatedText(
              text: "Please mark order from \n delivered location",
              maxLines: 2,
              style: customTextStyle(
                fontStyle: FontStyle.BodyL_Bold,
                color: FontColor.White,
              ),
            ),
            autoCloseDuration: const Duration(seconds: 5),
          );

          updatestat = false;

          emit(DeliveryStatusUpdateState());
        } else {
          toastification.show(
            backgroundColor: customColors().secretGarden,
            title: TranslatedText(
              text: "Order Status Updated",
              style: customTextStyle(
                fontStyle: FontStyle.BodyL_Bold,
                color: FontColor.White,
              ),
            ),
            autoCloseDuration: const Duration(seconds: 5),
          );

          Navigator.of(context).popUntil((route) => route.isFirst);

          context.gNavigationService.openDriverDashBoardPage(context);
        }
      } else {
        toastification.show(
          backgroundColor: customColors().warning,
          title: TranslatedText(
            text: "Status Update Failed Please Try Again..!.",
            style: customTextStyle(
              fontStyle: FontStyle.BodyL_Bold,
              color: FontColor.White,
            ),
          ),
          autoCloseDuration: const Duration(seconds: 5),
        );

        emit(DeliveryStatusUpdateState());
      }
    } catch (e) {
      toastification.show(
        backgroundColor: customColors().warning,
        title: TranslatedText(
          text: "Status Update Failed Please Try Again..!.",
          style: customTextStyle(
            fontStyle: FontStyle.BodyL_Bold,
            color: FontColor.White,
          ),
        ),
        autoCloseDuration: const Duration(seconds: 5),
      );
      emit(DeliveryStatusUpdateState());
    }
  }
}
