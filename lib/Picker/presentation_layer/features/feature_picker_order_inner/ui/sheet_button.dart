import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';

class SheetButton extends StatelessWidget {
  String imagepath;
  String sheettext;
  void Function()? onTapbtn;
  SheetButton({
    super.key,
    required this.imagepath,
    required this.sheettext,
    this.onTapbtn,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTapbtn,
      child: Column(
        children: [
          Image.asset(imagepath),
          TranslatedText(
            text: sheettext,
            textAlign: TextAlign.center,
            style: customTextStyle(
              fontStyle: FontStyle.Inter_Light,
              color: FontColor.FontPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
