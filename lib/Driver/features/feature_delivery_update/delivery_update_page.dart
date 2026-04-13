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
import 'package:geolocator/geolocator.dart';
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
  bool updatestat = false;
  bool _isGettingLocation = false;
  Position? _currentPosition;

  final ImagePicker imagePicker = ImagePicker();

  XFile? image;

  File? result;

  bool upload = false;

  bool uploading = false;

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

        // Validate compressed image
        if (image == null) {
          throw Exception("Image compression failed");
        }

        Uint8List imagebytes = await image!.readAsBytes(); //convert to bytes

        // Validate image bytes
        if (imagebytes.isEmpty) {
          throw Exception("Compressed image is empty");
        }
        // List<int> imageBytes = result.readAsBytesSync();
        // print("image bytes path = " + imagebytes.toString());
        String base64string = base64.encode(imagebytes);
        // print("base64 path = " + base64string.toString());
        Uint8List imag = base64.decode(base64string.toString());
        // print("my path = " + imag.toString());
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
      body: BlocBuilder<DeliveryUpdatePageCubit, DeliveryUpdatePageState>(
        builder: (context, state) {
          return Column(
            children: [
              // Show linear progress indicator when location is updating
              if (state is DeliveryUpdatePageLoading)
                LinearProgressIndicator(
                  backgroundColor: customColors().backgroundTertiary,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    customColors().primary,
                  ),
                ),
              // Main content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
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
                      BlocConsumer<
                        DeliveryUpdatePageCubit,
                        DeliveryUpdatePageState
                      >(
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
                                text:
                                    "Failed To Upload Bill Please Try Again...!",
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
                        builder: (context, state) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: DottedBorder(
                                  // color: Colors.black, //color of dotted/dash line
                                  // strokeWidth: 3, //thickness of dash/dots
                                  // dashPattern: [10, 6],
                                  //dash patterns, 10 is dash width, 6 is space width
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 50.0,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
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
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                                getImage(
                                                                  "camera",
                                                                );
                                                              },
                                                              child: Container(
                                                                padding:
                                                                    EdgeInsets.symmetric(
                                                                      vertical:
                                                                          18.0,
                                                                      horizontal:
                                                                          18.0,
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
                                                                      text:
                                                                          "Camera",
                                                                      style: customTextStyle(
                                                                        fontStyle:
                                                                            FontStyle.BodyL_Bold,
                                                                        color:
                                                                            FontColor.FontPrimary,
                                                                      ),
                                                                    ),
                                                                    Icon(
                                                                      Icons
                                                                          .camera_alt,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                                getImage(
                                                                  "gallery",
                                                                );
                                                              },
                                                              child: Container(
                                                                padding:
                                                                    EdgeInsets.symmetric(
                                                                      vertical:
                                                                          18.0,
                                                                      horizontal:
                                                                          18.0,
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
                                                                      text:
                                                                          "Gallery",
                                                                      style: customTextStyle(
                                                                        fontStyle:
                                                                            FontStyle.BodyL_Bold,
                                                                        color:
                                                                            FontColor.FontPrimary,
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
                                                    child:
                                                        uploading
                                                            ? CircularProgressIndicator(
                                                              color:
                                                                  customColors()
                                                                      .pacificBlue,
                                                            )
                                                            : Column(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .camera_alt,
                                                                ),
                                                                TranslatedText(
                                                                  text:
                                                                      "Upload Bill",
                                                                  style: customTextStyle(
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .BodyL_Bold,
                                                                    color:
                                                                        FontColor
                                                                            .FontPrimary,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                  )
                                                  : Image.file(
                                                    File(_pictures[0]),
                                                    height: 220,
                                                    width: 220,
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Container(
                                                        height: 200,
                                                        color: Colors.grey[300],
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.broken_image,
                                                            size: 50,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                            ],
                                          ),
                                        ),
                                        _pictures.isNotEmpty
                                            ? Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 8.0,
                                                          bottom: 8.0,
                                                        ),
                                                    child: InkWell(
                                                      onTap: () async {
                                                        try {
                                                          if (_pictures
                                                              .isNotEmpty) {
                                                            setState(() {
                                                              uploading = true;
                                                            });

                                                            File file = File(
                                                              image!.path,
                                                            );

                                                            // print("image");
                                                            BlocProvider.of<
                                                              DeliveryUpdatePageCubit
                                                            >(
                                                              context,
                                                            ).uploadimage(file);
                                                          } else {
                                                            showSnackBar(
                                                              context: context,
                                                              snackBar:
                                                                  showErrorDialogue(
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
                                                              snackBar:
                                                                  showErrorDialogue(
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
                                                                      .withOpacity(
                                                                        0.5,
                                                                      )
                                                                  : customColors()
                                                                      .pacificBlue,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                5.0,
                                                              ),
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
                                                                  color:
                                                                      FontColor
                                                                          .White,
                                                                ),
                                                              ),
                                                              const Padding(
                                                                padding:
                                                                    EdgeInsets.only(
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
                                                    padding:
                                                        const EdgeInsets.only(
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
                                                                  Navigator.pop(
                                                                    context,
                                                                  );
                                                                  getImage(
                                                                    "camera",
                                                                  );
                                                                },
                                                                child: Container(
                                                                  padding: EdgeInsets.symmetric(
                                                                    vertical:
                                                                        18.0,
                                                                    horizontal:
                                                                        18.0,
                                                                  ),
                                                                  decoration: BoxDecoration(
                                                                    border: Border(
                                                                      bottom: BorderSide(
                                                                        color:
                                                                            customColors().fontPrimary,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      TranslatedText(
                                                                        text:
                                                                            "Camera",
                                                                        style: customTextStyle(
                                                                          fontStyle:
                                                                              FontStyle.BodyL_Bold,
                                                                          color:
                                                                              FontColor.FontPrimary,
                                                                        ),
                                                                      ),
                                                                      Icon(
                                                                        Icons
                                                                            .camera_alt,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              InkWell(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                    context,
                                                                  );
                                                                  getImage(
                                                                    "gallery",
                                                                  );
                                                                },
                                                                child: Container(
                                                                  padding: EdgeInsets.symmetric(
                                                                    vertical:
                                                                        18.0,
                                                                    horizontal:
                                                                        18.0,
                                                                  ),
                                                                  decoration: BoxDecoration(
                                                                    border: Border(
                                                                      bottom: BorderSide(
                                                                        color:
                                                                            customColors().fontPrimary,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      TranslatedText(
                                                                        text:
                                                                            "Gallery",
                                                                        style: customTextStyle(
                                                                          fontStyle:
                                                                              FontStyle.BodyL_Bold,
                                                                          color:
                                                                              FontColor.FontPrimary,
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
                                                              customColors()
                                                                  .secretGarden,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                5.0,
                                                              ),
                                                        ),
                                                        child: Center(
                                                          child: TranslatedText(
                                                            text: "Retake",
                                                            style: customTextStyle(
                                                              fontStyle:
                                                                  FontStyle
                                                                      .BodyL_Bold,
                                                              color:
                                                                  FontColor
                                                                      .White,
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

                                        // Location Section
                                        if (upload) ...[
                                          const SizedBox(height: 16),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                            ),
                                            child: Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: customColors().primary
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: customColors().primary
                                                      .withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  if (_currentPosition != null)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8.0,
                                                          ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.location_on,
                                                            size: 16,
                                                            color:
                                                                customColors()
                                                                    .primary,
                                                          ),
                                                          const SizedBox(
                                                            width: 6,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                                                              style: customTextStyle(
                                                                fontStyle:
                                                                    FontStyle
                                                                        .BodyM_Bold,
                                                                color:
                                                                    FontColor
                                                                        .FontPrimary,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          8.0,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        _currentPosition == null
                                                            ? Expanded(
                                                              child: BasketButton(
                                                                loading:
                                                                    _isGettingLocation,
                                                                text:
                                                                    _currentPosition ==
                                                                            null
                                                                        ? "Get Current Location"
                                                                        : "Update Location",
                                                                bgcolor:
                                                                    customColors()
                                                                        .primary,
                                                                onpress: () async {
                                                                  await _getCurrentLocation();
                                                                },
                                                                textStyle: customTextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .BodyL_Bold,
                                                                  color:
                                                                      FontColor
                                                                          .White,
                                                                ),
                                                              ),
                                                            )
                                                            : const SizedBox.shrink(),
                                                        if (_currentPosition !=
                                                            null) ...[
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Expanded(
                                                            child: BasketButton(
                                                              text:
                                                                  "Update Location",
                                                              bgcolor:
                                                                  customColors()
                                                                      .green600,
                                                              onpress: () async {
                                                                if (_currentPosition !=
                                                                    null) {
                                                                  BlocProvider.of<
                                                                    DeliveryUpdatePageCubit
                                                                  >(
                                                                    context,
                                                                  ).updateLocation(
                                                                    _currentPosition!
                                                                        .latitude,
                                                                    _currentPosition!
                                                                        .longitude,
                                                                  );
                                                                }
                                                              },
                                                              textStyle: customTextStyle(
                                                                fontStyle:
                                                                    FontStyle
                                                                        .BodyL_Bold,
                                                                color:
                                                                    FontColor
                                                                        .White,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  // SizedBox(height: 80), // Add padding for bottomNavigationBar
                  // <-- close Column children
                ),
                // <-- close Column
                // <-- close SingleChildScrollView
                // <-- close Expanded
              ),
            ],
          );
        },
      ),
      bottomNavigationBar:
          upload
              ? SizedBox(
                height: screenSize.height * 0.15,
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
    // <-- close SingleChildScrollView
    //
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        toastification.show(
          backgroundColor: customColors().warning,
          title: TranslatedText(
            text: "Location services are disabled. Please enable them.",
            style: customTextStyle(
              fontStyle: FontStyle.BodyL_Bold,
              color: FontColor.White,
            ),
          ),
          autoCloseDuration: const Duration(seconds: 3),
        );
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          toastification.show(
            backgroundColor: customColors().warning,
            title: TranslatedText(
              text: "Location permissions are denied.",
              style: customTextStyle(
                fontStyle: FontStyle.BodyL_Bold,
                color: FontColor.White,
              ),
            ),
            autoCloseDuration: const Duration(seconds: 3),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        toastification.show(
          backgroundColor: customColors().warning,
          title: TranslatedText(
            text: "Location permissions are permanently denied.",
            style: customTextStyle(
              fontStyle: FontStyle.BodyL_Bold,
              color: FontColor.White,
            ),
          ),
          autoCloseDuration: const Duration(seconds: 3),
        );
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = position;
        _isGettingLocation = false;
      });

      toastification.show(
        backgroundColor: customColors().green600,
        title: TranslatedText(
          text: "Location retrieved successfully!",
          style: customTextStyle(
            fontStyle: FontStyle.BodyL_Bold,
            color: FontColor.White,
          ),
        ),
        autoCloseDuration: const Duration(seconds: 2),
      );
    } catch (e) {
      setState(() {
        _isGettingLocation = false;
      });

      toastification.show(
        backgroundColor: customColors().warning,
        title: TranslatedText(
          text: "Failed to get location: ${e.toString()}",
          style: customTextStyle(
            fontStyle: FontStyle.BodyL_Bold,
            color: FontColor.White,
          ),
        ),
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
  }
}
