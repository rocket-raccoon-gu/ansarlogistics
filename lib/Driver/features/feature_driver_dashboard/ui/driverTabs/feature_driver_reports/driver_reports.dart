import 'dart:math';

import 'package:ansarlogistics/Driver/features/feature_driver_dashboard/ui/driverTabs/feature_driver_reports/bloc/driver_reports_cubit.dart';
import 'package:ansarlogistics/Driver/features/feature_driver_dashboard/ui/driverTabs/feature_driver_reports/bloc/driver_reports_state.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_reports/ui/count_container_widget.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/animation_switch.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:intl/intl.dart';

class DriverReportsPage extends StatefulWidget {
  const DriverReportsPage({super.key});

  @override
  State<DriverReportsPage> createState() => _DriverReportsPageState();
}

class _DriverReportsPageState extends State<DriverReportsPage> {
  DateTime lastDayOfMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month + 1,
    0,
  );
  DateTime firstDayOfMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  String start = "";

  String end = "";

  @override
  Widget build(BuildContext context) {
    double mheight = MediaQuery.of(context).size.height * 1.222;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0.0),
        child: AppBar(elevation: 0, backgroundColor: HexColor('#F9FBFF')),
      ),
      backgroundColor: HexColor('#F9FBFF'),
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
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
                  color: customColors().backgroundTertiary.withOpacity(1.0),
                  spreadRadius: 3,
                  blurRadius: 5,
                  // offset: Offset(0, 3), // changes the position of the shadow
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(top: mheight * .012),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      width: double.maxFinite,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              bottom: 16.0,
                              top: 8.0,
                            ),
                            // child: Text(
                            //   "My Order Report ",
                            //   style: customTextStyle(
                            //     fontStyle: FontStyle.BodyL_Bold,
                            //     color: FontColor.FontPrimary,
                            //   ),
                            // ),
                            child: TranslatedText(
                              text: "My Order Report ",
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
          BlocConsumer<DriverReportCubit, DriverReportState>(
            builder: (context, state) {
              return Expanded(
                child: ExpandableNotifier(
                  child: ScrollOnExpand(
                    child: Builder(
                      builder: (context) {
                        var controller = ExpandableController.of(
                          context,
                          required: true,
                        );

                        return Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18.0,
                                        vertical: 8.0,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color:
                                                customColors()
                                                    .backgroundTertiary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            5.0,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                controller!.toggle();
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color:
                                                        customColors()
                                                            .backgroundTertiary,
                                                  ),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 8.0,
                                                    ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child:
                                                          context
                                                                      .read<
                                                                        DriverReportCubit
                                                                      >()
                                                                      .enddate ==
                                                                  ""
                                                              ? Text(
                                                                "${context.read<DriverReportCubit>().startdate}",
                                                              )
                                                              : Text(
                                                                "${context.read<DriverReportCubit>().startdate} - ${context.read<DriverReportCubit>().enddate}",
                                                              ),
                                                    ),
                                                    Icon(
                                                      Icons
                                                          .arrow_drop_down_sharp,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expandable(
                                              collapsed: Container(),
                                              expanded: Column(
                                                children: [
                                                  SizedBox(
                                                    height: 350.0,
                                                    width: 290,
                                                    child: ListView(
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      children: [
                                                        // DateTimeRange(start: start, end: end)
                                                        DateRangePickerWidget(
                                                          initialDisplayedDate:
                                                              DateTime.now(),
                                                          onDateRangeChanged: (
                                                            period,
                                                          ) {
                                                            setState(() {
                                                              if (period!.start
                                                                      .toString() !=
                                                                  "null") {
                                                                start =
                                                                    getFormatedDateForReport(
                                                                      period
                                                                          .start
                                                                          .toString(),
                                                                    ).toString();
                                                              }

                                                              if (period.end
                                                                      .toString() !=
                                                                  "null") {
                                                                end =
                                                                    getFormatedDateForReport(
                                                                      period.end
                                                                          .toString(),
                                                                    ).toString();
                                                              }
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 5.0,
                                                          vertical: 5.0,
                                                        ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            if (start == "" &&
                                                                end == "") {
                                                              // showSnackBar(
                                                              //     context:
                                                              //         context,
                                                              //     snackBar: showErrorDialogue1(
                                                              //         errorMessage:
                                                              //             "Date Field is Empty ..!"));
                                                            } else {
                                                              print("okok");
                                                              controller!
                                                                  .toggle();
                                                              context
                                                                  .read<
                                                                    DriverReportCubit
                                                                  >()
                                                                  .updatedata(
                                                                    start,
                                                                    end,
                                                                  );
                                                            }
                                                          },
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      15.0,
                                                                  vertical: 8.0,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  customColors()
                                                                      .accent,
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                "Apply",
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
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (state is DriverReportInitialState)
                                      if (state.statuslist.isEmpty)
                                        Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16.0,
                                                    vertical: 5.0,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Expanded(
                                                    child: CountContainer(
                                                      title: 'Order Assigned',
                                                      total: '0',
                                                    ),
                                                  ),
                                                  SizedBox(width: 5.0),
                                                  Expanded(
                                                    child: CountContainer(
                                                      title: 'Pending',
                                                      total: '0',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16.0,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: CountContainer(
                                                      title: "Delivered",
                                                      total: '0',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      else
                                        Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16.0,
                                                    vertical: 5.0,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Expanded(
                                                    child: CountContainer(
                                                      title: 'Order Assigned',
                                                      total:
                                                          state.statuslist
                                                              .where(
                                                                (element) =>
                                                                    element
                                                                        .status ==
                                                                    'assigned_driver',
                                                              )
                                                              .first
                                                              .orderCount
                                                              .toString(),
                                                    ),
                                                  ),
                                                  SizedBox(width: 5.0),
                                                  Expanded(
                                                    child: CountContainer(
                                                      title: 'Pending',
                                                      total:
                                                          state.statuslist
                                                              .where(
                                                                (element) =>
                                                                    element
                                                                        .status ==
                                                                    'on_the_way',
                                                              )
                                                              .first
                                                              .orderCount
                                                              .toString(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16.0,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: CountContainer(
                                                      title: "Delivered",
                                                      total:
                                                          state.statuslist
                                                              .where(
                                                                (element) =>
                                                                    element
                                                                        .status ==
                                                                    'complete',
                                                              )
                                                              .first
                                                              .orderCount
                                                              .toString(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                    else
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 150.0,
                                            ),
                                            child: Center(
                                              child: loadingindecator(),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
            listener: (context, state) {},
          ),
        ],
      ),
    );
  }
}
