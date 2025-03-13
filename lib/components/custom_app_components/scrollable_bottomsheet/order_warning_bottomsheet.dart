import 'package:ansarlogistics/common_features/feature_profile/profile.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class OrderWarningBottomSheet extends StatelessWidget {
  final bool? isWarning;
  final String? link, linkText;
  final String errorMsg, heading;
  const OrderWarningBottomSheet({
    Key? key,
    this.isWarning = false,
    this.link,
    this.linkText,
    required this.heading,
    required this.errorMsg,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: 8,
            top: 4,
            left: 16,
            right: 16,
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/danger.png',
                color:
                    (isWarning ?? false)
                        ? customColors().warning
                        : customColors().danger,
              ),
              const SizedBox(width: 8),
              Text(
                heading,
                style: customTextStyle(
                  fontStyle: FontStyle.HeaderXS_SemiBold,
                  color:
                      (isWarning ?? false)
                          ? FontColor.Warning
                          : FontColor.Danger,
                ),
              ),
            ],
          ),
        ),
        CustomDividerWithPadding(horizondalPadding: 0),
        Padding(
          padding: const EdgeInsets.only(
            top: 12,
            bottom: 16,
            left: 16,
            right: 16,
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: RichText(
              text: TextSpan(
                text: errorMsg,
                style: customTextStyle(
                  fontStyle: FontStyle.BodyL_Regular,
                  color: FontColor.FontPrimary,
                ),
                children: <TextSpan>[
                  if (link != null)
                    TextSpan(
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () async {
                              final uri = Uri.parse(link!);
                              // if (await canLaunchUrl(uri)) {
                              //   await launchUrl(uri);
                              // } else {
                              //   await context.gNavigationService
                              //       .openWebViewPage(context, {"url": link});
                              // }
                            },
                      text: linkText ?? "",
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyL_Regular,
                        color: FontColor.Info,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: BasketButton(
                    textStyle: customTextStyle(
                      fontStyle: FontStyle.BodyL_Bold,
                      color: FontColor.White,
                    ),
                    text: "Close",
                    bgcolor: customColors().primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
