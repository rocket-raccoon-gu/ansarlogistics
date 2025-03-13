import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';

class CustomDividerWithPadding extends StatelessWidget {
  double? horizondalPadding;
  CustomDividerWithPadding({this.horizondalPadding, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizondalPadding ?? 16,
        vertical: 4,
      ),
      child: SizedBox(
        height: 0,
        child: Divider(
          thickness: 1.2,
          color: customColors().backgroundTertiary,
        ),
      ),
    );
  }
}
