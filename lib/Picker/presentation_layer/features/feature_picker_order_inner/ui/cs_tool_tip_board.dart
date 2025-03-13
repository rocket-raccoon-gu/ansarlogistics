import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:super_tooltip/super_tooltip.dart';

class CsToolTipBoard extends StatelessWidget {
  String? phone_num;
  Function()? onTap;
  String ordernum;
  CsToolTipBoard({
    super.key,
    required this.phone_num,
    required this.onTap,
    required this.ordernum,
  });

  @override
  Widget build(BuildContext context) {
    return SuperTooltip(
      showBarrier: true,
      barrierColor: Colors.transparent,
      popupDirection: TooltipDirection.up,
      content: ToolTipContent(phone_num!, onTap, context, ordernum),
      child: Container(
        height: 80.0,
        width: 50.0,
        decoration: BoxDecoration(color: Colors.transparent),
      ),
    );
  }
}

Widget ToolTipContent(
  String phone,
  Function()? onTap,
  BuildContext context,
  String ordernum,
) {
  return SizedBox(
    width: 166,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: InkWell(
            onTap: () {
              whatsapp("", phone, context, ordernum);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 9.0,
              ),
              decoration: BoxDecoration(
                color: HexColor("#B7D635"),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Row(
                children: [
                  Image.asset('assets/whatsapp_min.png'),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      "Whatsapp",
                      style: customTextStyle(
                        fontStyle: FontStyle.Inter_Medium,
                        color: FontColor.White,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 9.0,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: customColors().fontTertiary),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Row(
                children: [
                  Image.asset('assets/phone.png'),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      "Call Customer",
                      style: customTextStyle(fontStyle: FontStyle.Inter_Medium),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
