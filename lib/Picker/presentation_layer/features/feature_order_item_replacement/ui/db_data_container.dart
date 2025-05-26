import 'package:ansarlogistics/components/custom_app_components/buttons/counter_button.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/product_bd_data_response.dart';

class DbDataContainer extends StatefulWidget {
  ProductDBdata? productDBdata;
  Function(int) counterCallback;
  DbDataContainer({
    super.key,
    required this.productDBdata,
    required this.counterCallback,
  });

  @override
  State<DbDataContainer> createState() => _DbDataContainerState();
}

class _DbDataContainerState extends State<DbDataContainer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 275.0,
          width: 275.0,
          child:
              widget.productDBdata!.images != null
                  ? Image.network(
                    '${mainimageurl}${getFirstImage(widget.productDBdata!.images)}',
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
                          widget.productDBdata!.skuName,
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
                              widget.productDBdata!.specialPrice != ""
                                  ? widget.productDBdata!.specialPrice
                                      .toString()
                                  : double.parse(
                                    widget.productDBdata!.regularPrice,
                                  ).toStringAsFixed(2).toString(),
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
                              "SKU: ${widget.productDBdata!.sku}",
                              style: customTextStyle(
                                fontStyle: FontStyle.HeaderXS_Bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (widget.productDBdata?.isProduce == "0")
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 14.0,
                      ),
                      child: CounterDropdown(
                        initNumber: 0,
                        counterCallback: widget.counterCallback,
                        maxNumber: 100,
                        minNumber: 0,
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
