import 'dart:convert';

import 'package:ansarlogistics/Driver/features/feature_driver_dashboard/ui/driverTabs/feature_driver_reports/bloc/driver_reports_state.dart';
import 'package:ansarlogistics/Picker/presentation_layer/bloc_navigation/navigation_cubit.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picker_driver_api/responses/order_report_response.dart';
import 'package:toastification/toastification.dart';

class DriverReportCubit extends Cubit<DriverReportState> {
  // PDApiGateway pdApiGateway;

  BuildContext context;

  final ServiceLocator serviceLocator;

  String startdate = getFormatedDateForReport(DateTime.now().toString());
  String enddate = getFormatedDateForReport(DateTime.now().toString());

  DriverReportCubit({
    // required this.pdApiGateway,
    required this.context,
    required this.serviceLocator,
  }) : super(DriverReportLoadingState()) {
    BlocProvider.of<NavigationCubit>(context).adcontroller.stream.listen((
      event,
    ) {
      if (event.currIndex == 1) {
        if (!isClosed) {
          updatedata(startdate, enddate);
        }
      }
    });
  }

  List<StatusHistory> statuslist = [];

  updatedata(String startdate1, String enddate1) async {
    startdate = startdate1;

    enddate = enddate1;

    if (!isClosed) {
      emit(DriverReportLoadingState());
    }

    String? token = await PreferenceUtils.getDataFromShared("usertoken");

    try {
      final responce = await serviceLocator.tradingApi.OrderREportService(
        startDate: startdate1,
        endDate: enddate1,
        token: token,
      );
      if (responce.statusCode == 200) {
        Map<String, dynamic> jsonresponce = jsonDecode(responce.body);

        OrderReportsResponse orderReportsResponse =
            OrderReportsResponse.fromJson(jsonresponce);

        statuslist = orderReportsResponse.statusHistories;
      } else {
        // ignore: use_build_context_synchronously
        toastification.show(
          context: context,
          backgroundColor: customColors().carnationRed,
          title: TranslatedText(
            text: "Request Failed Please try Again...!",
            style: customTextStyle(
              fontStyle: FontStyle.BodyL_Bold,
              color: FontColor.White,
            ),
          ),
        );
      }
    } catch (e) {
      toastification.show(
        context: context,
        backgroundColor: customColors().carnationRed,
        title: TranslatedText(
          text: "Request Failed Please try Again...!",
          style: customTextStyle(
            fontStyle: FontStyle.BodyL_Bold,
            color: FontColor.White,
          ),
        ),
      );
    }

    if (!isClosed) {
      emit(DriverReportInitialState(statuslist));
    }
  }
}
