import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_replacement/bloc/item_replacement_page_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_replacement/bloc/item_replacement_page_state.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_replacement/ui/dynamic_grid.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/counter_button.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/custom_text_form_field.dart';
import 'package:ansarlogistics/components/loading_indecator.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:picker_driver_api/responses/order_response.dart';

class ItemReplacementPage extends StatefulWidget {
  EndPicking itemdata;
  ItemReplacementPage({super.key, required this.itemdata});

  @override
  State<ItemReplacementPage> createState() => _ItemReplacementPageState();
}

class _ItemReplacementPageState extends State<ItemReplacementPage> {
  String cancelreason = "Please Select Reason";

  TextEditingController commentcontroller = TextEditingController();

  TextEditingController barcodeController = new TextEditingController();

  late GlobalKey<FormState> idFormKey = GlobalKey<FormState>();

  int selectedindex = -1;

  bool loading = false;

  int editquantity = 0;

  bool isScanner = false;

  bool producebarcode = false;

  bool istextbarcode = false;

  Future<void> scanBarcodeNormal(String barcodeScanRes) async {
    await BlocProvider.of<ItemReplacementPageCubit>(
      context,
    ).getScannedProductData(barcodeScanRes, producebarcode);

    if (mounted) {
      setState(() {
        isScanner = false;
        istextbarcode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(elevation: 0, backgroundColor: HexColor('#F9FBFF')),
      ),
      backgroundColor: HexColor('#F9FBFF'),
      body: Builder(
        builder: (context) {
          if (isScanner) {
            // return MobileScanner(
            //     allowDuplicates: false,
            //     controller: MobileScannerController(facing: CameraFacing.back),
            //     onDetect: (barcode, args) {
            //       if (barcode.rawValue == null) {
            //         showSnackBar(
            //             context: context,
            //             snackBar: showErrorDialogue(
            //                 errorMessage: "Please Scan accurate...!"));
            //       } else {
            //         final String code = barcode.rawValue!;
            //         showSnackBar(
            //             context: context,
            //             snackBar: showSuccessDialogue(message: code));
            //         scanBarcodeNormal(code);
            //       }
            //     });
            return MobileScanner(
              onDetect: (barcodes) {
                //  if (barcodes.raw == null) {
                //     showSnackBar(
                //         context: context,
                //         snackBar: showErrorDialogue(
                //             errorMessage: "Please Scan accurate...!"));
                //   } else {
                //     final String code = barcodes.rawValue ?? '';
                //     final String code = barcodes.;
                //     showSnackBar(
                //         context: context,
                //         snackBar: showSuccessDialogue(message: code));
                //     scanBarcodeNormal(code);
                //   }
              },
            );
          } else if (istextbarcode) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    children: [
                      Row(children: [Text("Enter product barcode")]),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextFormField(
                              keyboardType: TextInputType.number,
                              bordercolor: customColors().fontTertiary,
                              context: context,
                              controller: barcodeController,
                              fieldName: "",
                              hintText: "Type here...",
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: BasketButton(
                          onpress: () async {
                            // context.read<ItemAddPageCubit>().updatedata(
                            //     barcodeController.text, producebarcode);
                            scanBarcodeNormal(barcodeController.text);
                          },
                          bgcolor: customColors().dodgerBlue,
                          text: "Enter",
                          textStyle: customTextStyle(
                            fontStyle: FontStyle.HeaderXS_Bold,
                            color: FontColor.White,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 10.0,
                  ),
                  decoration: BoxDecoration(
                    color: HexColor('#F9FBFF'),
                    border: Border(
                      bottom: BorderSide(
                        width: 2.0,
                        color: customColors().backgroundTertiary,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: customColors().backgroundTertiary.withOpacity(
                          1.0,
                        ),
                        spreadRadius: 3,
                        blurRadius: 5,
                        // offset: Offset(0, 3), // changes the position of the shadow
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          context.gNavigationService.back(context);
                        },
                        child: Icon(
                          Icons.arrow_back,
                          size: 23,
                          color: HexColor("#A3A3A3"),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Available Replacements",
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyL_Bold,
                                color: FontColor.FontPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 8.0,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Why Are You Replacing This Item ?",
                                    textAlign: TextAlign.start,
                                    style: customTextStyle(
                                      fontStyle: FontStyle.BodyL_Bold,
                                      color: FontColor.FontPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 10.0,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    border:
                                        cancelreason == "Please Select Reason"
                                            ? Border.all(
                                              color: customColors().danger,
                                            )
                                            : Border.all(
                                              color: HexColor('#F0F0F0'),
                                            ),
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      // value: true,
                                      items:
                                          replacereasons.map((item) {
                                            return DropdownMenuItem(
                                              value: item,
                                              child: Text(item),
                                            );
                                          }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          cancelreason = value!;
                                        });
                                        // changereasons!(value);
                                      },
                                      hint: Text(
                                        cancelreason,
                                        style: customTextStyle(
                                          fontStyle: FontStyle.BodyM_Bold,
                                          color: FontColor.FontPrimary,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                      style: TextStyle(
                                        color: Colors.black,
                                        decorationColor: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              cancelreason == "Other Reasons"
                                  ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                    ),
                                    child: CustomTextFormField(
                                      context: context,
                                      maxLines: 3,
                                      bordercolor: customColors().fontSecondary,
                                      controller: commentcontroller,
                                      fieldName: "Please fill the reason",
                                      hintText: "Enter Reason..",
                                      validator: Validator.defaultValidator,
                                      onFieldSubmit: (p0) {
                                        if (idFormKey.currentState != null) {
                                          if (!idFormKey.currentState!
                                              .validate())
                                            return "Please fill the reason";
                                        }
                                      },
                                    ),
                                  )
                                  : SizedBox(),
                              BlocConsumer<
                                ItemReplacementPageCubit,
                                ItemReplacementPageState
                              >(
                                listener: (context, state) {
                                  if (state is ItemReplacementInitail) {
                                    setState(() {
                                      loading = false;
                                    });
                                  }
                                },
                                builder: (context, state) {
                                  if (state is ItemReplacementInitail) {
                                    if (state.prwork != null) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          state
                                                  .prwork!
                                                  .mediaGalleryEntries
                                                  .isNotEmpty
                                              ? Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 4.0,
                                                    ),
                                                child: FutureBuilder(
                                                  future: getData(),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData) {
                                                      Map<String, dynamic>
                                                      data = snapshot.data!;

                                                      return SizedBox(
                                                        height: 275.0,
                                                        width: 275.0,
                                                        child: Center(
                                                          child: CachedNetworkImage(
                                                            imageUrl:
                                                                '${data['imagepath']}${state.prwork!.mediaGalleryEntries[0].file}',
                                                            imageBuilder: (
                                                              context,
                                                              imageProvider,
                                                            ) {
                                                              return Container(
                                                                decoration: BoxDecoration(
                                                                  image: DecorationImage(
                                                                    image:
                                                                        imageProvider,
                                                                    fit:
                                                                        BoxFit
                                                                            .cover,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            placeholder:
                                                                (
                                                                  context,
                                                                  url,
                                                                ) => Center(
                                                                  child: Image.asset(
                                                                    'assets/Iphone_spinner.gif',
                                                                  ),
                                                                ),
                                                            errorWidget: (
                                                              context,
                                                              url,
                                                              error,
                                                            ) {
                                                              return Image.asset(
                                                                '${noimageurl}',
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      return SizedBox(
                                                        height: 275.0,
                                                        width: 275.0,
                                                        child: Center(
                                                          child: CachedNetworkImage(
                                                            imageUrl:
                                                                "${mainimageurl}${state.prwork!.mediaGalleryEntries[0].file}",
                                                            imageBuilder: (
                                                              context,
                                                              imageProvider,
                                                            ) {
                                                              return Container(
                                                                decoration: BoxDecoration(
                                                                  image: DecorationImage(
                                                                    image:
                                                                        imageProvider,
                                                                    fit:
                                                                        BoxFit
                                                                            .cover,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            placeholder:
                                                                (
                                                                  context,
                                                                  url,
                                                                ) => Center(
                                                                  child: Image.asset(
                                                                    'assets/Iphone_spinner.gif',
                                                                  ),
                                                                ),
                                                            errorWidget: (
                                                              context,
                                                              url,
                                                              error,
                                                            ) {
                                                              return Image.network(
                                                                '${noimageurl}',
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                              )
                                              : Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 4.0,
                                                    ),
                                                child: Container(
                                                  height: 275.0,
                                                  width: 275.0,
                                                  child: Image.network(
                                                    '${noimageurl}',
                                                  ),
                                                ),
                                              ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                            ),
                                            child: SizedBox(
                                              height: 60,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    state
                                                        .prwork!
                                                        .mediaGalleryEntries
                                                        .length,
                                                itemBuilder: (context, index) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8.0,
                                                        ),
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedindex = index;
                                                        });
                                                      },
                                                      child: Container(
                                                        height: 60.0,
                                                        width: 60.0,
                                                        decoration: BoxDecoration(
                                                          border: Border(
                                                            bottom: BorderSide(
                                                              width: 3.0,
                                                              color:
                                                                  selectedindex ==
                                                                          index
                                                                      ? Color.fromRGBO(
                                                                        183,
                                                                        214,
                                                                        53,
                                                                        1,
                                                                      )
                                                                      : Colors
                                                                          .transparent,
                                                            ),
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: CachedNetworkImage(
                                                            imageUrl:
                                                                "${mainimageurl}${state.prwork!.mediaGalleryEntries[index].file}",
                                                            imageBuilder: (
                                                              context,
                                                              imageProvider,
                                                            ) {
                                                              return Container(
                                                                decoration: BoxDecoration(
                                                                  image: DecorationImage(
                                                                    image:
                                                                        imageProvider,
                                                                    fit:
                                                                        BoxFit
                                                                            .cover,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            placeholder:
                                                                (
                                                                  context,
                                                                  url,
                                                                ) => Center(
                                                                  child: Image.asset(
                                                                    'assets/Iphone_spinner.gif',
                                                                  ),
                                                                ),
                                                            errorWidget: (
                                                              context,
                                                              url,
                                                              error,
                                                            ) {
                                                              return Image.network(
                                                                '${noimageurl}',
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16.0,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: HexColor('#F9FBFF'),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: customColors()
                                                        .backgroundTertiary
                                                        .withOpacity(0.7),
                                                    spreadRadius: 1,
                                                    blurRadius: 8,
                                                    offset: Offset(
                                                      0,
                                                      8,
                                                    ), // changes the position of the shadow
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16.0,
                                                    ),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            state.prwork!.name,
                                                            style: customTextStyle(
                                                              fontStyle:
                                                                  FontStyle
                                                                      .HeaderXS_Bold,
                                                              color:
                                                                  FontColor
                                                                      .FontPrimary,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Text(
                                                                context
                                                                        .read<
                                                                          ItemReplacementPageCubit
                                                                        >()
                                                                        .isSpecialPriceActive
                                                                    ? context
                                                                        .read<
                                                                          ItemReplacementPageCubit
                                                                        >()
                                                                        .specialPrice
                                                                        .toString()
                                                                    : double.parse(
                                                                      state
                                                                          .prwork!
                                                                          .price
                                                                          .toString(),
                                                                    ).toStringAsFixed(
                                                                      2,
                                                                    ),
                                                                style: customTextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .HeaderXS_Bold,
                                                                  color:
                                                                      FontColor
                                                                          .FontPrimary,
                                                                ),
                                                              ),
                                                              Text(
                                                                "  QAR",
                                                                style: customTextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .BodyL_Bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 8.0,
                                                          ),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                // "SKU: ${state.prwork!.sku}",
                                                                "SKU: ${context.read<ItemReplacementPageCubit>().showsku}",
                                                                style: customTextStyle(
                                                                  fontStyle:
                                                                      FontStyle
                                                                          .HeaderXS_Bold,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 12.0,
                                                            horizontal: 14.0,
                                                          ),
                                                      child: CounterContainer(
                                                        initNumber: 1,
                                                        counterCallback: (v) {
                                                          setState(() {
                                                            // editquantity = v;
                                                          });
                                                        },
                                                        increaseCallback: () {},
                                                        decreaseCallback: () {
                                                          print("mm");
                                                          // stateSetter(() => op = true);
                                                        },
                                                        minNumber: 0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ),
                                            child: Container(
                                              height: 275.0,
                                              width: 275.0,
                                              child: Center(
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      '${mainimageurl}${state.itemdata!.productImages[0]}',
                                                  imageBuilder: (
                                                    context,
                                                    imageProvider,
                                                  ) {
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  placeholder:
                                                      (context, url) => Center(
                                                        child: Image.asset(
                                                          'assets/Iphone_spinner.gif',
                                                        ),
                                                      ),
                                                  errorWidget: (
                                                    context,
                                                    url,
                                                    error,
                                                  ) {
                                                    return Image.network(
                                                      '${noimageurl}',
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: HexColor('#F9FBFF'),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: customColors()
                                                      .backgroundTertiary
                                                      .withOpacity(0.7),
                                                  spreadRadius: 1,
                                                  blurRadius: 8,
                                                  offset: Offset(
                                                    0,
                                                    8,
                                                  ), // changes the position of the shadow
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16.0,
                                                    vertical: 18.0,
                                                  ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          state
                                                              .itemdata!
                                                              .productName,
                                                          style: customTextStyle(
                                                            fontStyle:
                                                                FontStyle
                                                                    .HeaderXS_Bold,
                                                            color:
                                                                FontColor
                                                                    .FontPrimary,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Text(
                                                              double.parse(
                                                                state
                                                                    .itemdata!
                                                                    .price
                                                                    .toString(),
                                                              ).toStringAsFixed(
                                                                2,
                                                              ),
                                                              style: customTextStyle(
                                                                fontStyle:
                                                                    FontStyle
                                                                        .HeaderXS_Bold,
                                                                color:
                                                                    FontColor
                                                                        .FontPrimary,
                                                              ),
                                                            ),
                                                            Text(
                                                              "  QAR",
                                                              style: customTextStyle(
                                                                fontStyle:
                                                                    FontStyle
                                                                        .BodyL_Bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 8.0,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          state
                                                              .itemdata!
                                                              .productSku,
                                                          style: customTextStyle(
                                                            fontStyle:
                                                                FontStyle
                                                                    .BodyM_Bold,
                                                            color:
                                                                FontColor
                                                                    .FontSecondary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          context
                                                      .read<
                                                        ItemReplacementPageCubit
                                                      >()
                                                      .prvalue ==
                                                  0
                                              ? DynamicGrid(
                                                replacements:
                                                    state.replacements,
                                                selectedindex: selectedindex,
                                                onSelect: (p0) {
                                                  setState(() {
                                                    selectedindex = p0;
                                                  });
                                                },
                                              )
                                              : Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 8.0,
                                                        ),
                                                    child: Image.asset(
                                                      'assets/repost.png',
                                                      height: 20.0,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 8.0,
                                                        ),
                                                    child: Text(
                                                      "Replace To",
                                                      style: customTextStyle(
                                                        fontStyle:
                                                            FontStyle
                                                                .BodyM_Bold,
                                                        color:
                                                            FontColor
                                                                .FontPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 8.0,
                                                          horizontal: 8.0,
                                                        ),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            border: Border.all(
                                                              color:
                                                                  customColors()
                                                                      .fontPrimary,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  5.0,
                                                                ),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Column(
                                                                children: [
                                                                  FutureBuilder(
                                                                    future:
                                                                        getData(),
                                                                    builder: (
                                                                      context,
                                                                      snapshot,
                                                                    ) {
                                                                      if (snapshot
                                                                          .hasData) {
                                                                        Map<
                                                                          String,
                                                                          dynamic
                                                                        >
                                                                        data =
                                                                            snapshot.data!;

                                                                        return SizedBox(
                                                                          height:
                                                                              120.0,
                                                                          width:
                                                                              120.0,
                                                                          child: ClipRRect(
                                                                            borderRadius: BorderRadius.circular(
                                                                              10.0,
                                                                            ),
                                                                            child:
                                                                                BlocProvider.of<
                                                                                      ItemReplacementPageCubit
                                                                                    >(
                                                                                      context,
                                                                                    ).prwork!.mediaGalleryEntries.isNotEmpty
                                                                                    ? CachedNetworkImage(
                                                                                      imageUrl:
                                                                                          '${data['imagepath']}${BlocProvider.of<ItemReplacementPageCubit>(context).prwork!.mediaGalleryEntries[0].file}',
                                                                                      imageBuilder: (
                                                                                        context,
                                                                                        imageProvider,
                                                                                      ) {
                                                                                        return Container(
                                                                                          decoration: BoxDecoration(
                                                                                            image: DecorationImage(
                                                                                              image:
                                                                                                  imageProvider,
                                                                                              fit:
                                                                                                  BoxFit.cover,
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                      placeholder:
                                                                                          (
                                                                                            context,
                                                                                            url,
                                                                                          ) => Center(
                                                                                            child: Image.asset(
                                                                                              'assets/Iphone_spinner.gif',
                                                                                            ),
                                                                                          ),
                                                                                      errorWidget: (
                                                                                        context,
                                                                                        url,
                                                                                        error,
                                                                                      ) {
                                                                                        return Image.asset(
                                                                                          'assets/placeholder.png',
                                                                                        );
                                                                                      },
                                                                                    )
                                                                                    : Image.network(
                                                                                      '${noimageurl}',
                                                                                    ),
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        return SizedBox(
                                                                          height:
                                                                              120.0,
                                                                          width:
                                                                              120.0,
                                                                          child: ClipRRect(
                                                                            borderRadius: BorderRadius.circular(
                                                                              10.0,
                                                                            ),
                                                                            child:
                                                                                BlocProvider.of<
                                                                                      ItemReplacementPageCubit
                                                                                    >(
                                                                                      context,
                                                                                    ).prwork!.mediaGalleryEntries.isNotEmpty
                                                                                    ? CachedNetworkImage(
                                                                                      imageUrl:
                                                                                          '${mainimageurl}${BlocProvider.of<ItemReplacementPageCubit>(context).prwork!.mediaGalleryEntries[0].file}',
                                                                                      imageBuilder: (
                                                                                        context,
                                                                                        imageProvider,
                                                                                      ) {
                                                                                        return Container(
                                                                                          decoration: BoxDecoration(
                                                                                            image: DecorationImage(
                                                                                              image:
                                                                                                  imageProvider,
                                                                                              fit:
                                                                                                  BoxFit.cover,
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                      placeholder:
                                                                                          (
                                                                                            context,
                                                                                            url,
                                                                                          ) => Center(
                                                                                            child: Image.asset(
                                                                                              'assets/Iphone_spinner.gif',
                                                                                            ),
                                                                                          ),
                                                                                      errorWidget: (
                                                                                        context,
                                                                                        url,
                                                                                        error,
                                                                                      ) {
                                                                                        return Image.asset(
                                                                                          'assets/placeholder.png',
                                                                                        );
                                                                                      },
                                                                                    )
                                                                                    : Image.network(
                                                                                      '${noimageurl}',
                                                                                    ),
                                                                          ),
                                                                        );
                                                                      }
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                              Expanded(
                                                                child: Column(
                                                                  children: [
                                                                    Container(
                                                                      decoration: BoxDecoration(
                                                                        border: Border(
                                                                          left: BorderSide(
                                                                            color:
                                                                                customColors().fontPrimary,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              8.0,
                                                                        ),
                                                                        child: Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                Expanded(
                                                                                  child: Text(
                                                                                    BlocProvider.of<
                                                                                      ItemReplacementPageCubit
                                                                                    >(
                                                                                      context,
                                                                                    ).prwork!.name,
                                                                                    style: customTextStyle(
                                                                                      fontStyle:
                                                                                          FontStyle.Inter_Medium,
                                                                                      color:
                                                                                          FontColor.FontPrimary,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.symmetric(
                                                                                vertical:
                                                                                    10.0,
                                                                                horizontal:
                                                                                    3.0,
                                                                              ),
                                                                              child: Row(
                                                                                children: [
                                                                                  Text(
                                                                                    "SKU : ",
                                                                                    style: customTextStyle(
                                                                                      fontStyle:
                                                                                          FontStyle.BodyL_Bold,
                                                                                      color:
                                                                                          FontColor.FontSecondary,
                                                                                    ),
                                                                                  ),
                                                                                  Text(
                                                                                    BlocProvider.of<
                                                                                      ItemReplacementPageCubit
                                                                                    >(
                                                                                      context,
                                                                                    ).prwork!.sku,
                                                                                    style: customTextStyle(
                                                                                      fontStyle:
                                                                                          FontStyle.BodyM_Bold,
                                                                                      color:
                                                                                          FontColor.FontPrimary,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Row(
                                                                              mainAxisAlignment:
                                                                                  MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(
                                                                                    left:
                                                                                        2.0,
                                                                                  ),
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Text(
                                                                                        "Price :",
                                                                                        style: customTextStyle(
                                                                                          fontStyle:
                                                                                              FontStyle.BodyL_Bold,
                                                                                        ),
                                                                                      ),
                                                                                      Text(
                                                                                        double.parse(
                                                                                          BlocProvider.of<
                                                                                            ItemReplacementPageCubit
                                                                                          >(
                                                                                            context,
                                                                                          ).prwork!.price,
                                                                                        ).toStringAsFixed(
                                                                                          2,
                                                                                        ),
                                                                                        style: customTextStyle(
                                                                                          fontStyle:
                                                                                              FontStyle.Inter_SemiBold,
                                                                                          color:
                                                                                              FontColor.FontPrimary,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        ],
                                      );
                                    }
                                  } else if (state is ItemLoading) {
                                    return const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(top: 60.0),
                                          child: LoadingIndecator(),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          child: Container(
                                            height: 275.0,
                                            width: 275.0,
                                            child: Center(
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    "${mainimageurl}${widget.itemdata.productImages[0]}",
                                                imageBuilder: (
                                                  context,
                                                  imageProvider,
                                                ) {
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                placeholder:
                                                    (context, url) => Center(
                                                      child: Image.asset(
                                                        'assets/Iphone_spinner.gif',
                                                      ),
                                                    ),
                                                errorWidget: (
                                                  context,
                                                  url,
                                                  error,
                                                ) {
                                                  return Image.asset(
                                                    'assets/placeholder.png',
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: HexColor('#F9FBFF'),
                                            boxShadow: [
                                              BoxShadow(
                                                color: customColors()
                                                    .backgroundTertiary
                                                    .withOpacity(0.7),
                                                spreadRadius: 1,
                                                blurRadius: 8,
                                                offset: Offset(
                                                  0,
                                                  8,
                                                ), // changes the position of the shadow
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0,
                                              vertical: 18.0,
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        widget
                                                            .itemdata
                                                            .productName,
                                                        style: customTextStyle(
                                                          fontStyle:
                                                              FontStyle
                                                                  .HeaderXS_Bold,
                                                          color:
                                                              FontColor
                                                                  .FontPrimary,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            double.parse(
                                                              widget
                                                                  .itemdata
                                                                  .price
                                                                  .toString(),
                                                            ).toStringAsFixed(
                                                              2,
                                                            ),
                                                            style: customTextStyle(
                                                              fontStyle:
                                                                  FontStyle
                                                                      .HeaderXS_Bold,
                                                              color:
                                                                  FontColor
                                                                      .FontPrimary,
                                                            ),
                                                          ),
                                                          Text(
                                                            "  QAR",
                                                            style: customTextStyle(
                                                              fontStyle:
                                                                  FontStyle
                                                                      .BodyL_Bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 8.0,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        widget
                                                            .itemdata
                                                            .productSku,
                                                        style: customTextStyle(
                                                          fontStyle:
                                                              FontStyle
                                                                  .BodyM_Bold,
                                                          color:
                                                              FontColor
                                                                  .FontSecondary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: SizedBox(
        height: screenSize.height * 0.17,
        child:
            BlocProvider.of<ItemReplacementPageCubit>(context).prwork != null ||
                    selectedindex != -1
                ? Stack(
                  children: [
                    Positioned(
                      child:
                          loading
                              ? LinearProgressIndicator(
                                color: customColors().secretGarden,
                              )
                              : SizedBox(),
                    ),
                    Column(
                      children: [
                        Divider(
                          thickness: 1.0,
                          color: customColors().backgroundTertiary,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 5.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Produce Barcode",
                                style: customTextStyle(
                                  fontStyle: FontStyle.BodyL_SemiBold,
                                ),
                              ),
                              Checkbox(
                                value: producebarcode,
                                onChanged: (val) {
                                  setState(() {
                                    producebarcode = val!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                ),
                                child: BasketButtonwithIcon(
                                  onpress: () {
                                    if (cancelreason !=
                                        "Please Select Reason") {
                                      if (BlocProvider.of<
                                            ItemReplacementPageCubit
                                          >(context).prwork !=
                                          null) {
                                        // item from scan

                                        if (editquantity != 0) {
                                          setState(() {
                                            loading = true;
                                          });

                                          BlocProvider.of<
                                            ItemReplacementPageCubit
                                          >(context).updatereplacement(
                                            selectedindex,
                                            cancelreason,
                                            editquantity,
                                            context,
                                            context
                                                    .read<
                                                      ItemReplacementPageCubit
                                                    >()
                                                    .isSpecialPriceActive
                                                ? context
                                                    .read<
                                                      ItemReplacementPageCubit
                                                    >()
                                                    .specialPrice
                                                    .toString()
                                                : double.parse(
                                                  context
                                                      .read<
                                                        ItemReplacementPageCubit
                                                      >()
                                                      .prwork!
                                                      .price
                                                      .toString(),
                                                ).toStringAsFixed(2),
                                          );
                                        } else {
                                          setState(() {
                                            loading = true;
                                          });

                                          BlocProvider.of<
                                            ItemReplacementPageCubit
                                          >(context).updatereplacement(
                                            selectedindex,
                                            cancelreason,
                                            0,
                                            context,
                                            context
                                                    .read<
                                                      ItemReplacementPageCubit
                                                    >()
                                                    .isSpecialPriceActive
                                                ? context
                                                    .read<
                                                      ItemReplacementPageCubit
                                                    >()
                                                    .specialPrice
                                                    .toString()
                                                : double.parse(
                                                  context
                                                      .read<
                                                        ItemReplacementPageCubit
                                                      >()
                                                      .prwork!
                                                      .price
                                                      .toString(),
                                                ).toStringAsFixed(2),
                                          );
                                          // : double.parse(state
                                          //         .prwork!
                                          //         .price
                                          //         .toString())
                                          //     .toStringAsFixed(
                                          //         2));
                                        }
                                      } else {
                                        // items from similiar products

                                        if (selectedindex != -1) {
                                          setState(() {
                                            loading = true;
                                          });

                                          BlocProvider.of<
                                            ItemReplacementPageCubit
                                          >(context).updatereplacement(
                                            selectedindex,
                                            cancelreason,
                                            editquantity,
                                            context,
                                            context
                                                    .read<
                                                      ItemReplacementPageCubit
                                                    >()
                                                    .isSpecialPriceActive
                                                ? context
                                                    .read<
                                                      ItemReplacementPageCubit
                                                    >()
                                                    .specialPrice
                                                    .toString()
                                                : double.parse(
                                                  context
                                                      .read<
                                                        ItemReplacementPageCubit
                                                      >()
                                                      .relatableitems[selectedindex]
                                                      .price
                                                      .toString(),
                                                ).toStringAsFixed(2),
                                          );
                                        } else {
                                          showSnackBar(
                                            context: context,
                                            snackBar: showErrorDialogue(
                                              errorMessage:
                                                  "Please Select Replacement Item....!",
                                            ),
                                          );
                                        }
                                      }
                                    } else {
                                      showSnackBar(
                                        context: context,
                                        snackBar: showErrorDialogue(
                                          errorMessage:
                                              "Please Select the Reason",
                                        ),
                                      );
                                    }
                                  },
                                  textStyle: customTextStyle(
                                    fontStyle: FontStyle.BodyL_Bold,
                                    color: FontColor.White,
                                  ),
                                  loading: loading,
                                  bgcolor: customColors().dodgerBlue,
                                  text: "Submit",
                                  image: "assets/topick.png",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                )
                : Stack(
                  children: [
                    Positioned(
                      child:
                          loading
                              ? LinearProgressIndicator(
                                color: customColors().secretGarden,
                              )
                              : SizedBox(),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Divider(
                          thickness: 1.0,
                          color: customColors().backgroundTertiary,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 5.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Produce Barcode",
                                style: customTextStyle(
                                  fontStyle: FontStyle.BodyL_SemiBold,
                                ),
                              ),
                              Checkbox(
                                value: producebarcode,
                                onChanged: (val) {
                                  setState(() {
                                    producebarcode = val!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 10.0,
                                  right: 15.0,
                                ),
                                child: LayoutBuilder(
                                  builder: (context, constrains) {
                                    bool istablet = constrains.maxWidth > 400;

                                    return Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: customColors().fontTertiary,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          5.0,
                                        ),
                                      ),
                                      child: BasketButtonwithIcon(
                                        onpress: () {
                                          // scanBarcodeNormal();

                                          setState(() {
                                            isScanner = true;
                                          });
                                        },
                                        image: "assets/noun_scan.png",
                                        text: "Scan Item",
                                        imagecolor: customColors().dodgerBlue,
                                        textStyle: customTextStyle(
                                          fontStyle: FontStyle.BodyL_Bold,
                                          color: FontColor.FontPrimary,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // submit change to type barcode
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 10.0,
                                  right: 15.0,
                                ),
                                child: LayoutBuilder(
                                  builder: (context, constrains) {
                                    bool isTablet = constrains.maxWidth > 400;

                                    return BasketButtonwithIcon(
                                      onpress: () {
                                        setState(() {
                                          istextbarcode = true;
                                        });
                                      },
                                      text: "Text Barcode",
                                      image: "assets/font.png",
                                      bgcolor: customColors().pacificBlue,
                                      textStyle: customTextStyle(
                                        fontStyle: FontStyle.BodyL_Bold,
                                        color: FontColor.White,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
      ),
    );
  }
}
