import 'package:ansarlogistics/components/custom_app_components/textfields/translated_text.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BasketButton extends StatelessWidget {
  String? text;
  VoidCallback? onpress;
  Color? bgcolor;
  TextStyle textStyle;
  Color bordercolor;
  Color indicatorColor;
  double? buttonwidth;
  bool enabled;
  double? verticalPadding;
  bool loading;
  Color? splashColor;
  BasketButton({
    Key? key,
    this.text,
    this.onpress,
    this.bgcolor,
    required this.textStyle,
    this.bordercolor = transparent,
    this.buttonwidth,
    this.enabled = true,
    this.verticalPadding,
    this.loading = false,
    this.indicatorColor = white,
    this.splashColor,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return InkWell(
      splashColor: splashColor ?? transparent,
      highlightColor: transparent,
      enableFeedback: enabled,
      onTap: enabled ? onpress : () {},
      child: Container(
        padding: EdgeInsets.symmetric(vertical: verticalPadding ?? 14.0),
        width: buttonwidth ?? screenSize.width,
        decoration: BoxDecoration(
          color: enabled ? bgcolor : bgcolor!.withOpacity(0.5),
          borderRadius: BorderRadius.circular(3.54),
          border: Border.all(color: bordercolor),
        ),
        child: Center(
          child:
              loading
                  ? CupertinoActivityIndicator(
                    animating: true,
                    color: indicatorColor,
                  )
                  // : Text(text.toString(), style: textStyle),
                  : TranslatedText(text: text.toString(), style: textStyle),
        ),
      ),
    );
  }
}

class BasketButtonwithIcon extends StatelessWidget {
  String? text;
  VoidCallback? onpress;
  Color? bgcolor;
  TextStyle textStyle;
  Color bordercolor;
  Color indicatorColor;
  double? buttonwidth;
  bool enabled;
  double? verticalPadding;
  bool loading;
  Color? splashColor;
  String? image;
  Color? imagecolor;
  BasketButtonwithIcon({
    Key? key,
    this.text,
    this.onpress,
    this.bgcolor,
    required this.textStyle,
    this.bordercolor = transparent,
    this.buttonwidth,
    this.enabled = true,
    this.verticalPadding,
    this.loading = false,
    this.indicatorColor = white,
    this.splashColor,
    this.image,
    this.imagecolor,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return InkWell(
      splashColor: splashColor ?? transparent,
      highlightColor: transparent,
      enableFeedback: enabled,
      onTap: enabled ? onpress : () {},
      child: Container(
        padding: EdgeInsets.symmetric(vertical: verticalPadding ?? 14.0),
        width: buttonwidth ?? screenSize.width,
        decoration: BoxDecoration(
          color: enabled ? bgcolor : bgcolor!.withOpacity(0.5),
          borderRadius: BorderRadius.circular(3.54),
          border: Border.all(color: bordercolor),
        ),
        child: Center(
          child:
              loading
                  ? CupertinoActivityIndicator(
                    animating: true,
                    color: indicatorColor,
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        image!,
                        color: imagecolor ?? customColors().backgroundPrimary,
                        height: 20.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        // child: Text(text.toString(), style: textStyle),
                        child: TranslatedText(
                          text: text.toString(),
                          style: textStyle,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
