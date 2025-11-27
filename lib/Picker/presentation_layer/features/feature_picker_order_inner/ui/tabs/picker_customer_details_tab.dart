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
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';
import 'package:toastification/toastification.dart';

class PickerCustomerDetailsTab extends StatefulWidget {
  OrderNew? orderResponseItem;
  String preparationId;
  String suborderId;
  PickerCustomerDetailsTab({
    super.key,
    required this.orderResponseItem,
    required this.preparationId,
    required this.suborderId,
  });

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
      c1.call(
        widget.orderResponseItem!.customer!.phone.toString(),
        () async {},
      );
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
                      "${widget.orderResponseItem!.customer!.firstName} ${widget.orderResponseItem!.customer!.lastName}",
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
                      "+974 ${widget.orderResponseItem!.customer!.phone}",
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
                    "QAR ${double.parse(widget.orderResponseItem!.orderAmount.toString() == "" ? "0" : widget.orderResponseItem!.orderAmount!.toString()).toStringAsFixed(2)}",
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
                      widget.orderResponseItem!.paymentMethod!,
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyL_Bold,
                        color: FontColor.FontPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (enableholdrequest || enablecancelrequest)
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 14.0,
                        ),
                        child: Text(
                          '${widget.orderResponseItem!.deliveryNote}',
                          textAlign: TextAlign.start,
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyL_Bold,
                            color: FontColor.CarnationRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),

        if (enableholdrequest)
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

                      final token = await PreferenceUtils.getDataFromShared(
                        'usertoken',
                      );

                      final resp = await context.gTradingApiGateway
                          .updateMainOrderStatNew(
                            preparationId: widget.preparationId,
                            orderStatus: "holded",
                            comment:
                                "${UserController().profile.name.toString()} (${UserController().profile.empId}) was holded the order for ${UserController().cancelreason.toString()}",
                            orderNumber: widget.suborderId,
                            token: token!,
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
                      showSnackBar(
                        context: context,
                        snackBar: showErrorDialogue(
                          errorMessage: "Please Fill The Reason...",
                        ),
                      );
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
        else if (enablecancelrequest)
          Row(
            children: [
              Expanded(
                child: BasketButton(
                  textStyle: customTextStyle(
                    fontStyle: FontStyle.BodyL_Bold,
                    color: FontColor.White,
                  ),
                  text: 'Cancel Request',
                  bgcolor: customColors().carnationRed,
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

                      final token = await PreferenceUtils.getDataFromShared(
                        'usertoken',
                      );

                      final resp = await context.gTradingApiGateway
                          .updateMainOrderStatNew(
                            preparationId: widget.preparationId,
                            orderStatus: "cancel_request",
                            comment:
                                "${UserController().profile.name.toString()} (${UserController().profile.empId}) was cancelled the order for ${UserController().cancelreason.toString()}",
                            orderNumber: widget.suborderId,
                            token: token!,
                          );

                      if (resp.statusCode == 200) {
                        toastification.show(
                          backgroundColor: customColors().secretGarden,
                          context: context,
                          autoCloseDuration: const Duration(seconds: 5),
                          title: TranslatedText(
                            text: "Order is Cancel Requested",
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
                        isRecording ? 'Recording...' : 'Contact \nCustomer',
                    onTapbtn: () async {
                      // await handleCall();
                    },
                  ),
                  Positioned(
                    child: CsToolTipBoard(
                      phone_num:
                          widget.orderResponseItem!.customer!.phone.toString(),
                      onTap: () async {
                        await handleCall(); // Call and record
                        // await _makeCall('97450154119');
                      },
                      ordernum: widget.orderResponseItem!.id.toString(),
                    ),
                  ),
                ],
              ),

              SheetButton(
                imagepath: 'assets/hold_req.png',
                sheettext: 'Hold \nOrder',
                onTapbtn: () {
                  setState(() {
                    enableholdrequest = true;
                  });
                },
              ),

              SheetButton(
                imagepath: 'assets/hold_req.png',
                sheettext: 'Cancel \nRequest',
                onTapbtn: () {
                  setState(() {
                    enablecancelrequest = true;
                  });
                },
              ),
            ],
          ),
      ],
    );
  }
}
