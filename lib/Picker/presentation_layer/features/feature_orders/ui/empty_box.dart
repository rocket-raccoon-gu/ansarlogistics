import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';

class EmptyBox extends StatelessWidget {
  const EmptyBox({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Center(
        child: TranslatedText(
          text: "No Orders Found..!",
          style: customTextStyle(fontStyle: FontStyle.HeaderXS_SemiBold),
        ),
      ),
    );
  }
}
