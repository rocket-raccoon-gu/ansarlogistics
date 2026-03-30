import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/order_response.dart';

class OrderInnerAppBar extends StatelessWidget {
  Order orderResponseItem;
  Function()? onTapinfo;
  Function()? onTapBack;
  final Function()? onTaptranslate;
  OrderInnerAppBar({
    super.key,
    required this.orderResponseItem,
    required this.onTapinfo,
    required this.onTapBack,
    this.onTaptranslate,
  });

  bool translate = false;

  @override
  Widget build(BuildContext context) {
    double mheight = MediaQuery.of(context).size.height * 1.222;
    Size screenSize = MediaQuery.of(context).size;
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
            height: 50.0,
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
                      Expanded(
                        child: InkWell(
                          onTap: onTapinfo,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: screenSize.width * 0.6,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Order ID',
                                  style: customTextStyle(
                                    fontStyle: FontStyle.BodyS_Regular,
                                    color: FontColor.FontSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        orderResponseItem.subgroupIdentifier
                                            .toString(),
                                        style: customTextStyle(
                                          fontStyle: FontStyle.Lato_Bold,
                                          color: FontColor.FontPrimary,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    ImageIcon(
                                      AssetImage("assets/info.png"),
                                      color: HexColor('#A3A3A3'),
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Positioned(
          //   right: 15.0,
          //   bottom: 25.0,
          //   child: TranslateWidget(onTaptranslate: onTaptranslate),
          // ),
        ],
      ),
    );
  }
}

class TranslateWidget extends StatefulWidget {
  final Function()? onTaptranslate;
  const TranslateWidget({super.key, required this.onTaptranslate});

  @override
  State<TranslateWidget> createState() => _TranslateWidgetState();
}

class _TranslateWidgetState extends State<TranslateWidget> {
  bool translate = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: () {
          widget.onTaptranslate!();
          setState(() {
            translate = !translate;
          });
        },
        child: Container(
          padding: EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color:
                translate ? customColors().secretGarden : customColors().accent,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Icon(Icons.translate),
        ),
      ),
    );
  }
}
