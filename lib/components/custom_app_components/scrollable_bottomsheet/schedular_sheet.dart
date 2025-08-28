import 'dart:convert';
import 'dart:developer';

import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/custom_text_form_field.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class OrderSchedulerDateRange extends StatefulWidget {
  String orderid;
  final Function() reschedulesuccess;
  OrderSchedulerDateRange({
    super.key,
    required this.orderid,
    required this.reschedulesuccess,
  });

  @override
  State<OrderSchedulerDateRange> createState() =>
      _OrderSchedulerDateRangeState();
}

class _OrderSchedulerDateRangeState extends State<OrderSchedulerDateRange> {
  String fromdate = "";
  String todate = "";

  int selectedindex = -1;

  DateTime? dt;

  bool candeliver = false;
  TextEditingController commentcontroller = TextEditingController();

  DateRangePickerController? controller11 = DateRangePickerController();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order Reschedule",
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyL_Bold,
                      color: FontColor.FontPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      setState(() {
                        fromdate = "";
                        todate = "";
                        candeliver = false;
                        commentcontroller.clear();
                        // controller11!.selectedRange = null;
                        // controller11!.notifyPropertyChangedListeners("");
                        // context.gNavigationService.back(context);
                      });
                    },
                    child: Text(
                      "Reset",
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyL_Bold,
                        color: FontColor.CarnationRed,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Text(
                      "Order id : ",
                      style: customTextStyle(fontStyle: FontStyle.BodyM_Bold),
                    ),
                    Text(
                      "#${widget.orderid}",
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyM_Bold,
                        color: FontColor.SecretGarden,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: customColors().grey, thickness: 1.5),
              ExpandableNotifier(
                child: ScrollOnExpand(
                  child: Builder(
                    builder: (context) {
                      var controller = ExpandableController.of(
                        context,
                        required: true,
                      );
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: customColors().backgroundTertiary,
                                  ),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        controller!.toggle();
                                        // if (controller.expanded) {
                                        //   setState(() {
                                        //     candeliver = false;
                                        //   });
                                        // }
                                        log("okok");
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color:
                                                customColors()
                                                    .backgroundTertiary,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                          vertical: 8.0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Text(
                                                    fromdate == ""
                                                        ? "FromDate"
                                                        : fromdate,
                                                  ),
                                                  Text(
                                                    " - ",
                                                    style: customTextStyle(
                                                      fontStyle:
                                                          FontStyle.BodyL_Bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    todate == ""
                                                        ? "ToDate"
                                                        : todate,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(Icons.calendar_month),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expandable(
                                      collapsed: Container(),
                                      expanded: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: SfDateRangePicker(
                                                  controller: controller11,
                                                  selectionMode:
                                                      DateRangePickerSelectionMode
                                                          .range,
                                                  onSelectionChanged: (
                                                    dateRangePickerSelectionChangedArgs,
                                                  ) {
                                                    if (dateRangePickerSelectionChangedArgs
                                                            .value !=
                                                        null) {
                                                      PickerDateRange
                                                      pickerDateRange =
                                                          dateRangePickerSelectionChangedArgs
                                                              .value;

                                                      setState(() {
                                                        if (pickerDateRange
                                                                .startDate !=
                                                            null) {
                                                          setState(() {
                                                            dt =
                                                                pickerDateRange
                                                                    .startDate;
                                                          });

                                                          fromdate =
                                                              getFormatedDateForReport(
                                                                pickerDateRange
                                                                    .startDate
                                                                    .toString(),
                                                              );
                                                        }

                                                        if (pickerDateRange
                                                                .endDate !=
                                                            null) {
                                                          todate =
                                                              getFormatedDateForReport(
                                                                pickerDateRange
                                                                    .endDate
                                                                    .toString(),
                                                              );
                                                        }
                                                      });
                                                    }
                                                  },
                                                  monthCellStyle:
                                                      DateRangePickerMonthCellStyle(
                                                        textStyle: customTextStyle(
                                                          fontStyle:
                                                              FontStyle
                                                                  .BodyM_Bold,
                                                          color:
                                                              FontColor
                                                                  .FontPrimary,
                                                        ),
                                                        todayTextStyle:
                                                            customTextStyle(
                                                              fontStyle:
                                                                  FontStyle
                                                                      .BodyL_Bold,
                                                              color:
                                                                  FontColor
                                                                      .FontPrimary,
                                                            ),
                                                      ),
                                                  rangeSelectionColor: HexColor(
                                                    '#b9d737',
                                                  ),
                                                  startRangeSelectionColor:
                                                      customColors()
                                                          .pacificBlue,
                                                  endRangeSelectionColor:
                                                      customColors()
                                                          .pacificBlue,
                                                  rangeTextStyle:
                                                      customTextStyle(
                                                        fontStyle:
                                                            FontStyle
                                                                .BodyM_Bold,
                                                        color:
                                                            FontColor
                                                                .FontPrimary,
                                                      ),
                                                  enablePastDates: false,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: fromdate != "",
                                      child: MediaQuery.removePadding(
                                        context: context,
                                        removeTop: true,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                          ),
                                          child: GridView.builder(
                                            itemCount: timerangelist.length,
                                            shrinkWrap: true,
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 4,
                                                  mainAxisSpacing: 0,
                                                  childAspectRatio: 2.0,
                                                ),
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 5.0,
                                                      vertical: 5.0,
                                                    ),
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      selectedindex = index;
                                                    });
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 1.2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          selectedindex == index
                                                              ? customColors()
                                                                  .accent
                                                              : customColors()
                                                                  .backgroundPrimary,
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
                                                    child: Center(
                                                      child: Text(
                                                        timerangelist[index],
                                                        style: customTextStyle(
                                                          fontStyle:
                                                              FontStyle
                                                                  .BodyS_Bold,
                                                          color:
                                                              FontColor
                                                                  .FontPrimary,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    fromdate != "" && todate != ""
                                        ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 4.0,
                                              ),
                                              child: Text(
                                                "I Can Deliver This Order",
                                                style: customTextStyle(
                                                  fontStyle:
                                                      FontStyle.BodyM_Bold,
                                                  color: FontColor.CarnationRed,
                                                ),
                                              ),
                                            ),
                                            Checkbox(
                                              activeColor: HexColor('#b9d737'),
                                              value: candeliver,
                                              onChanged: (v) {
                                                setState(() {
                                                  candeliver = v!;

                                                  if (candeliver) {
                                                    controller!.toggle();
                                                  }
                                                });
                                              },
                                            ),
                                          ],
                                        )
                                        : SizedBox(),
                                    // !controller!.expanded && candeliver
                                    //     ? Padding(
                                    //         padding: const EdgeInsets.symmetric(
                                    //             vertical: 8.0, horizontal: 4.0),
                                    //         child: CustomTextFormField(
                                    //           context: context,
                                    //           maxLines: 3,
                                    //           bordercolor:
                                    //               customColors().fontSecondary,
                                    //           controller: commentcontroller,
                                    //           fieldName: "Please fill the reason",
                                    //           hintText: "Enter Reason..",
                                    //           onFieldSubmit: (p0) {
                                    //             FocusScope.of(context).unfocus();
                                    //           },
                                    //         ),
                                    //       )
                                    //     : SizedBox(),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: InkWell(
                                        onTap: () async {
                                          if (fromdate == "" && todate == "") {
                                            showGeneralDialog(
                                              context: context,
                                              pageBuilder: (
                                                context,
                                                animation,
                                                secondaryanimation,
                                              ) {
                                                return Container();
                                              },
                                              transitionBuilder: (
                                                context,
                                                animation,
                                                secondaryAnimation,
                                                child,
                                              ) {
                                                var curve = Curves.easeInOut
                                                    .transform(animation.value);

                                                return Transform.scale(
                                                  scale: curve,
                                                  child: AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8.0,
                                                          ),
                                                    ),
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          "Please Select Date..!",
                                                          style: customTextStyle(
                                                            fontStyle:
                                                                FontStyle
                                                                    .BodyL_Bold,
                                                            color:
                                                                FontColor
                                                                    .FontPrimary,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                top: 16.0,
                                                              ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              InkWell(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                    context,
                                                                  );
                                                                },
                                                                child: Container(
                                                                  padding: const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        20.0,
                                                                    vertical:
                                                                        10.0,
                                                                  ),
                                                                  decoration: BoxDecoration(
                                                                    color:
                                                                        customColors()
                                                                            .carnationRed,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          5.0,
                                                                        ),
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(
                                                                      "OK",
                                                                      style: customTextStyle(
                                                                        fontStyle:
                                                                            FontStyle.BodyM_Bold,
                                                                        color:
                                                                            FontColor.White,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          } else {
                                            // if (commentcontroller.text.isEmpty) {
                                            //   showGeneralDialog(
                                            //     context: context,
                                            //     pageBuilder: (context, animation,
                                            //         secondaryanimation) {
                                            //       return Container();
                                            //     },
                                            //     transitionBuilder: (context,
                                            //         animation,
                                            //         secondaryAnimation,
                                            //         child) {
                                            //       var curve = Curves.easeInOut
                                            //           .transform(animation.value);

                                            //       return Transform.scale(
                                            //         scale: curve,
                                            //         child: AlertDialog(
                                            //           shape: RoundedRectangleBorder(
                                            //             borderRadius:
                                            //                 BorderRadius.circular(
                                            //                     8.0),
                                            //           ),
                                            //           content: Column(
                                            //             mainAxisSize:
                                            //                 MainAxisSize.min,
                                            //             mainAxisAlignment:
                                            //                 MainAxisAlignment
                                            //                     .center,
                                            //             children: [
                                            //               Text(
                                            //                 "Please Fill the Reason..!",
                                            //                 style: customTextStyle(
                                            //                     fontStyle: FontStyle
                                            //                         .BodyL_Bold,
                                            //                     color: FontColor
                                            //                         .FontPrimary),
                                            //               ),
                                            //               Padding(
                                            //                 padding:
                                            //                     const EdgeInsets
                                            //                         .only(
                                            //                         top: 15.0),
                                            //                 child: Row(
                                            //                   mainAxisAlignment:
                                            //                       MainAxisAlignment
                                            //                           .center,
                                            //                   children: [
                                            //                     InkWell(
                                            //                       onTap: () {
                                            //                         context
                                            //                             .gNavigationService
                                            //                             .back(
                                            //                                 context);
                                            //                       },
                                            //                       child: Container(
                                            //                         padding: const EdgeInsets
                                            //                             .symmetric(
                                            //                             horizontal:
                                            //                                 25.0,
                                            //                             vertical:
                                            //                                 10.0),
                                            //                         decoration: BoxDecoration(
                                            //                             color: customColors()
                                            //                                 .carnationRed,
                                            //                             borderRadius:
                                            //                                 BorderRadius.circular(
                                            //                                     5.0)),
                                            //                         child: Center(
                                            //                           child: Text(
                                            //                             "OK",
                                            //                             style: customTextStyle(
                                            //                                 fontStyle:
                                            //                                     FontStyle
                                            //                                         .BodyM_Bold,
                                            //                                 color: FontColor
                                            //                                     .White),
                                            //                           ),
                                            //                         ),
                                            //                       ),
                                            //                     )
                                            //                   ],
                                            //                 ),
                                            //               )
                                            //             ],
                                            //           ),
                                            //         ),
                                            //       );
                                            //     },
                                            //   );
                                            // } else if (commentcontroller
                                            //     .text.isNotEmpty) {
                                            //
                                            //
                                            // with comment section

                                            //   final response = await context
                                            //       .gTradingApiGateway
                                            //       .sendRescheduleRequest(
                                            //     orderid: widget.orderid,
                                            //     deliverydate:
                                            //         getdateformattedrescheduled(
                                            //             dt!),
                                            //     timerange:
                                            //         timerangelist[selectedindex],
                                            //     userid: int.parse(UserController
                                            //         .userController.profile.id),
                                            //     candeliver: true,
                                            //   );

                                            //   Map<String, dynamic> resposebody =
                                            //       jsonDecode(response);

                                            //   if (resposebody['success'] == 1) {
                                            //     Navigator.pop(context);
                                            //     widget.reschedulesuccess();
                                            //   } else {
                                            //     // ignore: use_build_context_synchronously
                                            //     showGeneralDialog(
                                            //         context: context,
                                            //         pageBuilder: (context,
                                            //             animation,
                                            //             secondaryanimation) {
                                            //           return Container();
                                            //         });
                                            //   }
                                            // } else {
                                            //
                                            //
                                            // without comment section

                                            final response = await context
                                                .gTradingApiGateway
                                                .sendRescheduleRequest(
                                                  orderid: widget.orderid,
                                                  deliverydate:
                                                      getdateformattedrescheduled(
                                                        dt!,
                                                      ),
                                                  timerange:
                                                      timerangelist[selectedindex],
                                                  userid:
                                                      UserController
                                                          .userController
                                                          .profile
                                                          .id,
                                                  candeliver: true,
                                                );

                                            Map<String, dynamic> resposebody =
                                                jsonDecode(response);

                                            if (resposebody['success'] == 1) {
                                              Navigator.pop(context);
                                              widget.reschedulesuccess();
                                            } else {
                                              // ignore: use_build_context_synchronously
                                              showGeneralDialog(
                                                context: context,
                                                pageBuilder: (
                                                  context,
                                                  animation,
                                                  secondaryanimation,
                                                ) {
                                                  return Container();
                                                },
                                              );
                                            }
                                          }
                                          // }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 15.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: HexColor('#b9d737'),
                                            borderRadius: BorderRadius.circular(
                                              5.0,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Update Delivery Date",
                                              style: customTextStyle(
                                                fontStyle: FontStyle.BodyL_Bold,
                                                color: FontColor.FontPrimary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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

class OrderSchedulerNol extends StatefulWidget {
  String mainorderid;
  final Function() reschedulesuccess;
  OrderSchedulerNol({
    super.key,
    required this.mainorderid,
    required this.reschedulesuccess,
  });

  @override
  State<OrderSchedulerNol> createState() => _OrderSchedulerNolState();
}

class _OrderSchedulerNolState extends State<OrderSchedulerNol> {
  DateTime? d1;

  bool candeliver = false;

  TextEditingController commentcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order Reschedule",
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyL_Bold,
                      color: FontColor.FontPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        d1 = null;
                        candeliver = false;
                      });
                    },
                    child: Text(
                      "Reset",
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyL_Bold,
                        color: FontColor.CarnationRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Order Id : ",
                    style: customTextStyle(fontStyle: FontStyle.BodyM_Bold),
                  ),
                  Text(
                    "#${widget.mainorderid}",
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyM_Bold,
                      color: FontColor.SecretGarden,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Divider(color: customColors().fontPrimary),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Delivery Date",
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyM_Bold,
                          color: FontColor.FontPrimary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: InkWell(
                          onTap: () async {
                            d1 = await showRoundedDatePicker(
                              height: 310,
                              firstDate: DateTime.now().subtract(
                                Duration(days: 1),
                              ),
                              context: context,
                              theme: ThemeData.dark(),
                            );

                            setState(() {});
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: customColors().fontPrimary,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    d1 == null
                                        ? "yyyy-mm-dd"
                                        : getdateformattedrescheduled(d1!),
                                    style: customTextStyle(
                                      fontStyle: FontStyle.BodyL_Bold,
                                      color: FontColor.FontTertiary,
                                    ),
                                  ),
                                  Icon(Icons.calendar_month),
                                ],
                              ),
                            ),
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
        d1 != null
            ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "I can deliver this order",
                    style: customTextStyle(
                      fontStyle: FontStyle.BodyM_Bold,
                      color: FontColor.CarnationRed,
                    ),
                  ),
                ),
                Checkbox(
                  activeColor: HexColor('#b9d737'),
                  value: candeliver,
                  onChanged: (v) {
                    setState(() {
                      candeliver = v!;
                    });
                  },
                ),
              ],
            )
            : SizedBox(),
        candeliver
            ? Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 10.0,
              ),
              child: CustomTextFormField(
                context: context,
                maxLines: 3,
                bordercolor: customColors().fontSecondary,
                controller: commentcontroller,
                fieldName: "Please fill the reason",
                hintText: "Enter Reason...",
              ),
            )
            : SizedBox(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
          child: InkWell(
            onTap: () async {
              if (d1 == null) {
                showGeneralDialog(
                  context: context,
                  pageBuilder: (context, animation, secondaryanimation) {
                    return Container();
                  },
                  transitionBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    var curve = Curves.easeInOut.transform(animation.value);

                    return Transform.scale(
                      scale: curve,
                      child: AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Please Select Date...!",
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyL_Bold,
                                color: FontColor.FontPrimary,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 25.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 26.0,
                                        vertical: 10.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: customColors().carnationRed,
                                        borderRadius: BorderRadius.circular(
                                          5.0,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "OK",
                                          style: customTextStyle(
                                            fontStyle: FontStyle.BodyL_Bold,
                                            color: FontColor.White,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                if (candeliver && commentcontroller.text.isEmpty) {
                  showGeneralDialog(
                    context: context,
                    pageBuilder: (context, animation, secondaryanimation) {
                      return Container();
                    },
                    transitionBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      var curve = Curves.easeInExpo.transform(animation.value);

                      return Transform.scale(
                        scale: curve,
                        child: AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Please fill the reason....!",
                                style: customTextStyle(
                                  fontStyle: FontStyle.BodyL_Bold,
                                  color: FontColor.FontPrimary,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 14.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        context.gNavigationService.back(
                                          context,
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 25.0,
                                          vertical: 10.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: customColors().carnationRed,
                                          borderRadius: BorderRadius.circular(
                                            5.0,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "OK",
                                            style: customTextStyle(
                                              fontStyle: FontStyle.BodyM_Bold,
                                              color: FontColor.White,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (candeliver && commentcontroller.text.isNotEmpty) {
                  //
                  //
                  //

                  final response = await context.gTradingApiGateway
                      .sendRescheduleRequestNOL(
                        orderid: widget.mainorderid,
                        deliverydate: getdateformattedrescheduled(d1!),
                        userid: UserController.userController.profile.id,

                        candeliver: candeliver,
                        comment: commentcontroller.text,
                      );

                  Map<String, dynamic> responsebody = jsonDecode(response);

                  if (responsebody["success"] == 1) {
                    Navigator.pop(context);
                    widget.reschedulesuccess();
                  } else {
                    // ignore: use_build_context_synchronously
                    showGeneralDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: "",
                      pageBuilder: (context, animation, secondaryanimation) {
                        return Container();
                      },
                      transitionBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
                        var curve = Curves.easeInOut.transform(animation.value);

                        return Transform.scale(
                          scale: curve,
                          child: AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Somthing Went Wrong Please Check Again..!",
                                  textAlign: TextAlign.center,
                                  style: customTextStyle(
                                    fontStyle: FontStyle.BodyL_Bold,
                                    color: FontColor.CarnationRed,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: customColors().carnationRed,
                                        borderRadius: BorderRadius.circular(
                                          5.0,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "OK",
                                          style: customTextStyle(
                                            fontStyle: FontStyle.BodyL_Bold,
                                            color: FontColor.White,
                                          ),
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

                  //
                  // can deliver option
                  //
                } else {
                  //
                  //
                  // not can deliver option
                  //
                  final response = await context.gTradingApiGateway
                      .sendRescheduleRequestNOL(
                        orderid: widget.mainorderid,
                        deliverydate: getdateformattedrescheduled(d1!),
                        userid: UserController.userController.profile.id,
                        candeliver: candeliver,
                        comment: commentcontroller.text,
                      );

                  Map<String, dynamic> responsebody = jsonDecode(response);

                  if (responsebody["success"] == 1) {
                    Navigator.pop(context);
                    widget.reschedulesuccess();
                  } else {
                    // ignore: use_build_context_synchronously
                    showGeneralDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: "",
                      pageBuilder: (context, animation, secondaryanimation) {
                        return Container();
                      },
                      transitionBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
                        var curve = Curves.easeInOut.transform(animation.value);

                        return Transform.scale(
                          scale: curve,
                          child: AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Somthing Went Wrong Please Check Again..!",
                                  textAlign: TextAlign.center,
                                  style: customTextStyle(
                                    fontStyle: FontStyle.BodyL_Bold,
                                    color: FontColor.CarnationRed,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: customColors().carnationRed,
                                        borderRadius: BorderRadius.circular(
                                          5.0,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "OK",
                                          style: customTextStyle(
                                            fontStyle: FontStyle.BodyL_Bold,
                                            color: FontColor.White,
                                          ),
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
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              decoration: BoxDecoration(
                color: customColors().green600,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Center(
                child: Text(
                  "Reschedule",
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyL_Bold,
                    color: FontColor.White,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
