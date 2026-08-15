import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:ansarlogistics/Driver/features/feature_document_upload/bloc/document_upload_page_state.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:picker_driver_api/responses/driver_base_response.dart';
import 'package:signature/signature.dart';

class DocumentUploadPageCubit extends Cubit<DocumentUploadPageState> {
  final ServiceLocator serviceLocator;
  BuildContext context;
  Map<String, dynamic> data;
  DocumentUploadPageCubit({
    required this.serviceLocator,
    required this.context,
    required this.data,
  }) : super(UploadDocumentsPageLoadingState()) {
    updateOrder();
  }

  DataItem? orderResponseItem;

  final ImagePicker imagePicker = ImagePicker();

  var result;

  String sizekb = "";

  XFile? image;

  List<Map<String, dynamic>> optionslist = [
    {
      "id": 0,
      "name": "Customer Signature",
      "image": "assets/signature.png",
      "data": "",
    },
    {
      "id": 1,
      "name": "Customer QID/Passport",
      "image": "assets/id_card.png",
      "data": "",
    },
    {
      "id": 2,
      "name": "Driver Signature",
      "image": "assets/signature.png",
      "data": "",
    },
  ];

  String get orderId => orderResponseItem?.order.subgroupIdentifier ?? '';

  updateOrder() {
    orderResponseItem = data['order'];

    emit(DocumentUploadInitialPageState(optionslist));
  }

  captureSignature(
    SignatureController controller,
    int index,
    BuildContext context,
  ) async {
    if (controller.isNotEmpty) {
      var intValue = Random().nextInt(100) + 50;
      final Uint8List? data = await controller.toPngBytes(
        height: 300,
        width: 300,
      );
      try {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/${orderId}_$intValue.png');
        await tempFile.writeAsBytes(data!);
        optionslist[index]['data'] = XFile(tempFile.path);
      } catch (e) {
        if (context.mounted) {
          showSnackBar(
            context: context,
            snackBar: showErrorDialogue(
              errorMessage: "Signature Capture Failed Please Try Again..!",
            ),
          );
        }
      }
    } else {
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "Signature Capture Failed Please Try Again..!",
        ),
      );
    }
    emit(DocumentUploadInitialPageState(optionslist));
  }

  captureIdImage(int index, BuildContext context, String imgsource) async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "Image Capture Permission denied",
          ),
        );
        return;
      }

      image = await imagePicker.pickImage(
        source:
            imgsource == "camera" ? ImageSource.camera : ImageSource.gallery,
      );
      if (image == null) return;

      final filePath = image!.path;
      final lastindex = filePath.lastIndexOf(RegExp(r'.jp'));
      final outpath =
          lastindex > 0
              ? "${filePath.substring(0, lastindex)}_out${filePath.substring(lastindex)}"
              : "${filePath}_out.jpg";
      result = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outpath,
        quality: 70,
        format: CompressFormat.jpeg,
      );

      optionslist[index]['data'] = result ?? XFile(filePath);
      emit(DocumentUploadInitialPageState(optionslist));
    } catch (e) {
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "Image Capture Failed Please Try Again",
        ),
      );
    }
  }

  bool _hasFile(dynamic data) {
    if (data == null || data == '') return false;
    if (data is XFile) return data.path.isNotEmpty;
    if (data is File) return data.path.isNotEmpty;
    return false;
  }

  File _asFile(dynamic data) {
    if (data is File) return data;
    if (data is XFile) return File(data.path);
    throw Exception("Missing document file");
  }

  uploaddocuments(BuildContext context) async {
    if (!_hasFile(optionslist[0]['data']) ||
        !_hasFile(optionslist[1]['data']) ||
        !_hasFile(optionslist[2]['data'])) {
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage:
              "Please add customer signature, QID and driver signature",
        ),
      );
      emit(UploadDocumentsErrorState(optionslist));
      return;
    }

    if (orderId.isEmpty) {
      emit(UploadDocumentsErrorState(optionslist));
      return;
    }

    try {
      final token =
          UserController().app_token.isNotEmpty
              ? UserController().app_token
              : (await PreferenceUtils.getDataFromShared("usertoken") ??
                  UserController().profile.token.toString());

      final response = await serviceLocator.tradingApi.uploadDriverDocuments(
        orderId: orderId,
        token: token,
        customerSignature: _asFile(optionslist[0]['data']),
        customerQid: _asFile(optionslist[1]['data']),
        driverSignature: _asFile(optionslist[2]['data']),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          if (context.mounted) {
            showSnackBar(
              context: context,
              snackBar: showSuccessDialogue(message: "Documents Uploaded"),
            );
          }
          emit(UploadDocumentsSuccessState(optionslist));
          return;
        }
      }

      if (context.mounted) {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "Documents Upload Failed Please Try Again..!",
          ),
        );
      }
      emit(UploadDocumentsErrorState(optionslist));
    } catch (e) {
      if (context.mounted) {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "Upload Documentes Failed Please Try Again...!",
          ),
        );
      }
      emit(UploadDocumentsErrorState(optionslist));
    }
  }
}
