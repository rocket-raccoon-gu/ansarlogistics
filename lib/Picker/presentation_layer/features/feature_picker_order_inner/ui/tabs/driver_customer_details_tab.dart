import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/ui/cs_tool_tip_board.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/ui/sheet_button.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/order_response.dart';
import 'package:toastification/toastification.dart';

class DriverCustomerDetailsTab extends StatefulWidget {
  Order? orderResponseItem;
  DriverCustomerDetailsTab({super.key, required this.orderResponseItem});

  @override
  State<DriverCustomerDetailsTab> createState() =>
      _DriverCustomerDetailsTabState();
}

class _DriverCustomerDetailsTabState extends State<DriverCustomerDetailsTab> {
  late GlobalKey<FormState> idFormKey = GlobalKey<FormState>();
  bool isRecording = false;
  TextEditingController commentcontroller = TextEditingController();

  CallLogs c1 = CallLogs();

  bool enablecsnotanswrrequest = false;

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
                    TranslatedText(
                      text: "Customer Name",
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyL_Regular,
                        color: FontColor.FontSecondary,
                      ),
                    ),
                    TranslatedText(
                      text:
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
                    TranslatedText(
                      text: "Customer Phone",
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyL_Regular,
                        color: FontColor.FontSecondary,
                      ),
                    ),
                    Text(
                      "${widget.orderResponseItem!.telephone}",
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
                  TranslatedText(
                    text: "Total amount",
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
                    TranslatedText(
                      text: "Payment Method",
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
          ],
        ),

        if (enablecsnotanswrrequest)
          Row(
            children: [
              Expanded(
                child: BasketButton(
                  bgcolor: customColors().carnationRed,
                  textStyle: customTextStyle(
                    fontStyle: FontStyle.BodyL_Bold,
                    color: FontColor.White,
                  ),
                  text: 'Customer Not Answering',
                  onpress: () async {
                    showSnackBar(
                      context: context,
                      snackBar: showSuccessDialogue(
                        message: "status updating....!",
                      ),
                    );

                    final resp = await context.gTradingApiGateway
                        .updateMainOrderStat(
                          orderid: widget.orderResponseItem!.subgroupIdentifier,
                          orderstatus: "customer_not_answer",
                          comment:
                              "${UserController().profile.name.toString()} (${UserController().profile.empId}) was marked the order customer not answer",
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
                        title: Text(
                          "Order is on Customer Not Answer",
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyL_Bold,
                            color: FontColor.White,
                          ),
                        ),
                      );

                      Navigator.of(context).popUntil((route) => route.isFirst);

                      context.gNavigationService.openDriverDashBoardPage(
                        context,
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
              if (widget.orderResponseItem!.status != "assigned_driver")
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
                )
              else
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
                  ],
                ),

              SheetButton(
                imagepath: 'assets/customer_ser.png',
                sheettext: 'Client not\n Answer',
                onTapbtn: () {
                  setState(() {
                    enablecsnotanswrrequest = true;
                  });
                },
              ),
            ],
          ),
      ],
    );
  }
}
