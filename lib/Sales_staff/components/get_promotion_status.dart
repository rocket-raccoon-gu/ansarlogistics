import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class GetPromotionStatus extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final promotionStatus;
  GetPromotionStatus({super.key, this.promotionStatus});

  @override
  Widget build(BuildContext context) {
    // Check if the promotion status is a number
    final parsedNumber = num.tryParse(promotionStatus);

    if (parsedNumber != null) {
      // If it's a number, format it accordingly
      return AnimatedTextKit(
        animatedTexts: [
          ColorizeAnimatedText(
            "$promotionStatus% OFF",
            colors: colorizeColors,
            textStyle: colorizeTextStyle,
          ),
        ],
      );
    } else {
      // If it's not a number, append "OFF" to the status
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Status : ",
            style: customTextStyle(fontStyle: FontStyle.BodyL_Bold),
          ),
          AnimatedTextKit(
            animatedTexts: [
              ColorizeAnimatedText(
                "$promotionStatus",
                textStyle: colorizeTextStyle,
                colors: colorizeColors,
              ),
            ],
          ),
        ],
      );
    }
  }
}

const colorizeColors = [Colors.purple, Colors.blue, Colors.yellow, Colors.red];

const colorizeTextStyle = TextStyle(fontSize: 20.0, fontFamily: 'Horizon');
