import 'dart:io';

import 'package:ansarlogistics/Driver/features/feature_document_upload/bloc/document_upload_page_cubit.dart';
import 'package:ansarlogistics/Driver/features/feature_document_upload/bloc/document_upload_page_state.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/scrollable_bottomsheet.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:picker_driver_api/responses/driver_base_response.dart';
import 'package:signature/signature.dart';

class DocumentUploadPage extends StatefulWidget {
  DataItem orderResponseItem;
  DocumentUploadPage({super.key, required this.orderResponseItem});

  @override
  State<DocumentUploadPage> createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends State<DocumentUploadPage> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3.0,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  bool uploading = false;
  bool uploaded = false;

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  bool _hasFile(dynamic data) {
    if (data == null || data == '') return false;
    if (data is XFile) return data.path.isNotEmpty;
    if (data is File) return data.path.isNotEmpty;
    return false;
  }

  String? _filePath(dynamic data) {
    if (data is XFile) return data.path;
    if (data is File) return data.path;
    return null;
  }

  IconData _iconFor(int index) {
    switch (index) {
      case 1:
        return Icons.badge_outlined;
      case 2:
        return Icons.edit_outlined;
      default:
        return Icons.draw_outlined;
    }
  }

  String _hintFor(int index) {
    switch (index) {
      case 1:
        return "Take a clear photo of the QID or passport";
      case 2:
        return "Draw or upload the driver signature";
      default:
        return "Draw or upload the customer signature";
    }
  }

  void _openItemSheet(int index) {
    final isQid = index == 1;
    customShowModalBottomSheet(
      context: context,
      inputWidget: Column(
        children: [
          if (isQid) ...[
            _sheetRow("Camera", Icons.camera_alt, () {
              Navigator.pop(context);
              context.read<DocumentUploadPageCubit>().captureIdImage(
                index,
                context,
                "camera",
              );
            }),
            _sheetRow("Gallery", Icons.photo_library_outlined, () {
              Navigator.pop(context);
              context.read<DocumentUploadPageCubit>().captureIdImage(
                index,
                context,
                "gallery",
              );
            }),
          ] else ...[
            _sheetRow("Draw signature", Icons.draw_outlined, () {
              Navigator.pop(context);
              _openSignaturePad(index);
            }),
            _sheetRow("Gallery", Icons.photo_library_outlined, () {
              Navigator.pop(context);
              context.read<DocumentUploadPageCubit>().captureIdImage(
                index,
                context,
                "gallery",
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _sheetRow(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 18.0),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: customColors().fontPrimary)),
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

  Future<void> _openSignaturePad(int index) async {
    _signatureController.clear();
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TranslatedText(
                  text: index == 2 ? "Driver signature" : "Customer signature",
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyL_Bold,
                    color: FontColor.FontPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: customColors().backgroundTertiary,
                      ),
                      color: Colors.white,
                    ),
                    child: Signature(
                      controller: _signatureController,
                      height: 280,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: BasketButton(
                        text: "Clear",
                        bgcolor: customColors().backgroundTertiary,
                        onpress: () => _signatureController.clear(),
                        textStyle: customTextStyle(
                          fontStyle: FontStyle.BodyL_Bold,
                          color: FontColor.FontPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: BasketButton(
                        text: "Save",
                        bgcolor: customColors().pacificBlue,
                        onpress: () async {
                          await context
                              .read<DocumentUploadPageCubit>()
                              .captureSignature(
                                _signatureController,
                                index,
                                context,
                              );
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        },
                        textStyle: customTextStyle(
                          fontStyle: FontStyle.BodyL_Bold,
                          color: FontColor.White,
                        ),
                      ),
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

  Widget _documentCard({
    required int index,
    required String title,
    required dynamic data,
  }) {
    final filled = _hasFile(data);
    final path = _filePath(data);
    final color =
        filled ? customColors().secretGarden : customColors().fontTertiary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TranslatedText(
                text: title,
                style: customTextStyle(
                  fontStyle: FontStyle.BodyL_Bold,
                  color: FontColor.FontPrimary,
                ),
              ),
              const Spacer(),
              TranslatedText(
                text: filled ? "Added" : "Required",
                style: customTextStyle(
                  fontStyle: FontStyle.BodyS_Bold,
                  color:
                      filled ? FontColor.SecretGarden : FontColor.FontTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TranslatedText(
            text: _hintFor(index),
            style: customTextStyle(
              fontStyle: FontStyle.BodyM_Regular,
              color: FontColor.FontTertiary,
            ),
          ),
          const SizedBox(height: 10),
          DottedBorder(
            options: RoundedRectDottedBorderOptions(
              radius: const Radius.circular(12),
              dashPattern: const [8, 5],
              color: color,
            ),
            child: InkWell(
              onTap: uploading ? null : () => _openItemSheet(index),
              child: Container(
                width: double.infinity,
                height: 150,
                alignment: Alignment.center,
                child:
                    filled && path != null
                        ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(File(path), fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: customColors().secretGarden,
                                  borderRadius: BorderRadius.circular(20),
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
                                      text: "Change",
                                      style: customTextStyle(
                                        fontStyle: FontStyle.BodyM_Bold,
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _iconFor(index),
                              size: 40,
                              color: customColors().fontTertiary,
                            ),
                            const SizedBox(height: 8),
                            TranslatedText(
                              text: "Tap to add",
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyM_SemiBold,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadDocuments() async {
    setState(() => uploading = true);
    await context.read<DocumentUploadPageCubit>().uploaddocuments(context);
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
                      text: "Upload Documents",
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
          BlocConsumer<DocumentUploadPageCubit, DocumentUploadPageState>(
            listener: (context, state) {
              if (state is UploadDocumentsSuccessState) {
                setState(() {
                  uploading = false;
                  uploaded = true;
                });
                final order =
                    context.read<DocumentUploadPageCubit>().orderResponseItem;
                if (order != null) {
                  context.gNavigationService.openDeliveryUpdatePage(
                    context,
                    arg: {'order': order},
                  );
                }
              }
              if (state is UploadDocumentsErrorState) {
                setState(() => uploading = false);
              }
            },
            builder: (context, state) {
              final cubit = context.read<DocumentUploadPageCubit>();
              final options = cubit.optionslist;

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
                            label: "Documents",
                            active: !uploaded,
                            done: uploaded,
                          ),
                          const SizedBox(width: 8),
                          _stepChip(
                            number: "2",
                            label: "Upload bill",
                            active: uploaded,
                            done: false,
                          ),
                          const SizedBox(width: 8),
                          _stepChip(
                            number: "3",
                            label: "Delivered",
                            active: false,
                            done: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TranslatedText(
                        text:
                            "Add all three documents, then upload. Bill photo unlocks after a successful upload.",
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyM_Regular,
                          color: FontColor.FontTertiary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(options.length, (index) {
                        return _documentCard(
                          index: index,
                          title: options[index]['name']?.toString() ?? '',
                          data: options[index]['data'],
                        );
                      }),
                      if (uploading) ...[
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          minHeight: 8,
                          backgroundColor: customColors().grey,
                          valueColor: AlwaysStoppedAnimation(
                            customColors().secretGarden,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TranslatedText(
                          text: "Uploading documents, please wait...",
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyM_Bold,
                            color: FontColor.SecretGarden,
                          ),
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
        DocumentUploadPageCubit,
        DocumentUploadPageState
      >(
        builder: (context, state) {
          final cubit = context.read<DocumentUploadPageCubit>();
          final allAdded = cubit.optionslist.every(
            (item) => _hasFile(item['data']),
          );
          final enabled = allAdded && !uploading && !uploaded;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!allAdded && !uploaded)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TranslatedText(
                        text: "Add all documents to enable upload",
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyM_Regular,
                          color: FontColor.FontTertiary,
                        ),
                      ),
                    ),
                  BasketButton(
                    text: uploaded ? "Documents uploaded" : "Upload documents",
                    enabled: enabled || uploaded,
                    loading: uploading,
                    bgcolor: customColors().green600,
                    onpress:
                        uploaded
                            ? () {
                              final order = cubit.orderResponseItem;
                              if (order != null) {
                                context.gNavigationService
                                    .openDeliveryUpdatePage(
                                      context,
                                      arg: {'order': order},
                                    );
                              }
                            }
                            : enabled
                            ? _uploadDocuments
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
