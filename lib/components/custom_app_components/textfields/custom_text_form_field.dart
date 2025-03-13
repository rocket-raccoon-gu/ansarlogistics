import 'dart:async';

import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatefulWidget {
  final BuildContext context;
  final bool enabled;
  final dynamic textCapitalization;
  final TextEditingController controller;
  final List<TextInputFormatter>? inputFormatter;
  final Color? bordercolor;
  final Color? bgColor;
  final String fieldName;
  final String? hintText;
  final String defaultErrorMessage;

  final Widget? maxLengthEnforcement;
  final TextInputType? keyboardType;
  // final ValueChanged<String>? onchangedAction;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Validator? validator;
  final int? width;
  final double? height;
  final double? labelBottomPadding;
  final bool obscureTextStatus;
  final bool readonlyState;
  final Function? keyboardAction;
  final bool isInputaction;
  final bool autoFocus;
  final bool obscureIcon;
  TextInputAction? textInputAction;
  final Color? fillColor;
  final Widget? topEndWidget;
  final Widget? bottomStartWidget;
  final Widget? bottomEndWidget;
  final Function(String)? onFieldSubmit;
  final Function(String)? onChange;
  final Function(String)? onErrorCallBack;
  final int? maxLines;
  FocusNode? focusNode;
  final Color? focusedColor;
  final String? suffixtext;
  final Widget? prefixWidget;
  final int? minimumValueLimit;
  final double? minimumDecimalValueLimit;
  final TextAlign textAlign;
  Widget? sufixWidget;

  CustomTextFormField({
    Key? key,
    required this.context,
    this.autoFocus = false,
    this.enabled = true,
    this.obscureIcon = false,
    this.textCapitalization = TextCapitalization.none,
    this.onErrorCallBack,
    required this.controller,
    this.inputFormatter,
    this.bordercolor,
    this.focusedColor,
    this.bgColor,
    required this.fieldName,
    this.hintText = " ",
    this.defaultErrorMessage = "Please fill valid data",
    this.maxLength,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureTextStatus = false,
    this.width,
    this.height = 69,
    this.maxLengthEnforcement,
    this.keyboardType,
    // this.onchangedAction,
    this.readonlyState = false,
    this.labelBottomPadding,
    this.keyboardAction,
    this.isInputaction = false,
    this.textInputAction,
    this.fillColor,
    this.topEndWidget,
    this.bottomStartWidget,
    this.bottomEndWidget,
    this.onFieldSubmit,
    this.onChange,
    this.focusNode,
    this.maxLines,
    this.suffixtext,
    this.prefixWidget,
    this.minimumValueLimit,
    this.minimumDecimalValueLimit,
    this.textAlign = TextAlign.start,
    this.sufixWidget,
  }) : super(key: key);
  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool contentVisibility = false;
  // final phoneValidator = MultiValidator();
  @override
  void initState() {
    // TODO: implement initState
    contentVisibility = widget.obscureTextStatus;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double mheight = MediaQuery.of(context).size.height * 1.22;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.fieldName != "")
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.fieldName,
                style: customTextStyle(
                  fontStyle: FontStyle.BodyL_Regular,
                  color: FontColor.FontPrimary,
                ),
              ),
              widget.topEndWidget ?? Container(),
            ],
          ),
        Padding(
          padding: EdgeInsets.only(top: widget.labelBottomPadding ?? 8.0),
          child: TextFormField(
            readOnly: widget.readonlyState,
            textAlign: widget.textAlign,
            //    enableInteractiveSelection: false,
            //    textInputAction: widget.textInputAction ?? TextInputAction.none,
            // onFieldSubmitted: (value) {
            //   //     if (widget.keyboardAction != null) widget.keyboardAction!();
            // },
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: widget.keyboardType,
            minLines: widget.maxLines ?? 1,
            maxLines: widget.maxLines ?? 1,
            maxLength: widget.maxLength,
            cursorRadius: const Radius.circular(4.0),
            showCursor: true,
            onFieldSubmitted: widget.onFieldSubmit,
            onChanged: widget.onChange,
            obscureText: contentVisibility,
            obscuringCharacter: "●",
            autofocus: widget.autoFocus,
            textCapitalization: widget.textCapitalization,
            textAlignVertical: TextAlignVertical.center,
            controller: widget.controller,
            focusNode: widget.focusNode,
            inputFormatters: widget.inputFormatter,
            cursorColor: customColors().fontPrimary,
            validator: (value) {
              return customValidate(context, value.toString());
            },
            enabled: widget.enabled,
            style: customTextStyle(
              fontStyle: FontStyle.BodyL_Regular,
              color: FontColor.FontPrimary,
            ),
            decoration: InputDecoration(
              prefix: widget.prefixWidget,
              filled: true,
              helperText: "",
              helperStyle: const TextStyle(fontSize: 0),
              errorStyle: const TextStyle(fontSize: 0),
              suffix: widget.sufixWidget,
              suffixText: widget.suffixtext,
              fillColor:
                  widget.enabled
                      ? widget.fillColor ?? customColors().backgroundPrimary
                      : widget.fillColor ?? customColors().backgroundSecondary,
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color:
                      widget.bordercolor ?? customColors().backgroundTertiary,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              hintText: widget.hintText,
              hintStyle: customTextStyle(
                fontStyle: FontStyle.BodyL_Regular,
                color: FontColor.FontTertiary,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color:
                      widget.focusedColor ??
                      widget.bordercolor ??
                      customColors().backgroundTertiary,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color:
                      widget.bordercolor ?? customColors().backgroundTertiary,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: customColors().danger, width: 1),
                borderRadius: BorderRadius.circular(4.0),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: customColors().backgroundTertiary,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: customColors().danger, width: 1),
                borderRadius: BorderRadius.circular(4.0),
              ),
              suffixIcon:
                  widget.suffixIcon ??
                  ((widget.obscureIcon)
                      ? GestureDetector(
                        onTap: () {
                          setState(() {
                            contentVisibility = !contentVisibility;
                          });
                        },
                        child:
                            contentVisibility
                                ? Image.asset('assets/vector_eye_cross.png')
                                : Image.asset('assets/vector_eye.png'),
                      )
                      : null),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 10,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widget.bottomStartWidget ?? Container(),
            widget.bottomEndWidget ?? Container(),
          ],
        ),
      ],
    );
  }

  String? customValidate(BuildContext context, String value) {
    String? error;
    switch (widget.validator) {
      case Validator.none:
        error = noValidation(value);
        break;
      case Validator.defaultValidator:
        error = emptyValidation(value, widget.defaultErrorMessage);
        break;
      case Validator.account:
        error = accountValidation(value);
        break;
      case Validator.password:
        error = passwordValidation(value);
        break;
      case Validator.otp:
        error = otpValidation(value);
        break;
      case Validator.upi:
        error = upiValidation(value);
        break;
      case Validator.price:
        error = priceValidation(value);
        break;
      case Validator.date:
        error = dateValidation(value);
        break;
      case Validator.minimumValueLimit:
        error = minimumValueValidation(value, widget.minimumValueLimit);
        break;
      case Validator.minimumDecimalValueLimit:
        error = minimumDecimalValueValidation(
          value,
          widget.minimumDecimalValueLimit,
        );
        break;
      // case Validator.watchlistValidator:
      //   error = charecterValidation(value, widget.defaultErrorMessage);
      //   break;
      // case Validator.editWatchlistValidator:
      //   error = editWatchNameValidation(value, widget.defaultErrorMessage);
      //   break;
      // case Validator.basketValidator:
      //   error = basketValidation(value, widget.defaultErrorMessage);
      //   break;
      // case Validator.editBasketValidator:
      //   error = editBasketNameValidation(value, widget.defaultErrorMessage);
      //   break;
      // case Validator.percentageValidator:
      //   error = percentageValidation(value, widget.defaultErrorMessage);
      //   break;
      default:
        error = emptyValidation(
          widget.controller.value.toString(),
          widget.defaultErrorMessage,
        );
    }
    if (error != null) {
      showSnackBar(
        context: context,
        snackBar: showErrorDialogue(errorMessage: error),
      );
      if (widget.onErrorCallBack != null) {
        widget.onErrorCallBack!(error);
      }
    }
    return error;
  }
}

dynamic emptyValidation(String value, String errorString) {
  if (value.isEmpty || value == "") {
    return errorString;
  }
  return null;
}

dynamic noValidation(String value) {
  // return null;
}

dynamic dateValidation(String value) {
  if (value == "") {
    return "Please enter DOB";
  } else if (value.length != 8 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
    return "Incorrect date format";
  }
}

dynamic accountValidation(String value) {
  if (value == "") {
    return "Trade Code/CIN required";
  }
  // else if (value != "ADMIN") {
  //   return "Account doesnot exist";
  // }
}

dynamic passwordValidation(String value) {
  if (value == "") {
    return "Password required";
  }
  // else if (value != "admin") {
  //   return "Incorrect Password";
  // }
}

dynamic upiValidation(String value) {
  if (value.isEmpty) {
    return "UPI ID Required";
  }
}

dynamic priceValidation(String value) {
  if (value.isEmpty) {
    return "";
  }
}

dynamic minimumValueValidation(String value, int? minimumValue) {
  if (value.isEmpty ||
      (int.tryParse(value.replaceAll(",", ""))! < minimumValue!)) {
    return "minimum value is $minimumValue";
  }
}

dynamic minimumDecimalValueValidation(String value, double? minimumValue) {
  if (value.isEmpty ||
      (double.tryParse(value.replaceAll(",", ""))! < minimumValue!)) {
    return "Invalid value";
  }
}

// dynamic charecterValidation(String value, String errorString) {
//   if (value.isEmpty || value == "") {
//     return errorString;
//   } else if (UserController.userController.watchlists.any((element) =>
//       element.watchlistData.watchname.toUpperCase() == value.toUpperCase())) {
//     return errorString = "watchlist name already exists";
//   }
//   return null;
// }

// dynamic editWatchNameValidation(String value, String errorString) {
//   if (value.isEmpty || value == "") {
//     return errorString;
//   } else if (GeneralMethods.checkWatchNameDuplication(watchname: value)) {
//     return errorString = "watchlist name already exists";
//   }
//   return null;
// }

// dynamic basketValidation(String value, String errorString) {
//   if (value.isEmpty || value == "") {
//     return errorString;
//   } else if (UserController.userController.basketDetails.any((element) =>
//       element.basketData.basketname!.toUpperCase() == value.toUpperCase())) {
//     return errorString = "Basket name already exists";
//   }
//   return null;
// }

// dynamic editBasketNameValidation(String value, String errorString) {
//   if (value.isEmpty || value == "") {
//     return errorString;
//   } else if (GeneralMethods.checkBasketNameDuplication(basketName: value)) {
//     return errorString = "Basket name already exists";
//   }
//   return null;
// }

// dynamic percentageValidation(String value, String errorSring) {
//   if ((double.tryParse(value) ?? 0.00) > 100.00) {
//     return errorSring;
//   }
//   return null;
// }

dynamic otpValidation(String value) {
  if (value.isEmpty) {
    return "Otp Required";
  } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
    return "Invalid format";
  }
  return null;
}

enum Validator {
  none,
  defaultValidator,
  password,
  account,
  otp,
  upi,
  price,
  date,
  minimumValueLimit,
  minimumDecimalValueLimit,
  watchlistValidator,
  editWatchlistValidator,
  basketValidator,
  editBasketValidator,
  percentageValidator,
}

class UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text != newValue.text.toUpperCase()) {
      return TextEditingValue(
        text: newValue.text.toUpperCase(),
        selection: newValue.selection,
      );
    }
    return newValue;
  }
}
