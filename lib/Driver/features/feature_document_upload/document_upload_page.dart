import 'dart:io';

import 'package:ansarlogistics/Driver/features/feature_document_upload/bloc/document_upload_page_cubit.dart';
import 'package:ansarlogistics/Driver/features/feature_document_upload/bloc/document_upload_page_state.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/scrollable_bottomsheet/scrollable_bottomsheet.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/order_response.dart';
import 'package:signature/signature.dart';

class DocumentUploadPage extends StatefulWidget {
  Order orderResponseItem;
  DocumentUploadPage({super.key, required this.orderResponseItem});

  @override
  State<DocumentUploadPage> createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends State<DocumentUploadPage> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5.0,
    penColor: Colors.black,
    exportBackgroundColor: customColors().backgroundPrimary,
  );

  final SignatureController _controllerdriver = SignatureController(
    penStrokeWidth: 5.0,
    penColor: Colors.black,
  );

  bool uploadload = false;

  bool updatestat = false;

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    _controllerdriver.dispose();
    super.dispose();
  }

  updatedata(SignatureController _controller, int index) async {
    BlocProvider.of<DocumentUploadPageCubit>(
      context,
    ).captureSignature(_controller, index, context);

    Navigator.pop(context);
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
          backgroundColor: Color.fromRGBO(183, 214, 53, 1),
        ),
      ),
      body: BlocConsumer<DocumentUploadPageCubit, DocumentUploadPageState>(
        listener: (context, state) {
          if (state is UploadDocumentsSuccessState) {
            setState(() {
              uploadload = false;
              updatestat = true;
            });
          }
          if (state is UploadDocumentsErrorState) {
            setState(() {
              uploadload = false;
            });
          }
        },
        builder: (context, state) {
          return Column(
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
                          icon: Icon(Icons.arrow_back, size: 17.0),
                        ),
                        Expanded(
                          child: SizedBox(
                            width: double.maxFinite,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    "Upload Documents",
                                    style: customTextStyle(
                                      fontStyle: FontStyle.BodyL_SemiBold,
                                      color: FontColor.FontSecondary,
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
              Expanded(
                child: Column(
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.all(15.0),
                    //   child: LinearPercentIndicator(
                    //     width: MediaQuery.of(context).size.width - 50,
                    //     animation: true,
                    //     lineHeight: 35.0,
                    //     animationDuration: 2000,
                    //     percent: context
                    //         .read<UploadDocumentsPageCubit>()
                    //         .barpercentage,
                    //     center: Text(
                    //         "${context.read<UploadDocumentsPageCubit>().barpercentagetext.toString()}%"),
                    //     linearStrokeCap: LinearStrokeCap.roundAll,
                    //     progressColor: Colors.greenAccent,
                    //     barRadius: Radius.circular(4.0),
                    //   ),
                    // ),
                    if (state is DocumentUploadInitialPageState)
                      ListView.builder(
                        itemCount: state.optionslist.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding:
                                index == state.optionslist.length - 1
                                    ? const EdgeInsets.only(
                                      top: 25,
                                      left: 8.0,
                                      right: 8.0,
                                    )
                                    : const EdgeInsets.only(
                                      top: 14.0,
                                      left: 8.0,
                                      right: 8.0,
                                    ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: Text(
                                    state.optionslist[index]['name'],
                                    style: customTextStyle(
                                      fontStyle: FontStyle.BodyL_SemiBold,
                                      color: FontColor.FontPrimary,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    if (index == 0) {
                                      customShowModalBottomSheet(
                                        context: context,
                                        inputWidget: Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
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
                                                    Text(
                                                      "Gallery",
                                                      style: customTextStyle(
                                                        fontStyle:
                                                            FontStyle
                                                                .BodyM_Bold,
                                                        color:
                                                            FontColor
                                                                .FontPrimary,
                                                      ),
                                                    ),
                                                    Icon(Icons.browse_gallery),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.pop(context);

                                                showDialog(
                                                  context: context,
                                                  builder: (
                                                    BuildContext context,
                                                  ) {
                                                    return Dialog(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20.0,
                                                            ),
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Signature(
                                                            controller:
                                                                _controller,
                                                            height: 320,
                                                            width: 320,
                                                            backgroundColor:
                                                                customColors()
                                                                    .backgroundPrimary,
                                                          ),
                                                          BasketButton(
                                                            onpress: () {
                                                              updatedata(
                                                                _controller,
                                                                index,
                                                              );
                                                            },
                                                            text: "Send",
                                                            bgcolor:
                                                                customColors()
                                                                    .dodgerBlue,
                                                            textStyle:
                                                                customTextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .BodyL_Bold,
                                                                  color:
                                                                      FontColor
                                                                          .White,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
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
                                                    Text(
                                                      "Draw Sign",
                                                      style: customTextStyle(
                                                        fontStyle:
                                                            FontStyle
                                                                .BodyM_Bold,
                                                        color:
                                                            FontColor
                                                                .FontPrimary,
                                                      ),
                                                    ),
                                                    Icon(Icons.draw_sharp),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else if (index == 1) {
                                      customShowModalBottomSheet(
                                        context: context,
                                        inputWidget: Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.pop(context);
                                                BlocProvider.of<
                                                  DocumentUploadPageCubit
                                                >(context).captureIdImage(
                                                  index,
                                                  context,
                                                  "camera",
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
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
                                                    Text(
                                                      "Camera",
                                                      style: customTextStyle(
                                                        fontStyle:
                                                            FontStyle
                                                                .BodyL_Bold,
                                                        color:
                                                            FontColor
                                                                .FontPrimary,
                                                      ),
                                                    ),
                                                    Icon(Icons.camera_alt),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.pop(context);
                                                BlocProvider.of<
                                                  DocumentUploadPageCubit
                                                >(context).captureIdImage(
                                                  index,
                                                  context,
                                                  "gallery",
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
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
                                                    Text(
                                                      "Gallery",
                                                      style: customTextStyle(
                                                        fontStyle:
                                                            FontStyle
                                                                .BodyL_Bold,
                                                        color:
                                                            FontColor
                                                                .FontPrimary,
                                                      ),
                                                    ),
                                                    Icon(Icons.browse_gallery),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else if (index == 2) {
                                      customShowModalBottomSheet(
                                        context: context,
                                        inputWidget: Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.pop(context);
                                                BlocProvider.of<
                                                  DocumentUploadPageCubit
                                                >(context).captureIdImage(
                                                  index,
                                                  context,
                                                  "gallery",
                                                );
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 18.0,
                                                      vertical: 18.0,
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
                                                    Text(
                                                      "Gallery",
                                                      style: customTextStyle(
                                                        fontStyle:
                                                            FontStyle
                                                                .BodyL_Bold,
                                                        color:
                                                            FontColor
                                                                .FontPrimary,
                                                      ),
                                                    ),
                                                    Icon(Icons.browse_gallery),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.pop(context);

                                                showDialog(
                                                  context: context,
                                                  builder: (
                                                    BuildContext context,
                                                  ) {
                                                    return Dialog(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20.0,
                                                            ),
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Signature(
                                                            controller:
                                                                _controllerdriver,
                                                            height: 320,
                                                            width: 320,
                                                            backgroundColor:
                                                                customColors()
                                                                    .backgroundPrimary,
                                                          ),
                                                          BasketButton(
                                                            onpress: () {
                                                              updatedata(
                                                                _controllerdriver,
                                                                index,
                                                              );
                                                            },
                                                            text: "Send",
                                                            bgcolor:
                                                                customColors()
                                                                    .dodgerBlue,
                                                            textStyle:
                                                                customTextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .BodyL_Bold,
                                                                  color:
                                                                      FontColor
                                                                          .White,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 18.0,
                                                      vertical: 18.0,
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
                                                    Text(
                                                      "Draw Sign",
                                                      style: customTextStyle(
                                                        fontStyle:
                                                            FontStyle
                                                                .BodyL_Bold,
                                                        color:
                                                            FontColor
                                                                .FontPrimary,
                                                      ),
                                                    ),
                                                    Icon(Icons.draw_sharp),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0,
                                      vertical: 25.0,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: customColors().grey,
                                      ),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Center(
                                      child:
                                          state.optionslist[index].containsKey(
                                                    'data',
                                                  ) &&
                                                  state.optionslist[index]['data'] !=
                                                      ""
                                              ? Image.file(
                                                File(
                                                  state
                                                      .optionslist[index]['data']
                                                      .path,
                                                ),
                                                height: 50.0,
                                                width: 50.0,
                                              )
                                              : Image.asset(
                                                state
                                                    .optionslist[index]['image'],
                                                height: 50.0,
                                                width: 50.0,
                                              ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    else if (state is UploadDocumentsSuccessState)
                      ListView.builder(
                        itemCount: state.optionslist.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding:
                                index == state.optionslist.length - 1
                                    ? const EdgeInsets.only(
                                      top: 25,
                                      left: 8.0,
                                      right: 8.0,
                                    )
                                    : const EdgeInsets.only(
                                      top: 14.0,
                                      left: 8.0,
                                      right: 8.0,
                                    ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: Text(
                                    state.optionslist[index]['name'],
                                    style: customTextStyle(
                                      fontStyle: FontStyle.BodyL_SemiBold,
                                      color: FontColor.FontPrimary,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    if (index == 0) {
                                      customShowModalBottomSheet(
                                        context: context,
                                        inputWidget: Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
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
                                                    Text(
                                                      "Gallery",
                                                      style: customTextStyle(
                                                        fontStyle:
                                                            FontStyle
                                                                .BodyM_Bold,
                                                        color:
                                                            FontColor
                                                                .FontPrimary,
                                                      ),
                                                    ),
                                                    Icon(Icons.browse_gallery),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.pop(context);

                                                showDialog(
                                                  context: context,
                                                  builder: (
                                                    BuildContext context,
                                                  ) {
                                                    return Dialog(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20.0,
                                                            ),
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Signature(
                                                            controller:
                                                                _controller,
                                                            height: 320,
                                                            width: 320,
                                                            backgroundColor:
                                                                customColors()
                                                                    .backgroundPrimary,
                                                          ),
                                                          BasketButton(
                                                            onpress: () {
                                                              updatedata(
                                                                _controller,
                                                                index,
                                                              );
                                                            },
                                                            text: "Send",
                                                            bgcolor:
                                                                customColors()
                                                                    .dodgerBlue,
                                                            textStyle:
                                                                customTextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .BodyL_Bold,
                                                                  color:
                                                                      FontColor
                                                                          .White,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
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
                                                    Text(
                                                      "Draw Sign",
                                                      style: customTextStyle(
                                                        fontStyle:
                                                            FontStyle
                                                                .BodyM_Bold,
                                                        color:
                                                            FontColor
                                                                .FontPrimary,
                                                      ),
                                                    ),
                                                    Icon(Icons.draw_sharp),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else if (index == 1) {
                                      customShowModalBottomSheet(
                                        context: context,
                                        inputWidget: Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.pop(context);
                                                BlocProvider.of<
                                                  DocumentUploadPageCubit
                                                >(context).captureIdImage(
                                                  index,
                                                  context,
                                                  "camera",
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
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
                                                    Text(
                                                      "Camera",
                                                      style: customTextStyle(
                                                        fontStyle:
                                                            FontStyle
                                                                .BodyL_Bold,
                                                        color:
                                                            FontColor
                                                                .FontPrimary,
                                                      ),
                                                    ),
                                                    Icon(Icons.camera_alt),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.pop(context);
                                                BlocProvider.of<
                                                  DocumentUploadPageCubit
                                                >(context).captureIdImage(
                                                  index,
                                                  context,
                                                  "gallery",
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
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
                                                    Text(
                                                      "Gallery",
                                                      style: customTextStyle(
                                                        fontStyle:
                                                            FontStyle
                                                                .BodyL_Bold,
                                                        color:
                                                            FontColor
                                                                .FontPrimary,
                                                      ),
                                                    ),
                                                    Icon(Icons.browse_gallery),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else if (index == 2) {
                                      customShowModalBottomSheet(
                                        context: context,
                                        inputWidget: Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.pop(context);
                                                BlocProvider.of<
                                                  DocumentUploadPageCubit
                                                >(context).captureIdImage(
                                                  index,
                                                  context,
                                                  "gallery",
                                                );
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 18.0,
                                                      vertical: 18.0,
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
                                                    Text(
                                                      "Gallery",
                                                      style: customTextStyle(
                                                        fontStyle:
                                                            FontStyle
                                                                .BodyL_Bold,
                                                        color:
                                                            FontColor
                                                                .FontPrimary,
                                                      ),
                                                    ),
                                                    Icon(Icons.browse_gallery),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.pop(context);

                                                showDialog(
                                                  context: context,
                                                  builder: (
                                                    BuildContext context,
                                                  ) {
                                                    return Dialog(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20.0,
                                                            ),
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Signature(
                                                            controller:
                                                                _controllerdriver,
                                                            height: 320,
                                                            width: 320,
                                                            backgroundColor:
                                                                customColors()
                                                                    .backgroundPrimary,
                                                          ),
                                                          BasketButton(
                                                            onpress: () {
                                                              updatedata(
                                                                _controllerdriver,
                                                                index,
                                                              );
                                                            },
                                                            text: "Send",
                                                            bgcolor:
                                                                customColors()
                                                                    .dodgerBlue,
                                                            textStyle:
                                                                customTextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .BodyL_Bold,
                                                                  color:
                                                                      FontColor
                                                                          .White,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 18.0,
                                                      vertical: 18.0,
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
                                                    Text(
                                                      "Draw Sign",
                                                      style: customTextStyle(
                                                        fontStyle:
                                                            FontStyle
                                                                .BodyL_Bold,
                                                        color:
                                                            FontColor
                                                                .FontPrimary,
                                                      ),
                                                    ),
                                                    Icon(Icons.draw_sharp),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0,
                                      vertical: 25.0,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: customColors().grey,
                                      ),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Center(
                                      child:
                                          state.optionslist[index].containsKey(
                                                    'data',
                                                  ) &&
                                                  state.optionslist[index]['data'] !=
                                                      ""
                                              ? Image.file(
                                                File(
                                                  state
                                                      .optionslist[index]['data']
                                                      .path,
                                                ),
                                                height: 50.0,
                                                width: 50.0,
                                              )
                                              : Image.asset(
                                                state
                                                    .optionslist[index]['image'],
                                                height: 50.0,
                                                width: 50.0,
                                              ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    else if (state is UploadDocumentsErrorState)
                      ListView.builder(
                        itemCount: state.optionslist.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding:
                                index == state.optionslist.length - 1
                                    ? const EdgeInsets.only(
                                      top: 25,
                                      left: 8.0,
                                      right: 8.0,
                                    )
                                    : const EdgeInsets.only(
                                      top: 14.0,
                                      left: 8.0,
                                      right: 8.0,
                                    ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: Text(
                                    state.optionslist[index]['name'],
                                    style: customTextStyle(
                                      fontStyle: FontStyle.BodyL_SemiBold,
                                      color: FontColor.FontPrimary,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    if (index == 0) {
                                      customShowModalBottomSheet(
                                        context: context,
                                        inputWidget: Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
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
                                                    Text(
                                                      "Gallery",
                                                      style: customTextStyle(
                                                        fontStyle:
                                                            FontStyle
                                                                .BodyM_Bold,
                                                        color:
                                                            FontColor
                                                                .FontPrimary,
                                                      ),
                                                    ),
                                                    Icon(Icons.browse_gallery),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.pop(context);

                                                showDialog(
                                                  context: context,
                                                  builder: (
                                                    BuildContext context,
                                                  ) {
                                                    return Dialog(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20.0,
                                                            ),
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Signature(
                                                            controller:
                                                                _controller,
                                                            height: 320,
                                                            width: 320,
                                                            backgroundColor:
                                                                customColors()
                                                                    .backgroundPrimary,
                                                          ),
                                                          BasketButton(
                                                            onpress: () {
                                                              updatedata(
                                                                _controller,
                                                                index,
                                                              );
                                                            },
                                                            text: "Send",
                                                            bgcolor:
                                                                customColors()
                                                                    .dodgerBlue,
                                                            textStyle:
                                                                customTextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .BodyL_Bold,
                                                                  color:
                                                                      FontColor
                                                                          .White,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
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
                                                    Text(
                                                      "Draw Sign",
                                                      style: customTextStyle(
                                                        fontStyle:
                                                            FontStyle
                                                                .BodyM_Bold,
                                                        color:
                                                            FontColor
                                                                .FontPrimary,
                                                      ),
                                                    ),
                                                    Icon(Icons.draw_sharp),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else if (index == 1) {
                                      customShowModalBottomSheet(
                                        context: context,
                                        inputWidget: Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.pop(context);
                                                BlocProvider.of<
                                                  DocumentUploadPageCubit
                                                >(context).captureIdImage(
                                                  index,
                                                  context,
                                                  "camera",
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
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
                                                    Text(
                                                      "Camera",
                                                      style: customTextStyle(
                                                        fontStyle:
                                                            FontStyle
                                                                .BodyL_Bold,
                                                        color:
                                                            FontColor
                                                                .FontPrimary,
                                                      ),
                                                    ),
                                                    Icon(Icons.camera_alt),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.pop(context);
                                                BlocProvider.of<
                                                  DocumentUploadPageCubit
                                                >(context).captureIdImage(
                                                  index,
                                                  context,
                                                  "gallery",
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
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
                                                    Text(
                                                      "Gallery",
                                                      style: customTextStyle(
                                                        fontStyle:
                                                            FontStyle
                                                                .BodyL_Bold,
                                                        color:
                                                            FontColor
                                                                .FontPrimary,
                                                      ),
                                                    ),
                                                    Icon(Icons.browse_gallery),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else if (index == 2) {
                                      customShowModalBottomSheet(
                                        context: context,
                                        inputWidget: Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.pop(context);
                                                BlocProvider.of<
                                                  DocumentUploadPageCubit
                                                >(context).captureIdImage(
                                                  index,
                                                  context,
                                                  "gallery",
                                                );
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 18.0,
                                                      vertical: 18.0,
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
                                                    Text(
                                                      "Gallery",
                                                      style: customTextStyle(
                                                        fontStyle:
                                                            FontStyle
                                                                .BodyL_Bold,
                                                        color:
                                                            FontColor
                                                                .FontPrimary,
                                                      ),
                                                    ),
                                                    Icon(Icons.browse_gallery),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.pop(context);

                                                showDialog(
                                                  context: context,
                                                  builder: (
                                                    BuildContext context,
                                                  ) {
                                                    return Dialog(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20.0,
                                                            ),
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Signature(
                                                            controller:
                                                                _controllerdriver,
                                                            height: 320,
                                                            width: 320,
                                                            backgroundColor:
                                                                customColors()
                                                                    .backgroundPrimary,
                                                          ),
                                                          BasketButton(
                                                            onpress: () {
                                                              updatedata(
                                                                _controllerdriver,
                                                                index,
                                                              );
                                                            },
                                                            text: "Send",
                                                            bgcolor:
                                                                customColors()
                                                                    .dodgerBlue,
                                                            textStyle:
                                                                customTextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .BodyL_Bold,
                                                                  color:
                                                                      FontColor
                                                                          .White,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 18.0,
                                                      vertical: 18.0,
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
                                                    Text(
                                                      "Draw Sign",
                                                      style: customTextStyle(
                                                        fontStyle:
                                                            FontStyle
                                                                .BodyL_Bold,
                                                        color:
                                                            FontColor
                                                                .FontPrimary,
                                                      ),
                                                    ),
                                                    Icon(Icons.draw_sharp),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0,
                                      vertical: 25.0,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: customColors().grey,
                                      ),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Center(
                                      child:
                                          state.optionslist[index].containsKey(
                                                    'data',
                                                  ) &&
                                                  state.optionslist[index]['data'] !=
                                                      ""
                                              ? Image.file(
                                                File(
                                                  state
                                                      .optionslist[index]['data']
                                                      .path,
                                                ),
                                                height: 50.0,
                                                width: 50.0,
                                              )
                                              : Image.asset(
                                                state
                                                    .optionslist[index]['image'],
                                                height: 50.0,
                                                width: 50.0,
                                              ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    else
                      SizedBox(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SizedBox(
        height: screenSize.height * 0.10,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Divider(thickness: 1.0, color: customColors().backgroundTertiary),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child:
                  updatestat
                      ? BasketButton(
                        onpress: () {
                          context.gNavigationService.openDeliveryUpdatePage(
                            context,
                            arg: {'order': widget.orderResponseItem},
                          );
                        },
                        text: "Update Delivery",
                        bgcolor: customColors().green1,
                        textStyle: customTextStyle(
                          fontStyle: FontStyle.BodyL_Bold,
                          color: FontColor.White,
                        ),
                      )
                      : BasketButton(
                        loading: uploadload,
                        text: "Upload Documents",
                        bgcolor: customColors().mattPurple,
                        onpress: () async {
                          setState(() {
                            uploadload = true;
                          });

                          BlocProvider.of<DocumentUploadPageCubit>(
                            context,
                          ).uploaddocuments(context);
                        },
                        textStyle: customTextStyle(
                          fontStyle: FontStyle.BodyL_Bold,
                          color: FontColor.White,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
