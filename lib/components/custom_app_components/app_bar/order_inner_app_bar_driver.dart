import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/driver_base_response.dart';

class OrderInnerAppBarDriver extends StatelessWidget {
  Function()? onTapinfo;
  Function()? onTapBack;
  final Function()? onTaptranslate;
  String? title;
  DataItem orderResponseItem;
  OrderInnerAppBarDriver({
    super.key,
    required this.onTapinfo,
    required this.onTapBack,
    this.onTaptranslate,
    this.title,
    required this.orderResponseItem,
  });

  @override
  Widget build(BuildContext context) {
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
            color: customColors().backgroundTertiary.withValues(alpha: 1.0),
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
                      // InkWell(
                      //   onTap: onTapinfo,
                      //   child: Text(
                      //     title ??
                      //         orderResponseItem.subgroupIdentifier.toString(),
                      //     style: customTextStyle(
                      //       fontStyle: FontStyle.Lato_Bold,
                      //       color: FontColor.FontPrimary,
                      //     ),
                      //   ),
                      // ),
                      InkWell(
                        onTap: onTapinfo,
                        child: ImageIcon(
                          AssetImage("assets/info.png"),
                          color: HexColor('#A3A3A3'),
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
