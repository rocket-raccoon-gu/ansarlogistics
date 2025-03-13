import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:picker_driver_api/responses/order_report_response.dart';

class CountContainer extends StatelessWidget {
  String title;
  String total;
  CountContainer({super.key, required this.title, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 150.0,
      decoration: BoxDecoration(
        color: getstatColor(title),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: customTextStyle(
              fontStyle: FontStyle.BodyL_Bold,
              color: FontColor.White,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Center(
              child: Text(
                total,
                style: customTextStyle(
                  fontStyle: FontStyle.BodyL_Bold,
                  color: FontColor.White,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
