import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/custom_text_form_field.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';

class ManualForm extends StatefulWidget {
  Function()? onpress;
  TextEditingController controller;
  ManualForm({super.key, required this.onpress, required this.controller});

  @override
  State<ManualForm> createState() => _ManualFormState();
}

class _ManualFormState extends State<ManualForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            children: [
              Row(children: [Text("Enter product barcode")]),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      keyboardType: TextInputType.number,
                      bordercolor: customColors().fontTertiary,
                      context: context,
                      controller: widget.controller,
                      fieldName: "",
                      hintText: "Type here...",
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: BasketButton(
                  onpress: widget.onpress,
                  bgcolor: customColors().dodgerBlue,
                  text: "Enter",
                  textStyle: customTextStyle(
                    fontStyle: FontStyle.HeaderXS_Bold,
                    color: FontColor.White,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
