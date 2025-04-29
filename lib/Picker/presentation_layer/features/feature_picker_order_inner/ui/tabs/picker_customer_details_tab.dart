import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/ui/cs_tool_tip_board.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/ui/sheet_button.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/custom_text_form_field.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/order_response.dart';
import 'package:toastification/toastification.dart';

class PickerCustomerDetailsTab extends StatefulWidget {
  Order? orderResponseItem;

  PickerCustomerDetailsTab({super.key, required this.orderResponseItem});

  @override
  State<PickerCustomerDetailsTab> createState() =>
      _PickerCustomerDetailsTabState();
}

class _PickerCustomerDetailsTabState extends State<PickerCustomerDetailsTab> {
  bool isRecording = false;
  late GlobalKey<FormState> idFormKey = GlobalKey<FormState>();
  TextEditingController commentcontroller = TextEditingController();

  CallLogs c1 = CallLogs();

  bool sendcancelreq = false;

  bool enableholdrequest = false;

  bool enablecancelrequest = false;

  Future<void> handleCall() async {
    // await startRecording(); // Start recording
    try {
      c1.call(widget.orderResponseItem!.telephone, () async {});
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 5.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: HexColor('#F0F0F0')),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Customer Name",
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyL_Regular,
                        color: FontColor.FontSecondary,
                      ),
                    ),
                    Text(
                      "${widget.orderResponseItem!.customerFirstname} ${widget.orderResponseItem!.customerLastname}",
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyL_SemiBold,
                        color: FontColor.FontPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 5.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(color: HexColor('#F0F0F0')),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Customer Phone",
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyL_Regular,
                        color: FontColor.FontSecondary,
                      ),
                    ),
                    Text(
                      "+974 ${widget.orderResponseItem!.telephone}",
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyL_Bold,
                        color: FontColor.FontPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 5.0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(color: HexColor('#F0F0F0')),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total amount",
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyL_Regular,
                      color: FontColor.FontSecondary,
                    ),
                  ),
                  Text(
                    "QAR ${double.parse(widget.orderResponseItem!.grandTotal == "" ? "0" : widget.orderResponseItem!.grandTotal).toStringAsFixed(2)}",
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyL_Bold,
                      color: FontColor.FontPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 14.0,
                ),
                decoration: BoxDecoration(
                  color: HexColor('#F4F9F9'),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Payment Method",
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyL_Regular,
                        color: FontColor.FontSecondary,
                      ),
                    ),
                    Text(
                      widget.orderResponseItem!.paymentMethod,
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyL_Bold,
                        color: FontColor.FontPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (enablecancelrequest)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0, top: 5.0),
                    child: Row(
                      children: [
                        Text(
                          "Reason of cancelation:",
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyL_Bold,
                            color: FontColor.FontPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (UserController().cancelreason == "Other Reasons")
                    CustomTextFormField(
                      context: context,
                      maxLines: 3,
                      bordercolor: customColors().fontSecondary,
                      enablesuggesion: true,
                      controller: commentcontroller,
                      fieldName: "Please fill the reason",
                      hintText: "Enter Reason..",

                      validator: Validator.defaultValidator,
                      onChange: (p0) {
                        UserController().cancelreason = p0;
                      },
                      onFieldSubmit: (p0) {
                        if (idFormKey.currentState != null) {
                          if (!idFormKey.currentState!.validate())
                            return "Please fill the reason";
                        }
                      },
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        border:
                            UserController().cancelreason ==
                                    "Please Select Reason"
                                ? Border.all(color: customColors().danger)
                                : Border.all(color: HexColor('#F0F0F0')),
                      ),
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          // value: true,
                          items:
                              items.map((item) {
                                return DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (mounted) {
                              setState(() {
                                UserController().cancelreason = value!;
                              });
                            }
                            // changereasons!(value);
                          },
                          hint: Text(
                            UserController().cancelreason,
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
                ],
              )
            else if (enableholdrequest)
              CustomTextFormField(
                context: context,
                maxLines: 3,
                bordercolor: customColors().fontSecondary,
                controller: commentcontroller,
                fieldName: "Please fill the reason",
                hintText: "Enter Reason..",
                enablesuggesion: true,
                validator: Validator.defaultValidator,
                onChange: (p0) {
                  UserController().cancelreason = p0;
                },
                onFieldSubmit: (p0) {
                  if (idFormKey.currentState != null) {
                    if (!idFormKey.currentState!.validate())
                      return "Please fill the reason";
                  }
                },
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: HexColor('#F4F9F9'),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 14.0,
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Comments",
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyL_Regular,
                                color: FontColor.FontSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 8.0,
                          right: 8.0,
                          bottom: 8.0,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 24.0,
                          ),
                          decoration: BoxDecoration(
                            color: customColors().backgroundPrimary,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  FutureBuilder(
                                    future: getTranslateWord(
                                      widget.orderResponseItem!.deliveryNote,
                                    ),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Expanded(
                                          child: Text(
                                            snapshot.data!,
                                            textAlign: TextAlign.start,
                                            style: customTextStyle(
                                              fontStyle: FontStyle.Inter_Medium,
                                              color: FontColor.FontPrimary,
                                            ),
                                          ),
                                        );
                                      } else {
                                        return Text("");
                                      }
                                    },
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
              ),
          ],
        ),

        if (enablecancelrequest)
          Row(
            children: [
              Expanded(
                child: BasketButton(
                  bgcolor: customColors().carnationRed,
                  textStyle: customTextStyle(
                    fontStyle: FontStyle.BodyL_Bold,
                    color: FontColor.White,
                  ),
                  text: "Send Cancel Request",
                  loading: sendcancelreq,
                  onpress: () async {
                    if (UserController().cancelreason !=
                            "Please Select Reason" &&
                        UserController().cancelreason != "Other Reasons") {
                      setState(() {
                        sendcancelreq = true;
                      });

                      showSnackBar(
                        context: context,
                        snackBar: showSuccessDialogue(
                          message: "status updating....!",
                        ),
                      );

                      final resp = await context.gTradingApiGateway
                          .updateMainOrderStat(
                            orderid:
                                widget.orderResponseItem!.subgroupIdentifier,
                            orderstatus: "cancel_request",
                            comment:
                                "${UserController().profile.name.toString()} (${UserController().profile.empId}) is requested cancel the order for ${UserController().cancelreason.toString()}",
                            userid: UserController().profile.id,
                            latitude:
                                UserController.userController.locationlatitude,
                            longitude:
                                UserController.userController.locationlongitude,
                          );

                      try {
                        if (resp.statusCode == 200) {
                          toastification.show(
                            backgroundColor: customColors().secretGarden,
                            context: context,
                            autoCloseDuration: const Duration(seconds: 5),
                            title: TranslatedText(
                              text: "Requested For Cancel...!",
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyL_Bold,
                                color: FontColor.White,
                              ),
                            ),
                          );

                          UserController().cancelreason =
                              "Please Select Reason";

                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);

                          context.gNavigationService.openPickerWorkspacePage(
                            context,
                          );
                        } else {
                          setState(() {
                            sendcancelreq = false;
                          });

                          toastification.show(
                            backgroundColor: customColors().carnationRed,
                            context: context,
                            autoCloseDuration: const Duration(seconds: 5),
                            title: TranslatedText(
                              text: "Send Request Failed Please Try Again...!",
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyL_Bold,
                                color: FontColor.White,
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() {
                          sendcancelreq = false;
                        });

                        toastification.show(
                          backgroundColor: customColors().carnationRed,
                          context: context,
                          autoCloseDuration: const Duration(seconds: 5),
                          title: TranslatedText(
                            text: "Send Request Failed Please Try Again...!",
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyL_Bold,
                              color: FontColor.White,
                            ),
                          ),
                        );
                      }
                    } else {
                      toastification.show(
                        backgroundColor: customColors().carnationRed,
                        context: context,
                        autoCloseDuration: const Duration(seconds: 2),
                        title: TranslatedText(
                          text: "Please Update Reason...!",
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyL_Bold,
                            color: FontColor.White,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          )
        else if (enableholdrequest)
          Row(
            children: [
              Expanded(
                child: BasketButton(
                  bgcolor: customColors().mattPurple,
                  textStyle: customTextStyle(
                    fontStyle: FontStyle.BodyL_Bold,
                    color: FontColor.White,
                  ),
                  text: 'Send Hold Request',
                  loading: sendcancelreq,
                  onpress: () async {
                    if (UserController().cancelreason !=
                        "Please Select Reason") {
                      setState(() {
                        sendcancelreq = true;
                      });

                      showSnackBar(
                        context: context,
                        snackBar: showSuccessDialogue(
                          message: "status updating....!",
                        ),
                      );

                      final resp = await context.gTradingApiGateway
                          .updateMainOrderStat(
                            orderid:
                                widget.orderResponseItem!.subgroupIdentifier,
                            orderstatus: "holded",
                            comment:
                                "${UserController().profile.name.toString()} (${UserController().profile.empId}) was holded the order for ${UserController().cancelreason.toString()}",
                            userid: UserController().profile.id,
                            latitude:
                                UserController.userController.locationlatitude,
                            longitude:
                                UserController.userController.locationlongitude,
                          );

                      if (resp.statusCode == 200) {
                        toastification.show(
                          backgroundColor: customColors().secretGarden,
                          context: context,
                          autoCloseDuration: const Duration(seconds: 5),
                          title: TranslatedText(
                            text: "Order is On Hold",
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyL_Bold,
                              color: FontColor.White,
                            ),
                          ),
                        );

                        UserController().cancelreason = "Please Select Reason";

                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);

                        context.gNavigationService.openPickerWorkspacePage(
                          context,
                        );
                      } else {
                        setState(() {
                          sendcancelreq = false;
                        });

                        toastification.show(
                          backgroundColor: customColors().carnationRed,
                          context: context,
                          autoCloseDuration: const Duration(seconds: 5),
                          title: TranslatedText(
                            text: "Send Request Failed Please Try Again...!",
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyL_Bold,
                              color: FontColor.White,
                            ),
                          ),
                        );
                      }
                    } else {
                      // showSnackBar(
                      //     context: context,
                      //     snackBar: showErrorDialogue(
                      //         errorMessage: "Please Fill The Reason..."));
                      toastification.show(
                        backgroundColor: customColors().carnationRed,
                        context:
                            context, // optional if you use ToastificationWrapper
                        title: TranslatedText(
                          text: 'Please Update The Reason...!',
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyM_Bold,
                            color: FontColor.White,
                          ),
                        ),
                        autoCloseDuration: const Duration(seconds: 2),
                      );
                    }
                  },
                ),
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Stack(
                children: [
                  SheetButton(
                    imagepath: 'assets/contact_btn.png',
                    sheettext:
                        isRecording ? 'Recording...' : 'Contact \n Customer',
                    onTapbtn: () async {
                      // await handleCall();
                    },
                  ),
                  Positioned(
                    child: CsToolTipBoard(
                      phone_num: widget.orderResponseItem!.telephone,
                      onTap: () async {
                        await handleCall(); // Call and record
                        // await _makeCall('97450154119');
                      },
                      ordernum: widget.orderResponseItem!.subgroupIdentifier,
                    ),
                  ),
                ],
              ),
              SheetButton(
                imagepath: 'assets/cancel_req.png',
                sheettext: 'Cancel \n Request',
                onTapbtn: () {
                  setState(() {
                    enablecancelrequest = true;
                  });
                },
              ),
              SheetButton(
                imagepath: 'assets/hold_req.png',
                sheettext: 'Hold \n Order',
                onTapbtn: () {
                  setState(() {
                    enableholdrequest = true;
                  });
                },
              ),
            ],
          ),
      ],
    );
  }
}
