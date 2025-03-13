import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/status_history_response.dart';
import 'package:timeline_tile/timeline_tile.dart';

class CustomTimeline extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  StatusHistory statushistory;
  CustomTimeline({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.statushistory,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TimelineTile(
        isFirst: isFirst,
        isLast: isLast,
        indicatorStyle:
            isFirst
                ? IndicatorStyle(
                  width: 40.0,
                  height: 40.0,
                  color: customColors().green1,
                  indicator: Column(
                    children: [
                      Container(
                        height: 25.0,
                        width: 25.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: customColors().secretGarden,
                        ),
                        child: Center(child: Icon(Icons.check)),
                      ),
                      Icon(Icons.arrow_upward, size: 15),
                    ],
                  ),
                )
                : IndicatorStyle(
                  width: 40.0,
                  height: 40.0,
                  color: Colors.transparent,
                  indicator: Column(
                    children: [
                      Container(
                        height: 20.0,
                        width: 20.0,
                        decoration: BoxDecoration(
                          color: customColors().green4,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Icon(Icons.arrow_upward, size: 20),
                    ],
                  ),
                ),
        afterLineStyle: LineStyle(thickness: 1, color: customColors().crisps),
        beforeLineStyle: LineStyle(
          thickness: 1,
          color: customColors().dodgerBlue,
        ),
        endChild: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: ListTile(
            title: Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 12.0),
              child: getStatusType(statushistory.status),
            ),
            subtitle: Text(
              statushistory.comment,
              style: customTextStyle(fontStyle: FontStyle.BodyM_Bold),
            ),
          ),
        ),
      ),
    );
  }
}

getStatusType(String status) {
  switch (status) {
    case "start_picking":
      return Container(
        decoration: BoxDecoration(color: customColors().dodgerBlue),
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        child: Text("Start Picking", style: TextStyle(color: Colors.white)),
      );
    case "end_picking":
      return Container(
        decoration: BoxDecoration(color: customColors().islandAqua),
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        child: Text("End Picking", style: TextStyle(color: Colors.white)),
      );
    case "assigned_picker":
      return Container(
        decoration: BoxDecoration(color: customColors().green3),
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        child: Text("Assigned Picker", style: TextStyle(color: Colors.white)),
      );
    case "holded":
      return Container(
        decoration: BoxDecoration(color: HexColor('#be3ecf')),
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        child: Text("On Hold", style: TextStyle(color: Colors.white)),
      );
    case "complete":
      return Container(
        decoration: BoxDecoration(color: HexColor('#79b004')),
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        child: Text("Delivered", style: TextStyle(color: Colors.white)),
      );
    case "on_the_way":
      return Container(
        decoration: BoxDecoration(color: HexColor('#00674c')),
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        child: Text("On The Way", style: TextStyle(color: Colors.white)),
      );
    case "assigned_driver":
      return Container(
        decoration: BoxDecoration(color: HexColor('#08925f')),
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        child: Text("Assigned Driver", style: TextStyle(color: Colors.white)),
      );
    case "cancel_request":
      return Container(
        decoration: BoxDecoration(color: HexColor('#a42525')),
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        child: Text("Cancel Request", style: TextStyle(color: Colors.white)),
      );
    case "canceled":
      return Text("Canceled");
    case "canceled_by_team":
      return Container(
        decoration: BoxDecoration(color: HexColor('#a42525')),
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        child: Text("Cancel By Team", style: TextStyle(color: Colors.white)),
      );
    case "material_request":
      return Container(
        decoration: BoxDecoration(color: customColors().mattPurple),
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        child: Text("Material Request", style: TextStyle(color: Colors.white)),
      );
    default:
  }
}
