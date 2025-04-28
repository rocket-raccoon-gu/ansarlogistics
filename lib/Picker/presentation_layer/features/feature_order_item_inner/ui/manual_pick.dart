import 'package:ansarlogistics/components/custom_app_components/buttons/counter_button.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/custom_text_form_field.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';
import 'package:picker_driver_api/responses/order_response.dart';

class ManualPick extends StatefulWidget {
  EndPicking? orderItem;
  Function(int) counterCallback;
  TextEditingController barcodeController;
  ManualPick({
    super.key,
    required this.orderItem,
    required this.counterCallback,
    required this.barcodeController,
  });

  @override
  State<ManualPick> createState() => _ManualPickState();
}

class _ManualPickState extends State<ManualPick> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 275.0, width: 275.0),

          Row(children: [Text("Enter product barcode")]),

          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  keyboardType: TextInputType.number,
                  bordercolor: customColors().fontTertiary,
                  context: context,
                  controller: widget.barcodeController,
                  fieldName: "",
                  hintText: "Type here...",
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: CounterDropdown(
              initNumber: 0,
              counterCallback: widget.counterCallback,
              maxNumber: 100,
              minNumber: 0,
            ),
          ),
        ],
      ),
    );
  }
}
