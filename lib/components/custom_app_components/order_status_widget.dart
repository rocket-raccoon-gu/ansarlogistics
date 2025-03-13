import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OrderStatusWidget extends StatelessWidget {
  String status;

  OrderStatusWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22.0,
      decoration: BoxDecoration(
        // color: getOrderWidgetColor(status),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(4.0),
          bottomLeft: Radius.circular(4.0),
        ),
      ),
      child: Center(
        child: Text(
          getTranslate(context, getStatus(status)),
          style: customTextStyle(
            fontStyle: FontStyle.BodyM_SemiBold,
            color: FontColor.White,
          ),
        ),
      ),
    );
  }
}
