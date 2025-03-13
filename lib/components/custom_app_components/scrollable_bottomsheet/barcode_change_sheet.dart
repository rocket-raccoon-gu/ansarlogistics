import 'package:ansarlogistics/themes/style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BarcodeChangeSheet extends StatefulWidget {
  var curve;
  String scannedbarcode;
  Function(String)? confirmTap;
  BarcodeChangeSheet({
    super.key,
    required this.curve,
    required this.scannedbarcode,
    required this.confirmTap,
  });

  @override
  State<BarcodeChangeSheet> createState() => _BarcodeChangeSheetState();
}

class _BarcodeChangeSheetState extends State<BarcodeChangeSheet> {
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: widget.curve,
      child: AlertDialog(
        content: StatefulBuilder(
          builder: (context, StateSetter state) {
            return SizedBox(
              width: 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Column(
                        children: [
                          TextFormField(
                            autofocus: true,
                            initialValue: widget.scannedbarcode,
                            onChanged: (value) {
                              setState(() {
                                widget.scannedbarcode = value;
                              });
                            },
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyM_Bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      widget.confirmTap!(widget.scannedbarcode);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: customColors().accent,
                                      ),
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
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Positioned(
                      //     right: 2.0,
                      //     child: InkWell(
                      //         onTap: () {
                      //           context.gNavigationService.back(context);
                      //         },
                      //         child: Icon(Icons.close)))
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
