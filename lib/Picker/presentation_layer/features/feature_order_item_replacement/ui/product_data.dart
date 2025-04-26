import 'package:ansarlogistics/components/custom_app_components/buttons/counter_button.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/order_response.dart';
import 'package:picker_driver_api/responses/product_response.dart';

class ProductData extends StatefulWidget {
  EndPicking? productResponse;
  int? editqty;
  ProductData({
    super.key,
    required this.productResponse,
    required this.editqty,
  });

  @override
  State<ProductData> createState() => _ProductDataState();
}

class _ProductDataState extends State<ProductData> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 275.0,
          width: 275.0,
          child:
              widget.productResponse!.productImages.isNotEmpty
                  ? Image.network(
                    '${mainimageurl}${widget.productResponse!.productImages[0]}',
                    fit: BoxFit.fill,
                  )
                  : Image.network(noimageurl, fit: BoxFit.fill),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.productResponse!.productName,
                          style: customTextStyle(
                            fontStyle: FontStyle.HeaderXS_Bold,
                            color: FontColor.FontPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              widget.productResponse!.price,
                              style: customTextStyle(
                                fontStyle: FontStyle.HeaderXS_Bold,
                                color: FontColor.FontPrimary,
                              ),
                            ),
                            Text(
                              "  QAR",
                              style: customTextStyle(
                                fontStyle: FontStyle.BodyL_Bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              // "SKU: ${state.prwork!.sku}",
                              "SKU: ${widget.productResponse!.productSku}",
                              style: customTextStyle(
                                fontStyle: FontStyle.HeaderXS_Bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
