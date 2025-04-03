import 'dart:developer';

import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';
import 'package:slider_button/slider_button.dart';

class SwipeableWidget extends StatefulWidget {
  String text;
  Function()? onSwipeFinish;
  SwipeableWidget({super.key, required this.text, required this.onSwipeFinish});

  @override
  State<SwipeableWidget> createState() => _SwipeableWidgetState();
}

class _SwipeableWidgetState extends State<SwipeableWidget>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return SliderButton(
      action: () async {
        log("okok");
        widget.onSwipeFinish!();
      },
      label: TranslatedText(
        text: widget.text,
        style: customTextStyle(
          fontStyle: FontStyle.BodyL_Bold,
          color: FontColor.FontPrimary,
        ),
      ),
      icon: Center(
        child: Icon(
          Icons.arrow_forward,
          color: customColors().backgroundPrimary,
        ),
      ),
      width: 230,
      height: 55.0,
      radius: 10,
      buttonSize: 40.0,
      buttonColor: customColors().fontPrimary,
      // backgroundColor: customColors().backgroundPrimary,
      // highlightedColor: Colors.white,
      backgroundColor: customColors().green4,
      baseColor: customColors().fontPrimary,
    );
  }
}
