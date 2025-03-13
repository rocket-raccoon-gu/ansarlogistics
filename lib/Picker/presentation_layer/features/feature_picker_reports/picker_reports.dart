import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_reports/bloc/picker_report_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_reports/bloc/picker_report_state.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_reports/ui/count_container_widget.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/animation_switch.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';

class PickerReports extends StatefulWidget {
  const PickerReports({super.key});

  @override
  State<PickerReports> createState() => _PickerReportsState();
}

class _PickerReportsState extends State<PickerReports> {
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
                            child: Text(
                              "My Order Report ",
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
          BlocConsumer<PickerReportCubit, PickerReportState>(
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
                                                // showCustomDateRangePicker(
                                                //   context,
                                                //   dismissible: true,
                                                //   minimumDate: DateTime.now()
                                                //       .subtract(const Duration(
                                                //           days: 30)),
                                                //   maximumDate: DateTime.now()
                                                //       .add(const Duration(
                                                //           days: 30)),
                                                //   backgroundColor:
                                                //       customColors().red1,
                                                //   primaryColor:
                                                //       customColors().accent,
                                                //   startDate: format.parse(context
                                                //       .read<
                                                //           OrderReportPageCubit>()
                                                //       .startdate),
                                                //   endDate: format.parse(context
                                                //       .read<
                                                //           OrderReportPageCubit>()
                                                //       .enddate),
                                                //   onApplyClick: (start, end) {
                                                //     setState(() {
                                                //       // endDate = end;
                                                //       // startDate = start;
                                                //     });
                                                //   },
                                                //   onCancelClick: () {
                                                //     setState(() {
                                                //       // endDate = null;
                                                //       // startDate = null;
                                                //     });
                                                //   },
                                                // );
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
                                                                        PickerReportCubit
                                                                      >()
                                                                      .enddate ==
                                                                  ""
                                                              ? Text(
                                                                "${context.read<PickerReportCubit>().startdate}",
                                                              )
                                                              : Text(
                                                                "${context.read<PickerReportCubit>().startdate} - ${context.read<PickerReportCubit>().enddate}",
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
                                                                    PickerReportCubit
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
                                    if (state is PickerReportInitialState)
                                      // state checking
                                      if (state.statuslist.isEmpty)
                                        // statuslist empty check
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
                                        // statuslist not empty check
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
                                                                    'assigned_picker',
                                                              )
                                                              .first
                                                              .orderCount,
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
                                                                    'start_picking',
                                                              )
                                                              .first
                                                              .orderCount,
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
                                                      title: "End Picked",
                                                      total:
                                                          state.statuslist
                                                              .where(
                                                                (element) =>
                                                                    element
                                                                        .status ==
                                                                    'end_picking',
                                                              )
                                                              .first
                                                              .orderCount,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                    // state  checking end
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
