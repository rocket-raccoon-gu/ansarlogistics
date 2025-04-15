import 'package:ansarlogistics/components/custom_app_components/custom_image_icon.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomSearchField extends StatefulWidget {
  final void Function(String) onSearch;
  final String hintText;
  bool focus;
  TextEditingController controller;
  TextInputType keyboardType;
  final GlobalKey<FormFieldState<String>> searchFormKey;
  final void Function() onFilter;
  CustomSearchField({
    super.key,
    required this.onSearch,
    this.focus = true,
    this.hintText = "Search Orderid",
    required this.searchFormKey,
    required this.controller,
    required this.keyboardType,
    required this.onFilter,
  });

  @override
  State<CustomSearchField> createState() => _CustomSearchFieldState();
}

class _CustomSearchFieldState extends State<CustomSearchField> {
  bool _clearbtn = false;
  _enableClose() {
    setState(() {
      _clearbtn = true;
    });
  }

  _disableClose() {
    setState(() {
      _clearbtn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double mheight = MediaQuery.of(context).size.height * 1.222;

    return Container(
      decoration: BoxDecoration(
        // color: customColors().backgroundPrimary,
        border: Border.all(color: customColors().fontTertiary),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 12.0),
              child: CustomImageIcon(
                imagepath: 'assets/search.png',
                Imagecolor: HexColor('#AEAEAE'),
              ),
            ),
            Expanded(
              child: SizedBox(
                width: double.maxFinite,
                child: TextFormField(
                  key: widget.searchFormKey,
                  // autofocus: widget.focus,
                  keyboardType: widget.keyboardType,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                    //   FilteringTextInputFormatter.allow(
                    //       RegExp(r'^[A-Za-z 0-9 &%]+')),
                  ],
                  controller: widget.controller,
                  decoration: InputDecoration(
                    // hintText: getTranslate(context, widget.hintText),
                    hintText: widget.hintText,
                    hintStyle: customTextStyle(
                      fontStyle: FontStyle.BodyL_Regular,
                      color: FontColor.FontTertiary,
                    ),
                    // filled: true,
                    // fillColor: customColors().backgroundPrimary,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  autocorrect: true,
                  // showCursor: widget.focus,
                  onChanged: (value) {
                    widget.onSearch(value);
                    if (value.isNotEmpty) {
                      _enableClose();
                    } else {
                      _disableClose();
                    }
                  },
                  cursorColor: customColors().fontPrimary,
                  onTap:
                      () => {
                        if (widget.controller.text.isNotEmpty) {_enableClose()},
                      },
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyL_Regular,
                    color: FontColor.FontPrimary,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: InkWell(
                onTap: widget.onFilter,
                child: Stack(
                  children: [
                    Positioned(
                      top: 4.0,
                      left: 5.0,
                      child: Container(
                        height: 10.0,
                        width: 10.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: customColors().carnationRed,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(color: HexColor('#ffff')),
                      child: Image.asset(
                        "assets/filter.png",
                        height: 25.0,
                        width: 25.0,
                        color: customColors().fontPrimary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
