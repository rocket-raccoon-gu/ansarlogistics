import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class CountContainer extends StatelessWidget {
  final String title;
  final String total;
  final VoidCallback? onTap;

  const CountContainer({
    super.key,
    required this.title,
    required this.total,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 150.0,
          decoration: BoxDecoration(
            color: getstatColor(title),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TranslatedText(
                text: title,
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
              if (onTap != null)
                Text(
                  'Tap to view',
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyS_Regular,
                    color: FontColor.White,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
