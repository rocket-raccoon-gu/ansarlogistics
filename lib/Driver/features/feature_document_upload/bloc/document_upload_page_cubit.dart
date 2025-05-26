import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:ansarlogistics/Driver/features/feature_document_upload/bloc/document_upload_page_state.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:picker_driver_api/responses/order_response.dart';
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

  Order? orderResponseItem;

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

  updateOrder() {
    orderResponseItem = data['order'];

    emit(DocumentUploadInitialPageState(optionslist));
  }

  captureSignature(
    SignatureController controller,
    int index,
    BuildContext context,
  ) async {
    // print(optionslist);
    if (controller.isNotEmpty) {
      var intValue = Random().nextInt(10); // Value is >= 0 and < 10.
      intValue = Random().nextInt(100) + 50;
      final Uint8List? data = await controller.toPngBytes(
        height: 300,
        width: 300,
      );
      // XFile xfle =
      //     XFile.fromData(data!, mimeType: 'image/jpeg', name: 'new_img.jpg');
      try {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File(
          '${tempDir.path}/${orderResponseItem!.subgroupIdentifier} ${intValue.toString()}',
        );
        await tempFile.writeAsBytes(data!);
        // ignore: unnecessary_null_comparison
        if (XFile(tempFile.path) != null) {
          optionslist[index]['data'] = XFile(tempFile.path);
          // updatebarpercentage();
        } else {
          // ignore: use_build_context_synchronously
          showSnackBar(
            context: context,
            snackBar: showErrorDialogue(
              errorMessage: "Signature Capture Failed Please Try Again..!",
            ),
          );
        }
      } catch (e) {}
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
    var status = await Permission.camera.status;

    try {
      if (status.isGranted) {
        // UserController.userController.isgranted = true;

        image = await imagePicker.pickImage(
          source:
              imgsource == "camera" ? ImageSource.camera : ImageSource.gallery,
        );

        final filePath = image!.path;

        final lastindex = filePath.lastIndexOf(new RegExp(r'.jp'));
        final splitted = filePath.substring(0, (lastindex));
        final outpath = "${splitted}_out${filePath.substring(lastindex)}";
        result = await FlutterImageCompress.compressAndGetFile(
          filePath,
          outpath,
          quality: 28,
        );

        optionslist[index]['data'] = result;
        // updatebarpercentage();
        emit(DocumentUploadInitialPageState(optionslist));
      } else {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "Image Capture Permission denied",
          ),
        );
      }
    } catch (e) {
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "Image Capture Failed Please Try Again",
        ),
      );
    }
  }

  uploaddocuments(BuildContext context) async {
    try {
      Uint8List imagebytesqId = await optionslist[1]['data'].readAsBytes();
      Uint8List imagecsign = await optionslist[0]['data'].readAsBytes();
      Uint8List imagedsign = await optionslist[2]['data'].readAsBytes();
      final response = await serviceLocator.tradingApi.updatedocuments(
        imagebytes: imagecsign,
        imagebytesdSign: imagedsign,
        imagebytesqId: imagebytesqId,
        orderid: orderResponseItem!.subgroupIdentifier,
        driverid: int.parse(UserController.userController.profile.id),
      );

      // print(response);

      if (response == 201) {
        // ignore: use_build_context_synchronously
        showSnackBar(
          context: context,
          snackBar: showSuccessDialogue(message: "Documents Uploaded"),
        );

        // serviceLocator.navigationService.openCaptureImage(context, datamap);

        emit(UploadDocumentsSuccessState(optionslist));
      } else {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "Documents Upload Failed Please Try Again..!",
          ),
        );

        emit(UploadDocumentsErrorState(optionslist));
      }
    } catch (e) {
      // print(e);
      Navigator.pop(context);
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "Upload Documentes Failed Please Try Again...!",
        ),
      );
      rethrow;
    }
  }
}
