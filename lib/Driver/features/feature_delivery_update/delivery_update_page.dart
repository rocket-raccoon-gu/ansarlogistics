import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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

class _DeliveryUpdatePageState extends State<DeliveryUpdatePage>
    with SingleTickerProviderStateMixin {
  List<String> _pictures = [];

  final ImagePicker imagePicker = ImagePicker();

  XFile? image;

  File? result;

  bool upload = false;

  bool uploading = false;

  bool updatestat = false;

  Future<void>? getImage(String imgsource) async {
    _pictures.clear();
    bool isCameraGranted = await Permission.camera.request().isGranted;
    if (!isCameraGranted) {
      isCameraGranted =
          await Permission.camera.request() == PermissionStatus.granted;
    }

    if (!isCameraGranted) {
      // Have not permission to camera
      return;
    }
    if (isCameraGranted) {
      try {
        image = await imagePicker.pickImage(
          source:
              imgsource == "camera" ? ImageSource.camera : ImageSource.gallery,
        );
        final filePath = image!.path;
        final lastindex = filePath.lastIndexOf(new RegExp(r'.jp'));
        final splitted = filePath.substring(0, (lastindex));
        final outpath = "${splitted}_out${filePath.substring(lastindex)}";
        image = await FlutterImageCompress.compressAndGetFile(
          filePath,
          outpath,
          quality: 28,
        );

        Uint8List imagebytes = await image!.readAsBytes(); //convert to bytes
        // List<int> imageBytes = result.readAsBytesSync();
        print("image bytes path = " + imagebytes.toString());
        String base64string = base64.encode(imagebytes);
        print("base64 path = " + base64string.toString());
        Uint8List imag = base64.decode(base64string.toString());
        print("my path = " + imag.toString());
        _pictures.add(image!.path.toString());
        // if (controller != null) {
        //   image = await controller!.takePicture();
        //   if (!mounted) return;
        setState(() {});
        // }
      } catch (e) {
        showSnackBar(
          context: context,
          snackBar: showErrorDialogue(
            errorMessage: "Bill Image Not Captured Properly Try Again..!",
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double mheight = MediaQuery.of(context).size.height * 1.222;
    Size screenSize = MediaQuery.of(context).size;
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
                  width: 2.0,
                  color: customColors().backgroundTertiary,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: mheight * .012),
              child: Center(
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        context.gNavigationService.back(context);
                      },
                      icon: Icon(Icons.arrow_back_ios, size: 17.0),
                    ),
                    Expanded(
                      child: SizedBox(
                        width: double.maxFinite,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16.0,
                                bottom: 16.0,
                                top: 8.0,
                              ),
                              child: TranslatedText(
                                text: "Upload Bill Picture ",
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
                  ],
                ),
              ),
            ),
          ),
          BlocConsumer<DeliveryUpdatePageCubit, DeliveryUpdatePageState>(
            builder: (context, state) {
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: DottedBorder(
                        color: Colors.black, //color of dotted/dash line
                        strokeWidth: 3, //thickness of dash/dots
                        dashPattern: [10, 6],
                        //dash patterns, 10 is dash width, 6 is space width
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 50.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _pictures.isEmpty
                                        ? InkWell(
                                          onTap: () async {
                                            // getImage();
                                            customShowModalBottomSheet(
                                              context: context,
                                              inputWidget: Column(
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      getImage("camera");
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 18.0,
                                                            horizontal: 18.0,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                          bottom: BorderSide(
                                                            color:
                                                                customColors()
                                                                    .fontPrimary,
                                                          ),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          TranslatedText(
                                                            text: "Camera",
                                                            style: customTextStyle(
                                                              fontStyle:
                                                                  FontStyle
                                                                      .BodyL_Bold,
                                                              color:
                                                                  FontColor
                                                                      .FontPrimary,
                                                            ),
                                                          ),
                                                          Icon(
                                                            Icons.camera_alt,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      getImage("gallery");
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 18.0,
                                                            horizontal: 18.0,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                          bottom: BorderSide(
                                                            color:
                                                                customColors()
                                                                    .fontPrimary,
                                                          ),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          TranslatedText(
                                                            text: "Gallery",
                                                            style: customTextStyle(
                                                              fontStyle:
                                                                  FontStyle
                                                                      .BodyL_Bold,
                                                              color:
                                                                  FontColor
                                                                      .FontPrimary,
                                                            ),
                                                          ),
                                                          Icon(
                                                            Icons
                                                                .browse_gallery,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          child: Container(
                                            height: 210.0,
                                            width: 210.0,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color:
                                                    customColors()
                                                        .backgroundTertiary,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6.0),
                                            ),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.camera_alt_rounded,
                                                    size: 65.0,
                                                  ),
                                                  TranslatedText(
                                                    text: "Take Photo",
                                                    style: customTextStyle(
                                                      fontStyle:
                                                          FontStyle
                                                              .BodyM_SemiBold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                        : Padding(
                                          padding: const EdgeInsets.only(
                                            top: 25.0,
                                          ),
                                          child:
                                              image != null
                                                  ? Image.file(
                                                    File(
                                                      _pictures[_pictures
                                                              .length -
                                                          1],
                                                    ),
                                                    height: 210.0,
                                                    width: 210.0,
                                                  )
                                                  : Container(
                                                    height: 210.0,
                                                    width: 210.0,
                                                  ),
                                        ),
                                  ],
                                ),
                              ),
                              uploading
                                  ? Padding(
                                    padding: const EdgeInsets.only(
                                      top: 50.0,
                                      left: 10.0,
                                      right: 10.0,
                                    ),
                                    child: Column(
                                      children: [
                                        LinearProgressIndicator(
                                          minHeight: 12.0,
                                          backgroundColor: customColors().grey,
                                          valueColor: AlwaysStoppedAnimation(
                                            customColors().secretGarden,
                                          ),
                                          // value: context
                                          //     .read<ImageCaptureCubit>()
                                          //     .uploadprogress,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                          ),
                                          child: Text(
                                            "Uploading Please Wait....!",
                                            style: customTextStyle(
                                              fontStyle: FontStyle.BodyM_Bold,
                                              color: FontColor.SecretGarden,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  : SizedBox(height: 50),
                              _pictures.isNotEmpty
                                  ? Padding(
                                    padding: const EdgeInsets.only(top: 50.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                            bottom: 8.0,
                                          ),
                                          child: InkWell(
                                            onTap: () async {
                                              try {
                                                if (image
                                                        .toString()
                                                        .isNotEmpty ||
                                                    image != null) {
                                                  setState(() {
                                                    uploading = true;
                                                  });

                                                  File file = File(image!.path);

                                                  // print("image");
                                                  BlocProvider.of<
                                                    DeliveryUpdatePageCubit
                                                  >(context).uploadimage(file);
                                                } else {
                                                  showSnackBar(
                                                    context: context,
                                                    snackBar: showErrorDialogue(
                                                      errorMessage:
                                                          "Please Select a Picture",
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                showSnackBar(
                                                  context: context,
                                                  snackBar: showSnackBar(
                                                    context: context,
                                                    snackBar: showErrorDialogue(
                                                      errorMessage:
                                                          e.toString(),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24.0,
                                                    vertical: 9.0,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    _pictures.isEmpty
                                                        ? customColors()
                                                            .pacificBlue
                                                            .withOpacity(0.5)
                                                        : customColors()
                                                            .pacificBlue,
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                              child: Center(
                                                child: Row(
                                                  children: [
                                                    TranslatedText(
                                                      text: "Upload",
                                                      style: customTextStyle(
                                                        fontStyle:
                                                            FontStyle
                                                                .BodyM_Bold,
                                                        color: FontColor.White,
                                                      ),
                                                    ),
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                        left: 8.0,
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .cloud_upload_outlined,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8.0,
                                            bottom: 8.0,
                                          ),
                                          child: InkWell(
                                            onTap: () async {
                                              // getImage();

                                              setState(() {
                                                uploading = false;
                                              });
                                              customShowModalBottomSheet(
                                                context: context,
                                                inputWidget: Column(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        getImage("camera");
                                                      },
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              vertical: 18.0,
                                                              horizontal: 18.0,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          border: Border(
                                                            bottom: BorderSide(
                                                              color:
                                                                  customColors()
                                                                      .fontPrimary,
                                                            ),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            TranslatedText(
                                                              text: "Camera",
                                                              style: customTextStyle(
                                                                fontStyle:
                                                                    FontStyle
                                                                        .BodyL_Bold,
                                                                color:
                                                                    FontColor
                                                                        .FontPrimary,
                                                              ),
                                                            ),
                                                            Icon(
                                                              Icons.camera_alt,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        getImage("gallery");
                                                      },
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              vertical: 18.0,
                                                              horizontal: 18.0,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          border: Border(
                                                            bottom: BorderSide(
                                                              color:
                                                                  customColors()
                                                                      .fontPrimary,
                                                            ),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            TranslatedText(
                                                              text: "Gallery",
                                                              style: customTextStyle(
                                                                fontStyle:
                                                                    FontStyle
                                                                        .BodyL_Bold,
                                                                color:
                                                                    FontColor
                                                                        .FontPrimary,
                                                              ),
                                                            ),
                                                            Icon(
                                                              Icons
                                                                  .browse_gallery,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24.0,
                                                    vertical: 12.0,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    customColors().secretGarden,
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                              child: Center(
                                                child: TranslatedText(
                                                  text: "Retake",
                                                  style: customTextStyle(
                                                    fontStyle:
                                                        FontStyle.BodyM_Bold,
                                                    color: FontColor.White,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  : SizedBox(height: 100.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            listener: (context, state) {
              if (state is DeliveryBillUpdatedState) {
                setState(() {
                  upload = true;
                  uploading = false;
                });
              }

              if (state is DeliveryBillUpdateErrorState) {
                setState(() {
                  upload = false;
                });

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

              if (state is DeliveryStatusUpdateState) {
                setState(() {
                  updatestat = false;
                });
              }
            },
          ),
        ],
      ),
      bottomNavigationBar:
          upload
              ? SizedBox(
                height: screenSize.height * 0.10,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Divider(
                      thickness: 1.0,
                      color: customColors().backgroundTertiary,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: BasketButton(
                        loading:
                            context.read<DeliveryUpdatePageCubit>().updatestat,
                        text: "Update Delivery Status",
                        bgcolor: customColors().green600,
                        onpress: () async {
                          setState(() {
                            updatestat = true;
                          });

                          BlocProvider.of<DeliveryUpdatePageCubit>(
                            context,
                          ).updateMainOrderStat("complete");
                        },
                        textStyle: customTextStyle(
                          fontStyle: FontStyle.BodyL_Bold,
                          color: FontColor.White,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : SizedBox(),
    );
  }
}
