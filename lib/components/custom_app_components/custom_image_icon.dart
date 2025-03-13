import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';

class CustomImageIcon extends StatelessWidget {
  final String imagepath;
  final Color? Imagecolor;
  CustomImageIcon({
    super.key,
    required this.imagepath,
    required this.Imagecolor,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagepath,
      color: Imagecolor ?? customColors().fontPrimary,
      height: 16.0,
      width: 16.0,
    );
  }
}
