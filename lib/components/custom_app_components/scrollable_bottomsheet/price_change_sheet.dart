import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/order_response.dart';

class PriceChangeSheet extends StatefulWidget {
  List<String> mediaGalleryEntries = [];
  EndPicking data;
  var curve;
  String price = "0.00";
  String scannedbarcode;
  Function(int)? confirmTap;
  PriceChangeSheet({
    super.key,
    required this.mediaGalleryEntries,
    required this.data,
    required this.curve,
    required this.price,
    required this.scannedbarcode,
    required this.confirmTap,
  });

  @override
  State<PriceChangeSheet> createState() => _PriceChangeSheetState();
}

class _PriceChangeSheetState extends State<PriceChangeSheet> {
  int editquantity = 0;

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: widget.curve,
      child: AlertDialog(
        content: StatefulBuilder(
          builder: (context, StateSetter state) {
            return SizedBox(
              width: 100.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: ClipRRect(
                              child:
                                  widget.mediaGalleryEntries.isNotEmpty
                                      ? CachedNetworkImage(
                                        imageUrl:
                                            "${mainimageurl}${widget.mediaGalleryEntries[0].toString()}",
                                        imageBuilder: (context, imageProvider) {
                                          return Container(
                                            height: 109.0,
                                            width: 100.9,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          );
                                        },
                                        placeholder:
                                            (context, url) => Center(
                                              child: Image.asset(
                                                'assets/Iphone_spinner.gif',
                                              ),
                                            ),
                                        errorWidget: (context, url, error) {
                                          return Image.asset(
                                            'assets/placeholder.png',
                                          );
                                        },
                                      )
                                      : Image.asset(
                                        "'assets/placeholder.png'",
                                        height: 60.0,
                                        width: 60.0,
                                      ),
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(vertical: 10.0),
                          //   child: Text(
                          //     widget.data.productName,
                          //     textAlign: TextAlign.center,
                          //     style: customTextStyle(
                          //         fontStyle: FontStyle.BodyL_Bold,
                          //         color: FontColor.FontPrimary),
                          //   ),
                          // ),
                          Text(
                            widget.scannedbarcode,
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyM_Bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Price : QAR ",
                                  style: customTextStyle(
                                    fontStyle: FontStyle.BodyL_Bold,
                                  ),
                                ),
                                Text(
                                  widget.price,
                                  style: customTextStyle(
                                    fontStyle: FontStyle.BodyL_Bold,
                                    color: FontColor.FontPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            child: Text(
                              "Accept price change?",
                              textAlign: TextAlign.center,
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyL_SemiBold,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: BasketButton(
                                  loading: loading,
                                  onpress: () {
                                    if (!loading) {
                                      setState(() {
                                        loading = true;
                                      });

                                      widget.confirmTap!(editquantity);
                                    }
                                  },
                                  bgcolor: HexColor('#FCE444'),
                                  text: "Yes",
                                  textStyle: customTextStyle(
                                    fontStyle: FontStyle.BodyL_Bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: BasketButton(
                                  onpress: () {
                                    context.gNavigationService.back(context);
                                  },
                                  text: "NO",
                                  textStyle: customTextStyle(
                                    fontStyle: FontStyle.BodyL_Bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        right: 2.0,
                        child: InkWell(
                          onTap: () {
                            context.gNavigationService.back(context);
                          },
                          child: Icon(Icons.close),
                        ),
                      ),
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
