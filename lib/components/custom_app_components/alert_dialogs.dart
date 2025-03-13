import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';

Future<dynamic> showAlertDilogue({
  required BuildContext context,
  required String content,
  bool dismissable = false,
  String? positiveButtonName,
  String? negativeButtonName,
  VoidCallback? onPositiveButtonClick,
  VoidCallback? onNegativeButtonClick,
}) async {
  return showDialog(
    barrierDismissible: dismissable,
    context: context,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async {
          return dismissable;
        },
        child: AlertDialog(
          backgroundColor: customColors().backgroundPrimary,
          content: Text(
            content,
            style: customTextStyle(
              fontStyle: FontStyle.BodyM_SemiBold,
              color: FontColor.FontSecondary,
            ),
          ),
          actions: [
            if (negativeButtonName != null)
              TextButton(
                child: Text(
                  negativeButtonName,
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyM_SemiBold,
                    color: FontColor.Danger,
                  ),
                ),
                onPressed: onNegativeButtonClick,
              ),
            TextButton(
              child: Text(
                positiveButtonName ?? "Ok",
                style: customTextStyle(
                  fontStyle: FontStyle.BodyM_SemiBold,
                  color: FontColor.Info,
                ),
              ),
              onPressed: onPositiveButtonClick,
            ),
          ],
        ),
      );
    },
  );
}
