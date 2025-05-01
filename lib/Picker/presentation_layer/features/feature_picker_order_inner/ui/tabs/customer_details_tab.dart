import 'package:ansarlogistics/components/custom_app_components/textfields/custom_text_form_field.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/order_response.dart';

class CustomerDetailsTab extends StatefulWidget {
  Order? orderResponseItem;
  bool enablecancelrequest;
  bool enableholdrequest;
  bool enablecsnotaanswer;
  CustomerDetailsTab({
    super.key,
    required this.orderResponseItem,
    required this.enablecancelrequest,
    required this.enableholdrequest,
    required this.enablecsnotaanswer,
  });

  @override
  State<CustomerDetailsTab> createState() => _CustomerDetailsTabState();
}

class _CustomerDetailsTabState extends State<CustomerDetailsTab> {
  late GlobalKey<FormState> idFormKey = GlobalKey<FormState>();

  TextEditingController commentcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView(
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

              if (widget.enablecancelrequest)
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
              else if (widget.enableholdrequest)
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
                                                fontStyle:
                                                    FontStyle.Inter_Medium,
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
        ),
      ],
    );
  }
}
