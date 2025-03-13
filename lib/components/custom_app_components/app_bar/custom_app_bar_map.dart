import 'dart:developer';

import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';

class CustomAppBarMap extends StatelessWidget {
  Function()? onTapBack;
  CustomAppBarMap({super.key, required this.onTapBack});

  @override
  Widget build(BuildContext context) {
    double mheight = MediaQuery.of(context).size.height * 1.222;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      decoration: BoxDecoration(
        color: HexColor('#F9FBFF'),
        border: Border(
          bottom: BorderSide(
            width: 2.0,
            color: customColors().backgroundTertiary,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: customColors().backgroundTertiary.withOpacity(1.0),
            spreadRadius: 3,
            blurRadius: 5,
            // offset: Offset(0, 3), // changes the position of the shadow
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            height: 35.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: onTapBack,
                  child: Icon(
                    Icons.arrow_back,
                    size: 25,
                    color: HexColor("#A3A3A3"),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "My Order Routes",
                        style: customTextStyle(
                          fontStyle: FontStyle.Lato_Bold,
                          color: FontColor.FontPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18.0,
                          vertical: 5.0,
                        ),
                        child: Row(children: []),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
