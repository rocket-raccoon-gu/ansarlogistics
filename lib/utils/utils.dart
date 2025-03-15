import 'dart:developer';
import 'dart:io';

import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/ui/customer_details_sheet.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as crypto;
import 'package:intl/intl.dart';
import 'package:picker_driver_api/responses/order_response.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';

crypto.IV iv = crypto.IV.fromLength(16);

bool get applyTheme {
  if (Platform.isAndroid) {
    try {
      String versionString = Platform.operatingSystemVersion.split(" ")[1];
      int version = int.parse(versionString);
      if (version < 10) {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
  return true;
}

showSnackBar({required BuildContext context, required SnackBar snackBar}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

SnackBar showWaringDialogue({
  required String errorMessage,
  Duration duration = const Duration(milliseconds: 2000),
}) {
  return SnackBar(
    backgroundColor: customColors().silverDust,
    duration: duration,
    content: Text(
      errorMessage,
      style: customTextStyle(
        fontStyle: FontStyle.BodyM_SemiBold,
        color: FontColor.White,
      ),
    ),
  );
}

SnackBar showSuccessDialogue({
  required String message,
  Duration duration = const Duration(milliseconds: 2000),
}) {
  return SnackBar(
    backgroundColor: customColors().success,
    duration: duration,
    content: Text(
      message,
      style: customTextStyle(
        fontStyle: FontStyle.BodyM_SemiBold,
        color: FontColor.White,
      ),
    ),
  );
}

SnackBar showErrorDialogue({
  required String errorMessage,
  Duration duration = const Duration(milliseconds: 2000),
}) {
  return SnackBar(
    backgroundColor: customColors().danger,
    duration: duration,
    content: Text(
      errorMessage,
      style: customTextStyle(
        fontStyle: FontStyle.BodyM_SemiBold,
        color: FontColor.White,
      ),
    ),
  );
}

String keyVal(String userId) {
  String keyVal = userId;
  if (keyVal.length < 32) {
    keyVal = keyVal.padRight(32, "0");
  } else if (keyVal.length > 32) {
    keyVal = keyVal.substring(0, 32);
  }
  return keyVal;
}

String encryptStringForUser(String val, String keyVal) {
  final key = crypto.Key.fromUtf8(keyVal);
  final encrypter = crypto.Encrypter(crypto.AES(key));
  final encrypted = encrypter.encrypt(val, iv: iv);
  return encrypted.base64;
}

String decryptStringForUser(String val, String keyVal) {
  try {
    final key = crypto.Key.fromUtf8(keyVal);
    final encrypter = crypto.Encrypter(crypto.AES(key));
    final decrypted = encrypter.decrypt(
      crypto.Encrypted.fromBase64(val),
      iv: iv,
    );
    return decrypted;
  } catch (e) {
    return e.toString();
  }
}

getdateformatted(DateTime dt) {
  var dateformat = DateFormat('MM-dd-yyyy');
  var formatted = dateformat.format(dt);
  print(formatted);
  return formatted;
}

getdateformattedrescheduled(DateTime dt) {
  var dateformat = DateFormat('yyyy-MM-dd');
  var formatted = dateformat.format(dt);
  print(formatted);
  return formatted;
}

getFormatedDateForReport(String _date) {
  var inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  var date1 = inputFormat.parse(_date);

  var outputFormat = DateFormat('yyyy-MM-dd');

  var date2 = outputFormat.format(date1);

  return date2.toString();
}

Future<void> showTopModel(
  BuildContext context,
  ServiceLocator serviceLocator,
  Order order,
) async {
  final value = await showTopModalSheet<String?>(
    context,
    CustomerDetailsSheet(
      serviceLocator: serviceLocator,
      onTapClose: () {
        UserController().cancelreason = "Please Select Reason";
        context.gNavigationService.back(context);
      },
      orderResponseItem: order,
    ),
  );
}

getstatColor(String stat) {
  switch (stat) {
    case "Order Assigned":
      return customColors().dividentColor;
    case "Pending":
      return customColors().info;
    case "On The Way":
      return customColors().info;
    case "End Picked":
      return customColors().secretGarden;
    case "Delivered":
      return customColors().secretGarden;
    case "Customer Not Answer":
      return customColors().crisps;
    case "Canceled":
      return customColors().carnationRed;
    default:
  }
}

Widget getitemstat(EndPicking data, BuildContext context) {
  if (data.itemStatus == "canceled" ||
      data.qtyOrdered == double.parse(data.qtyCanceled).toInt()) {
    return Text(
      "Canceled",
      style: customTextStyle(
        fontStyle: FontStyle.BodyL_Bold,
        color: FontColor.Danger,
      ),
    );
  } else if (data.itemStatus == "end_picking" ||
      UserController.userController.indexlist.contains(data)) {
    return Text(
      "Picked",
      style: customTextStyle(
        fontStyle: FontStyle.BodyL_Bold,
        color: FontColor.SecretGarden,
      ),
    );
  } else if (data.itemStatus == "start_picking") {
    return Text(
      // "${getTranslate(context, "Start Picking")}",
      "Start Picking",
      style: customTextStyle(
        fontStyle: FontStyle.BodyL_Bold,
        color: FontColor.SecretGarden,
      ),
    );
  } else if (data.itemStatus == "item_not_available" ||
      UserController.userController.itemnotavailablelist.contains(data)) {
    return Text(
      "Item Not Available",
      style: customTextStyle(
        fontStyle: FontStyle.BodyL_Bold,
        color: FontColor.DodgerBlue,
      ),
    );
  } else if (data.itemStatus == "assigned_picker") {
    return Text(
      "Assigned Picker",
      style: customTextStyle(
        fontStyle: FontStyle.BodyL_Bold,
        color: FontColor.Purple,
      ),
    );
  } else {
    return Text(
      "Ordered",
      style: customTextStyle(
        fontStyle: FontStyle.BodyL_Bold,
        color: FontColor.Accent,
      ),
    );
  }
}

String getPrice(String code) {
  String last = code;
  String price = "00";
  if (code.startsWith('00')) {
    last = code.substring(2);
  }
  double parsedValue = double.parse(last) / 1000;
  print(parsedValue);
  // price = parsedValue.toString();
  String priceString = parsedValue.toString();
  int dotIndex = priceString.indexOf('.');
  if (dotIndex != -1 && dotIndex < priceString.length - 2) {
    // Decimal part is not zero
    price = priceString.substring(
      0,
      dotIndex + 3,
    ); // Include up to two decimal places
  } else {
    // Decimal part is zero
    price = priceString;
  }
  return price;
}
