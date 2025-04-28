import 'package:ansarlogistics/components/custom_app_components/buttons/counter_button.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/erp_data_response.dart';

class ErpDataContainer extends StatefulWidget {
  ErPdata? erPdata;
  Function(int) counterCallback;
  ErpDataContainer({
    super.key,
    required this.erPdata,
    required this.counterCallback,
  });

  @override
  State<ErpDataContainer> createState() => _ErpDataContainerState();
}

class _ErpDataContainerState extends State<ErpDataContainer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 275.0,
          width: 275.0,
          child: Image.network('$noimageurl', fit: BoxFit.fill),
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
                          widget.erPdata!.erpProductName,
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
                              double.parse(
                                widget.erPdata!.erpPrice,
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
                              "SKU: ${widget.erPdata!.erpSku}",
                              style: customTextStyle(
                                fontStyle: FontStyle.HeaderXS_Bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(
                  //     vertical: 12.0,
                  //     horizontal: 14.0,
                  //   ),
                  //   child: CounterDropdown(
                  //     initNumber: 1,
                  //     counterCallback: (v) {
                  //       setState(() {
                  //         // editquantity = v;
                  //       });
                  //     },
                  //     maxNumber: 100,
                  //     minNumber: 0,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 14.0),
          child: CounterDropdown(
            initNumber: 0,
            counterCallback: widget.counterCallback,
            maxNumber: 100,
            minNumber: 0,
          ),
        ),
      ],
    );
  }
}
