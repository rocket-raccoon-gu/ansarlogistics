import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';

class SessionOutBottomSheet extends StatelessWidget {
  VoidCallback? onTap;
  SessionOutBottomSheet({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 40),
        Image.asset("assets/failed.png"),
        const SizedBox(height: 16),
        Text(
          "Oh no! Session Timed Out",
          textAlign: TextAlign.center,
          style: customTextStyle(
            fontStyle: FontStyle.HeaderS_SemiBold,
            color: FontColor.FontPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Your session timed out, or you logged in from a diffrent location",
          textAlign: TextAlign.center,
          style: customTextStyle(
            fontStyle: FontStyle.BodyL_Regular,
            color: FontColor.FontSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: BasketButton(
                  bgcolor: customColors().primary,
                  text: "Relogin",
                  textStyle: customTextStyle(
                    fontStyle: FontStyle.BodyL_SemiBold,
                    color: FontColor.White,
                  ),
                  onpress: onTap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
