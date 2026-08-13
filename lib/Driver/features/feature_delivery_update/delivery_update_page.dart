import 'dart:io';

import 'package:ansarlogistics/Driver/features/feature_delivery_update/bloc/delivery_update_page_cubit.dart';
import 'package:ansarlogistics/Driver/features/feature_delivery_update/bloc/delivery_update_page_state.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/scrollable_bottomsheet.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toastification/toastification.dart';

class DeliveryUpdatePage extends StatefulWidget {
  const DeliveryUpdatePage({super.key});

  @override
  State<DeliveryUpdatePage> createState() => _DeliveryUpdatePageState();
}

class _DeliveryUpdatePageState extends State<DeliveryUpdatePage> {
  final ImagePicker imagePicker = ImagePicker();
  XFile? image;
  bool uploading = false;

  Future<void> getImage(String imgsource) async {
    bool isCameraGranted = await Permission.camera.request().isGranted;
    if (!isCameraGranted) {
      isCameraGranted =
          await Permission.camera.request() == PermissionStatus.granted;
    }
    if (!isCameraGranted) return;

    try {
      final picked = await imagePicker.pickImage(
        source:
            imgsource == "camera" ? ImageSource.camera : ImageSource.gallery,
      );
      if (picked == null) return;

      final filePath = picked.path;
      final dir = filePath.contains('/') || filePath.contains('\\')
          ? filePath.substring(
            0,
            filePath.replaceAll('\\', '/').lastIndexOf('/'),
          )
          : filePath;
      final outpath =
          '$dir/bill_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final compressed = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outpath,
        quality: 70,
        format: CompressFormat.jpeg,
      );

      setState(() {
        image = compressed ?? picked;
        uploading = false;
      });
      if (!mounted) return;
      context.read<DeliveryUpdatePageCubit>().resetBillUpload();
    } catch (e) {
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(
          errorMessage: "Bill Image Not Captured Properly Try Again..!",
        ),
      );
    }
  }

  void _openSourceSheet() {
    customShowModalBottomSheet(
      context: context,
      inputWidget: Column(
        children: [
          _sourceRow("Camera", Icons.camera_alt, () {
            Navigator.pop(context);
            getImage("camera");
          }),
          _sourceRow("Gallery", Icons.photo_library_outlined, () {
            Navigator.pop(context);
            getImage("gallery");
          }),
        ],
      ),
    );
  }

  Widget _sourceRow(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 18.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: customColors().fontPrimary),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TranslatedText(
              text: label,
              style: customTextStyle(
                fontStyle: FontStyle.BodyL_Bold,
                color: FontColor.FontPrimary,
              ),
            ),
            Icon(icon),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadBill() async {
    if (image == null) {
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(errorMessage: "Please Select a Picture"),
      );
      return;
    }
    setState(() => uploading = true);
    await context.read<DeliveryUpdatePageCubit>().uploadimage(File(image!.path));
  }

  Widget _stepChip({
    required String number,
    required String label,
    required bool active,
    required bool done,
  }) {
    final color =
        done
            ? customColors().secretGarden
            : active
            ? customColors().pacificBlue
            : customColors().fontTertiary;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Center(
                child:
                    done
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Text(
                          number,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TranslatedText(
                text: label,
                maxLines: 1,
                style: customTextStyle(
                  fontStyle: FontStyle.BodyM_Bold,
                  color: FontColor.FontPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(
          elevation: 0,
          backgroundColor: customColors().backgroundPrimary,
        ),
      ),
      backgroundColor: customColors().backgroundPrimary,
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1.0,
                  color: customColors().backgroundTertiary,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.gNavigationService.back(context),
                    icon: const Icon(Icons.arrow_back_ios, size: 17.0),
                  ),
                  Expanded(
                    child: TranslatedText(
                      text: "Complete Delivery",
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyL_Bold,
                        color: FontColor.FontPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          BlocConsumer<DeliveryUpdatePageCubit, DeliveryUpdatePageState>(
            listener: (context, state) {
              if (state is DeliveryBillUpdatedState) {
                setState(() => uploading = false);
                toastification.show(
                  backgroundColor: customColors().secretGarden,
                  context: context,
                  title: TranslatedText(
                    text: "Bill uploaded successfully",
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyL_Bold,
                      color: FontColor.White,
                    ),
                  ),
                );
              }

              if (state is DeliveryBillUpdateErrorState) {
                setState(() => uploading = false);
                toastification.show(
                  backgroundColor: customColors().carnationRed,
                  context: context,
                  title: TranslatedText(
                    text: "Failed To Upload Bill Please Try Again...!",
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyL_Bold,
                      color: FontColor.White,
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              final cubit = context.read<DeliveryUpdatePageCubit>();
              final billUploaded = cubit.billUploaded;
              final hasPhoto = image != null;

              return Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (cubit.orderId.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: customColors().backgroundTertiary
                                .withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TranslatedText(
                            text: "Order  ${cubit.orderId}",
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyL_Bold,
                              color: FontColor.FontPrimary,
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          _stepChip(
                            number: "1",
                            label: "Upload bill",
                            active: !billUploaded,
                            done: billUploaded,
                          ),
                          const SizedBox(width: 8),
                          _stepChip(
                            number: "2",
                            label: "Mark delivered",
                            active: billUploaded,
                            done: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TranslatedText(
                        text: "Bill photo",
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyL_Bold,
                          color: FontColor.FontPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TranslatedText(
                        text:
                            "Capture a clear photo of the delivery bill, then upload it. Mark Delivered unlocks after a successful upload.",
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyM_Regular,
                          color: FontColor.FontTertiary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          radius: const Radius.circular(12),
                          dashPattern: const [8, 5],
                          color:
                              billUploaded
                                  ? customColors().secretGarden
                                  : customColors().fontTertiary,
                        ),
                        child: InkWell(
                          onTap: uploading ? null : _openSourceSheet,
                          child: Container(
                            width: double.infinity,
                            height: 240,
                            alignment: Alignment.center,
                            child:
                                hasPhoto
                                    ? Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.file(
                                            File(image!.path),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        if (billUploaded)
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    customColors().secretGarden,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.check_circle,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  TranslatedText(
                                                    text: "Uploaded",
                                                    style: customTextStyle(
                                                      fontStyle:
                                                          FontStyle.BodyM_Bold,
                                                      color: FontColor.White,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    )
                                    : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.camera_alt_rounded,
                                          size: 56,
                                          color: customColors().fontTertiary,
                                        ),
                                        const SizedBox(height: 8),
                                        TranslatedText(
                                          text: "Tap to take photo",
                                          style: customTextStyle(
                                            fontStyle: FontStyle.BodyM_SemiBold,
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                      ),
                      if (uploading) ...[
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          minHeight: 8,
                          backgroundColor: customColors().grey,
                          valueColor: AlwaysStoppedAnimation(
                            customColors().secretGarden,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TranslatedText(
                          text: "Uploading bill, please wait...",
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyM_Bold,
                            color: FontColor.SecretGarden,
                          ),
                        ),
                      ],
                      if (hasPhoto && !uploading) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: BasketButton(
                                text:
                                    billUploaded
                                        ? "Bill uploaded"
                                        : "Upload bill",
                                enabled: !billUploaded,
                                loading: false,
                                bgcolor: customColors().pacificBlue,
                                onpress: billUploaded ? null : _uploadBill,
                                textStyle: customTextStyle(
                                  fontStyle: FontStyle.BodyL_Bold,
                                  color: FontColor.White,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: BasketButton(
                                text: "Retake",
                                bgcolor: customColors().secretGarden,
                                onpress: _openSourceSheet,
                                textStyle: customTextStyle(
                                  fontStyle: FontStyle.BodyL_Bold,
                                  color: FontColor.White,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BlocBuilder<
        DeliveryUpdatePageCubit,
        DeliveryUpdatePageState
      >(
        builder: (context, state) {
          final cubit = context.read<DeliveryUpdatePageCubit>();
          final enabled = cubit.billUploaded && !uploading;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!cubit.billUploaded)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TranslatedText(
                        text: "Upload the bill to enable Mark Delivered",
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyM_Regular,
                          color: FontColor.FontTertiary,
                        ),
                      ),
                    ),
                  BasketButton(
                    text: "Mark Delivered",
                    enabled: enabled,
                    loading: cubit.updatestat,
                    bgcolor: customColors().green600,
                    onpress:
                        enabled
                            ? () => cubit.updateMainOrderStat("complete")
                            : null,
                    textStyle: customTextStyle(
                      fontStyle: FontStyle.BodyL_Bold,
                      color: FontColor.White,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
