import 'dart:developer';

import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/order_response.dart';

customShowModalBottomSheet({
  required BuildContext context,
  required Widget inputWidget,
  Widget? errorDialogue,
  AnimationController? controller,
  BoxConstraints? heightConstraint,
}) {
  return showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    transitionAnimationController: controller,
    enableDrag: true,
    constraints:
        heightConstraint ??
        BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .9),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(8.0),
        topRight: Radius.circular(8.0),
      ),
    ),
    builder: (BuildContext buildcontext) {
      return Stack(
        alignment: Alignment.center,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: SingleChildScrollView(
                child: AnimatedPadding(
                  padding: MediaQuery.of(context).viewInsets,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.decelerate,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        child: Container(
                          decoration: BoxDecoration(
                            color: customColors().backgroundTertiary,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          height: 4,
                          width: 64,
                        ),
                      ),
                      inputWidget,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(top: 0, child: errorDialogue ?? Container()),
        ],
      );
    },
  );
}

sessionTimeOutBottomSheet({
  required BuildContext context,
  required Widget inputWidget,
  bool dismissable = false,
}) {
  return showModalBottomSheet(
    isDismissible: false,
    context: context,
    enableDrag: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(8.0),
        topRight: Radius.circular(8.0),
      ),
    ),
    builder: (BuildContext buildContext) {
      return WillPopScope(
        onWillPop: () async {
          return dismissable;
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: SingleChildScrollView(
              child: AnimatedPadding(
                padding: MediaQuery.of(context).viewInsets,
                duration: const Duration(milliseconds: 100),
                curve: Curves.decelerate,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      child: Container(
                        decoration: BoxDecoration(
                          color: customColors().backgroundTertiary,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        height: 4,
                        width: 64,
                      ),
                    ),
                    inputWidget,
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

customShowModalBottomSheetEg({
  required BuildContext context,
  required Widget inputWidget,
}) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(8.0),
        topRight: Radius.circular(8.0),
      ),
    ),
    builder: (context) {
      return inputWidget;
    },
  );
}

class OutOfStockBottomSheet extends StatefulWidget {
  Function(int val, String status)? onconfirmpress;
  Function() onTapoutofstock;
  Function(String reason) onTapitemcancel;
  EndPicking? itemdata;
  Order? orderItemsResponse;
  OutOfStockBottomSheet({
    super.key,
    required this.itemdata,
    required this.orderItemsResponse,
    required this.onTapoutofstock,
    required this.onTapitemcancel,
  });

  @override
  State<OutOfStockBottomSheet> createState() => _OutOfStockBottomSheetState();
}

class _OutOfStockBottomSheetState extends State<OutOfStockBottomSheet> {
  bool isClickable = true;

  int selectedindex = -1;

  @override
  Widget build(BuildContext context) {
    return isClickable
        ? WillPopScope(
          onWillPop: () async {
            return Future.value(true);
          },
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 5.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select the Option",
                      style: customTextStyle(fontStyle: FontStyle.BodyL_Bold),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Divider(color: customColors().fontTertiary),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 5.0,
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      // widget.reasoncancel = 0;
                      selectedindex = 2;
                    });
                    // widget.onReplacepress!();

                    context.gNavigationService.openOrderItemReplacementPage(
                      context,
                      arg: {
                        'item': widget.itemdata,
                        'order': widget.orderItemsResponse,
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color:
                          selectedindex == 2
                              ? HexColor('#b9d737')
                              : Colors.transparent,
                      border: Border.all(color: customColors().fontTertiary),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            "Replace the Item",
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyM_Bold,
                              color: FontColor.FontPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 5.0,
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedindex = 1;
                    });
                    widget.onTapoutofstock();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color:
                          selectedindex == 1
                              ? HexColor('#b9d737')
                              : Colors.transparent,
                      border: Border.all(color: customColors().fontTertiary),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            "Item Out Of Stock",
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyM_Bold,
                              color: FontColor.FontPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5.0,
                ),
                child: InkWell(
                  onTap: () async {
                    // setState(() {
                    //   // widget.reasoncancel = 0;
                    //
                    // });
                    setState(() {
                      isClickable = false;
                      selectedindex = 2;
                    });
                    // if (widget.orderdetails.items.length == 1) {
                    //   //

                    //   showGeneralDialog(
                    //     context: context,
                    //     barrierDismissible: true,
                    //     barrierLabel: "",
                    //     pageBuilder:
                    //         (context, animation, secondaryAnimation) {
                    //       return Container();
                    //     },
                    //     transitionBuilder:
                    //         (context0, animation, secondaryAnimation, child) {
                    //       var curve =
                    //           Curves.easeInOut.transform(animation.value);

                    //       return Transform.scale(
                    //         scale: curve,
                    //         child: AlertDialog(
                    //           shape: RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.circular(8.0)),
                    //           content: Column(
                    //               mainAxisSize: MainAxisSize.min,
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               children: [
                    //                 Lottie.asset(
                    //                     'assets/animation_alert.json'),
                    //                 Padding(
                    //                   padding: const EdgeInsets.only(
                    //                       top: 25.0, bottom: 25.0),
                    //                   child: Text(
                    //                     "Cancel Not Allowed Make Cancel Request for this order..!",
                    //                     textAlign: TextAlign.center,
                    //                     style: customTextStyle(
                    //                         fontStyle: FontStyle.BodyL_Bold,
                    //                         color: FontColor.CarnationRed),
                    //                   ),
                    //                 ),
                    //                 InkWell(
                    //                   onTap: () {
                    //                     // setState(() {
                    //                     //   enablecancelrequest =
                    //                     //       true;
                    //                     // });
                    //                     Navigator.pop(context);
                    //                     Navigator.pop(context);
                    //                   },
                    //                   child: Container(
                    //                     padding: const EdgeInsets.symmetric(
                    //                         vertical: 10.0, horizontal: 8.0),
                    //                     decoration: BoxDecoration(
                    //                         color:
                    //                             customColors().carnationRed,
                    //                         borderRadius:
                    //                             BorderRadius.circular(5.0)),
                    //                     child: Center(
                    //                       child: Text(
                    //                         "OK",
                    //                         style: customTextStyle(
                    //                             fontStyle:
                    //                                 FontStyle.BodyL_Bold,
                    //                             color: FontColor.White),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 )
                    //               ]),
                    //         ),
                    //       );
                    //     },
                    //   );
                    // } else {
                    //   // item cancel
                    //   widget.onTapitemcancel();
                    // }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color:
                          selectedindex == 0
                              ? HexColor("#b9d737")
                              : Colors.transparent,
                      border: Border.all(color: customColors().fontTertiary),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Row(
                      children: [
                        // CustomRadioButton(
                        //     noLabel: true,
                        //     value: 0,
                        //     groupValue: widget.reasoncancel,
                        //     onChanged: (int val) {
                        //       setState(() {
                        //         widget.reasoncancel = val;
                        //       });
                        //     }),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            "Item Cancel",
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyM_Bold,
                              color: FontColor.FontPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
        : ReasonContainer(onTapitemcancel: widget.onTapitemcancel);
  }
}

class ReasonContainer extends StatelessWidget {
  ReasonContainer({super.key, required this.onTapitemcancel});

  Function(String reason) onTapitemcancel;

  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(true);
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  maxLines: 2,
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Enter Reason',
                    floatingLabelStyle: customTextStyle(
                      fontStyle: FontStyle.BodyL_Bold,
                      color: FontColor.FontPrimary,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: customColors().backgroundTertiary,
                        width: 2.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: customColors().backgroundTertiary,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // TextField(
                //   decoration: InputDecoration(
                //     labelText: 'Enter more text',
                //   ),
                // ),
                SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    log(controller.text);
                    onTapitemcancel(controller.text);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 15.0,
                    ),
                    decoration: BoxDecoration(color: customColors().red3),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: customTextStyle(
                          fontStyle: FontStyle.BodyL_Bold,
                          color: FontColor.White,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
