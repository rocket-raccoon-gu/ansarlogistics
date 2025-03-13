import 'package:ansarlogistics/components/restart_widget.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:flutter/material.dart';

class LanguageButton extends StatefulWidget {
  int indexval;
  LanguageButton({super.key, required this.indexval});

  @override
  State<LanguageButton> createState() => _LanguageButtonState();
}

class _LanguageButtonState extends State<LanguageButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      decoration: BoxDecoration(
        border: Border.all(color: customColors().secretGarden),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () async {
              setState(() {
                widget.indexval = 1;
              });

              await PreferenceUtils.storeDataToShared('language', 'en');
              RestartWidget.restartApp(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: widget.indexval == 1 ? customColors().crisps : null,
              ),
              child: Center(
                child: Text(
                  'En',
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyL_Bold,
                    color: FontColor.FontPrimary,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
              width: 1.0,
              height: 15.0,
              decoration: BoxDecoration(
                border: Border.all(color: customColors().fontPrimary),
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              setState(() {
                widget.indexval = 2;
              });
              await PreferenceUtils.storeDataToShared('language', 'ar');
              RestartWidget.restartApp(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: widget.indexval == 2 ? customColors().crisps : null,
              ),
              child: Center(
                child: Text(
                  'ع',
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyL_Bold,
                    color: FontColor.FontPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
