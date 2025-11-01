import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_inner/bloc/order_item_details_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_order_item_replacement/bloc/item_replacement_page_cubit.dart';
import 'package:ansarlogistics/Picker/presentation_layer/features/feature_picker_order_inner/ui/customer_details_sheet.dart';
// import 'package:ansarlogistics/Section_In/features/feature_home_section_incharge/bloc/home_section_incharge_state.dart';
// import 'package:ansarlogistics/Section_In/features/feature_home_section_incharge/ui/ar_branch_section.dart';
// import 'package:ansarlogistics/Section_In/features/feature_home_section_incharge/ui/home_section.dart';
// import 'package:ansarlogistics/Section_In/features/feature_home_section_incharge/ui/other_branch_section.dart';
import 'package:ansarlogistics/app_page_injectable.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/basket_button.dart';
import 'package:ansarlogistics/components/custom_app_components/buttons/counter_button.dart';
import 'package:ansarlogistics/components/custom_app_components/textfields/custom_text_form_field.dart';
import 'package:ansarlogistics/constants/methods.dart';
import 'package:ansarlogistics/constants/texts.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as crypto;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:picker_driver_api/responses/erp_data_response.dart';
import 'package:picker_driver_api/responses/order_response.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';
import 'package:picker_driver_api/responses/product_bd_data_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';
import 'package:barcode_widget/barcode_widget.dart';

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

TextStyle titleStyle() => customTextStyle(
  fontStyle: FontStyle.BodyL_Bold,
  color: FontColor.FontPrimary,
);

TextStyle subtitleStyle() => customTextStyle(
  fontStyle: FontStyle.BodyM_Bold,
  color: FontColor.FontSecondary,
);

TextStyle amountBold() => customTextStyle(
  fontStyle: FontStyle.BodyL_Bold,
  color: FontColor.FontPrimary,
);

Widget sectionTitle(String text) {
  return Text(text, style: titleStyle());
}

// UI: Dispatch type selector (Normal / Driver / Rider)
// UI: Dispatch type selector (Normal / Driver / Rider)
Widget dispatchSelector({
  required String? value,
  required ValueChanged<String> onChanged,
  required String postcode,
  required String subgroupId,
  required String paymentMethod,
}) {
  final colors = customColors();
  final options = <Map<String, String>>[
    {'key': 'normal', 'label': 'Normal'},
  ];

  // Check if subgroup ID starts with 'EXP'
  if (subgroupId.startsWith('EXP') &&
      paymentMethod.toLowerCase() == 'cashondelivery') {
    // Add Rafeeq Driver for EXP subgroups
    options.add({'key': 'driver', 'label': 'Rafeeq Driver'});

    // Add Snoonu Rider option only for specific postcodes in EXP subgroups
    final postcodePrefix =
        postcode.isNotEmpty ? int.tryParse(postcode.substring(0, 2)) : null;
    if (postcodePrefix != null &&
        ((postcodePrefix >= 42 && postcodePrefix <= 46) ||
            postcodePrefix == 50 ||
            (postcodePrefix >= 56 && postcodePrefix <= 58))) {
      options.add({'key': 'rider', 'label': 'Snoonu Rider'});
    }
  }

  final Color selectedBg = switch (value) {
    'driver' => const Color(0xFF9729BA),
    'rider' => Colors.red,
    _ => customColors().islandAqua,
  };

  return Row(
    children: [
      Text('Dispatch Type', style: titleStyle()),
      const SizedBox(width: 8),
      Wrap(
        spacing: 8,
        alignment: WrapAlignment.end,
        children:
            options.map((o) {
              final key = o['key']!;
              final selected = value == key;

              // Pick selected background color by option
              final Color selectedBg = switch (key) {
                'driver' => HexColor('#9729BA'),
                'rider' => HexColor('#FF0000'),
                _ => customColors().islandAqua,
              };

              // Pick an icon per option
              IconData icon = switch (key) {
                'driver' => Icons.directions_car_filled_outlined,
                'rider' => Icons.pedal_bike_outlined,
                _ => Icons.local_shipping_outlined,
              };

              return ChoiceChip(
                // small, neat chips
                visualDensity: VisualDensity.comfortable,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: selected ? customColors().backgroundPrimary : null,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      o['label']!,
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyL_SemiBold,
                        color:
                            selected ? FontColor.White : FontColor.FontPrimary,
                      ),
                    ),
                  ],
                ),
                selected: selected,
                onSelected: (_) => onChanged(key),
                selectedColor: selectedBg,
                backgroundColor: selectedBg,
              );
            }).toList(),
      ),
    ],
  );
}

Widget getDriverTypeWidget(String driverType, String type) {
  switch (driverType) {
    case 'rafeeq':
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Image.asset('assets/rafeeq_logo.png', width: 24, height: 24),
            const SizedBox(width: 8),
            Text(
              type,
              style: customTextStyle(
                fontStyle: FontStyle.BodyL_SemiBold,
                color: FontColor.White,
              ),
            ),
          ],
        ),
      );
    case 'driver':
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Image.asset('assets/rafeeq_logo.png', width: 24, height: 24),
            const SizedBox(width: 8),
            Text(
              type,
              style: customTextStyle(
                fontStyle: FontStyle.BodyL_SemiBold,
                color: FontColor.White,
              ),
            ),
          ],
        ),
      );
    case 'rider':
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Image.asset('assets/snoonu_logo.png', width: 24, height: 24),
            const SizedBox(width: 8),
            Text(
              type,
              style: customTextStyle(
                fontStyle: FontStyle.BodyL_SemiBold,
                color: FontColor.White,
              ),
            ),
          ],
        ),
      );
    case 'snoonu':
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
        child: Row(
          children: [
            Image.asset('assets/snoonu_logo.png', height: 16),
            const SizedBox(width: 8),
            Text(
              type,
              style: customTextStyle(
                fontStyle: FontStyle.BodyL_SemiBold,
                color: FontColor.White,
              ),
            ),
          ],
        ),
      );
    default:
      return const Icon(Icons.local_shipping_outlined);
  }
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
  return userId.padRight(32, ' '); // Ensures exactly 32 bytes
}

Uint8List hexToBytes(String hex) {
  final result = Uint8List(hex.length ~/ 2);
  for (var i = 0; i < hex.length; i += 2) {
    final byte = int.parse(hex.substring(i, i + 2), radix: 16);
    result[i ~/ 2] = byte;
  }
  return result;
}

bool isValidHex(String hex) {
  final hexRegex = RegExp(r'^[0-9a-fA-F]+$');
  return hexRegex.hasMatch(hex);
}

String encryptStringForUser(String plainText, String key) {
  final keyBytes = crypto.Key.fromUtf8(
    key.padRight(32, ' '),
  ); // Ensure 32 bytes for AES-256
  final iv = crypto.IV.fromLength(16); // Random IV (Initialization Vector)
  final encrypter = crypto.Encrypter(
    crypto.AES(keyBytes, mode: crypto.AESMode.cbc, padding: 'PKCS7'),
  );

  final encrypted = encrypter.encrypt(plainText, iv: iv);

  // Combine IV and encrypted data, then convert to hex
  final combinedBytes = iv.bytes + encrypted.bytes;
  return combinedBytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
}

String decryptStringForUser(String encryptedHex, String key) {
  // Convert the hex-encoded string to bytes
  final encryptedBytes = hexToBytes(encryptedHex);

  // Ensure the encrypted data is a multiple of 16 bytes (AES block size)
  if (encryptedBytes.length % 16 != 0) {
    throw ArgumentError('Invalid encrypted data length');
  }

  // Extract the IV (first 16 bytes) and the encrypted data (remaining bytes)
  final iv = crypto.IV(Uint8List.fromList(encryptedBytes.sublist(0, 16)));
  final encryptedData = encryptedBytes.sublist(16);

  // Create the decrypter
  final keyBytes = crypto.Key.fromUtf8(
    key.padRight(32, ' '),
  ); // Ensure 32 bytes for AES-256
  final encrypter = crypto.Encrypter(
    crypto.AES(keyBytes, mode: crypto.AESMode.cbc, padding: 'PKCS7'),
  );

  // Decrypt the data
  final decrypted = encrypter.decrypt(
    crypto.Encrypted(Uint8List.fromList(encryptedData)),
    iv: iv,
  );

  return decrypted;
}

getdateformatted(DateTime dt) {
  var dateformat = DateFormat('MM-dd-yyyy');
  var formatted = dateformat.format(dt);
  return formatted;
}

getdateformattedrescheduled(DateTime dt) {
  var dateformat = DateFormat('yyyy-MM-dd');
  var formatted = dateformat.format(dt);
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
  String preparationId,
  OrderNew order,
  String suborderId,
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
      preparationId: preparationId,
      suborderId: suborderId,
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
      return customColors().red2;
  }
}

getItemStatus(String stat) {
  switch (stat) {
    case "canceled":
      return "Canceled";
    case "end_picking":
      return "End Picking";
    case "start_picking":
      return "Start Picking";
    case "item_not_available":
      return "Item Not Available";
    case "assigned_picker":
      return "Assigned Picker";
    case "assigned_driver":
      return "Assigned Driver";
    case "holded":
      return "Holded";
    case "material_request":
      return "Material Request";
    default:
      return "Ordered";
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

String getWeightFromBarcode(String orderprice, String scaleprice) {
  double orderprice1 = double.parse(orderprice);
  double scaleprice1 = double.parse(scaleprice);
  double weight = orderprice1 / scaleprice1;
  return weight.toStringAsFixed(3);
}

String getPriceFromBarcode(String code) {
  String last = code;
  String price = "00";

  // Check if code starts with '00'
  if (code.startsWith('00')) {
    last = code.substring(2);
  }

  // Convert to price value (divide by 1000)
  double parsedValue = double.parse(last) / 1000;

  // Format the price string
  String priceString = parsedValue.toString();
  int dotIndex = priceString.indexOf('.');

  if (dotIndex != -1 && dotIndex < priceString.length - 2) {
    // Decimal part is not zero - include up to two decimal places
    price = priceString.substring(0, dotIndex + 3);
  } else {
    // Decimal part is zero
    price = priceString;
  }

  return price;
}

String getLastSixDigits(String barcode) {
  if (barcode.length <= 6) {
    return barcode; // Return as-is if 6 or fewer characters
  }
  return barcode.substring(barcode.length - 6);
}

class ColorInfo {
  final String label;
  final String colorCode;

  ColorInfo(this.label, this.colorCode);

  @override
  String toString() => '$label ($colorCode)';
}

ColorInfo getColorInfo(String value) {
  switch (value) {
    // Neutral Colors
    case "917":
      return ColorInfo("Black", "#000000");
    case "918":
      return ColorInfo("Grey", "#808080");
    case "925":
      return ColorInfo("White", "#FFFFFF");
    case "947":
      return ColorInfo("Silver", "#C0C0C0");
    case "961":
      return ColorInfo("Dark Grey", "#5A5A5A");
    case "950":
      return ColorInfo("Light Grey", "#D3D3D3");

    // Warm Colors
    case "920":
      return ColorInfo("Brown", "#A52A2A");
    case "923":
      return ColorInfo("Beige", "#F5F5DC");
    case "921":
      return ColorInfo("Cream", "#FFFDD0");
    case "924":
      return ColorInfo("Red", "#FF0000");
    case "943":
      return ColorInfo("Maroon", "#800000");
    case "945":
      return ColorInfo("Orange", "#FFA500");
    case "922":
      return ColorInfo("Yellow", "#FFFF00");
    case "948":
      return ColorInfo("Olive", "#808000");
    case "952":
      return ColorInfo("Coffee", "#6F4E37");
    case "960":
      return ColorInfo("Bronze", "#CD7F32");
    case "958":
      return ColorInfo("Gold", "#FFD700");

    // Cool Colors
    case "926":
      return ColorInfo("Blue", "#0000FF");
    case "939":
      return ColorInfo("Light Blue", "#ADD8E6");
    case "940":
      return ColorInfo("Navy Blue", "#000080");
    case "944":
      return ColorInfo("Dark Blue", "#00008B");
    case "946":
      return ColorInfo("Sky Blue", "#87CEEB");
    case "991":
      return ColorInfo("Dark Grayish Blue", "#2F4F4F");

    // Greens
    case "927":
      return ColorInfo("Green", "#008000");
    case "949":
      return ColorInfo("Light Green", "#90EE90");
    case "951":
      return ColorInfo("Mint Green", "#98FF98");
    case "962":
      return ColorInfo("Dark Green", "#006400");

    // Purples & Pinks
    case "941":
      return ColorInfo("Purple", "#800080");
    case "931":
      return ColorInfo("Pink", "#FFC0CB");
    case "953":
      return ColorInfo("Rose Pink", "#FF66CC");
    case "956":
      return ColorInfo("Fuchsia", "#FF00FF");
    case "993":
      return ColorInfo("Light Grayish Violet", "#D8BFD8");

    // Others
    case "942":
      return ColorInfo("Graphite", "#383838");
    case "954":
      return ColorInfo("Light Black", "#404040");
    case "955":
      return ColorInfo("Dark Black", "#1A1A1A");
    case "957":
      return ColorInfo("Coral", "#FF7F50");
    case "959":
      return ColorInfo("Apricot", "#FBCEB1");
    case "963":
      return ColorInfo("Tan", "#D2B48C");
    case "992":
      return ColorInfo("Light Grayish Orange", "#F4A460");

    // Default (Unknown Color)
    default:
      return ColorInfo("Unknown Color", "#CCCCCC");
  }
}

class CarpetSizeInfo {
  final String label; // e.g., "60x90cm"
  final String value; // e.g., "856"

  CarpetSizeInfo(this.label, this.value);

  @override
  String toString() => '$label ($value)';
}

CarpetSizeInfo getCarpetSizeInfo(String value) {
  switch (value) {
    // Small/Standard Sizes
    case "820":
      return CarpetSizeInfo("50CM", "820");
    case "821":
      return CarpetSizeInfo("52CM", "821");
    case "822":
      return CarpetSizeInfo("54CM", "822");
    case "823":
      return CarpetSizeInfo("56CM", "823");
    case "824":
      return CarpetSizeInfo("58CM", "824");
    case "825":
      return CarpetSizeInfo("60CM", "825");
    case "826":
      return CarpetSizeInfo("62CM", "826");
    case "827":
      return CarpetSizeInfo("64CM", "827");
    case "828":
      return CarpetSizeInfo("66CM", "828");
    case "829":
      return CarpetSizeInfo("68CM", "829");
    case "830":
      return CarpetSizeInfo("70CM", "830");
    case "831":
      return CarpetSizeInfo("72CM", "831");
    case "832":
      return CarpetSizeInfo("74CM", "832");
    case "833":
      return CarpetSizeInfo("76CM", "833");
    case "834":
      return CarpetSizeInfo("78CM", "834");
    case "835":
      return CarpetSizeInfo("80CM", "835");
    case "836":
      return CarpetSizeInfo("82CM", "836");
    case "837":
      return CarpetSizeInfo("84CM", "837");
    case "838":
      return CarpetSizeInfo("86CM", "838");
    case "839":
      return CarpetSizeInfo("88CM", "839");
    case "840":
      return CarpetSizeInfo("90CM", "840");

    // Rectangular Sizes (cm)
    case "856":
      return CarpetSizeInfo("60x90cm", "856");
    case "857":
      return CarpetSizeInfo("80X150cm", "857");
    case "858":
      return CarpetSizeInfo("150X250cm", "858");
    case "859":
      return CarpetSizeInfo("250X350cm", "859");
    case "860":
      return CarpetSizeInfo("150X230cm", "860");
    case "861":
      return CarpetSizeInfo("150x225cm", "861");
    case "876":
      return CarpetSizeInfo("140x200cm", "876");
    case "877":
      return CarpetSizeInfo("100x150cm", "877");
    case "878":
      return CarpetSizeInfo("80x120cm", "878");
    case "879":
      return CarpetSizeInfo("240x350cm", "879");
    case "881":
      return CarpetSizeInfo("120x200", "881");
    case "882":
      return CarpetSizeInfo("150x200", "882");
    case "883":
      return CarpetSizeInfo("180x200", "883");
    case "884":
      return CarpetSizeInfo("150x190", "884");
    case "885":
      return CarpetSizeInfo("96X200cm", "885");
    case "886":
      return CarpetSizeInfo("77X150cm", "886");
    case "887":
      return CarpetSizeInfo("238X350cm", "887");
    case "888":
      return CarpetSizeInfo("194X300cm", "888");
    case "889":
      return CarpetSizeInfo("117X180cm", "889");
    case "890":
      return CarpetSizeInfo("150X220cm", "890");
    case "891":
      return CarpetSizeInfo("150X200cm", "891");
    case "892":
      return CarpetSizeInfo("50X70cm", "892");
    case "893":
      return CarpetSizeInfo("100x100cm", "893");
    case "894":
      return CarpetSizeInfo("75x75cm", "894");
    case "895":
      return CarpetSizeInfo("200X290cm", "895");
    case "896":
      return CarpetSizeInfo("120X170cm", "896");
    case "897":
      return CarpetSizeInfo("75X45cm", "897");
    case "898":
      return CarpetSizeInfo("45x75cm", "898");
    case "899":
      return CarpetSizeInfo("300x300cm", "899");
    case "900":
      return CarpetSizeInfo("292X400cm", "900");
    case "901":
      return CarpetSizeInfo("96X300cm", "901");
    case "902":
      return CarpetSizeInfo("400X400cm", "902");
    case "903":
      return CarpetSizeInfo("160X160cm", "903");
    case "911":
      return CarpetSizeInfo("75x150cm", "911");
    case "928":
      return CarpetSizeInfo("120x300cm", "928");
    case "929":
      return CarpetSizeInfo("120x400cm", "929");
    case "930":
      return CarpetSizeInfo("120x500cm", "930");
    case "932":
      return CarpetSizeInfo("120x120cm", "932");
    case "933":
      return CarpetSizeInfo("250x250cm", "933");
    case "969":
      return CarpetSizeInfo("45x90cm", "969");
    case "970":
      return CarpetSizeInfo("120x200cm", "970");

    // Large/Roll Sizes
    case "841":
      return CarpetSizeInfo("200x200cm", "841");
    case "842":
      return CarpetSizeInfo("150x150cm", "842");
    case "843":
      return CarpetSizeInfo("300x400cm", "843");
    case "844":
      return CarpetSizeInfo("240x330cm", "844");
    case "845":
      return CarpetSizeInfo("240X340cm", "845");
    case "846":
      return CarpetSizeInfo("200x300cm", "846");
    case "847":
      return CarpetSizeInfo("160x230cm", "847");
    case "848":
      return CarpetSizeInfo("120x180cm", "848");
    case "849":
      return CarpetSizeInfo("100x200cm", "849");
    case "850":
      return CarpetSizeInfo("400x600cm", "850");
    case "851":
      return CarpetSizeInfo("400x500cm", "851");
    case "852":
      return CarpetSizeInfo("300x500cm", "852");
    case "853":
      return CarpetSizeInfo("100x500cm", "853");
    case "854":
      return CarpetSizeInfo("100x400cm", "854");
    case "855":
      return CarpetSizeInfo("100x300cm", "855");
    case "862":
      return CarpetSizeInfo("0.5x0.8M", "862");
    case "863":
      return CarpetSizeInfo("1.5x1.5M", "863");
    case "864":
      return CarpetSizeInfo("1.5x2.25M", "864");
    case "865":
      return CarpetSizeInfo("1x2M", "865");
    case "866":
      return CarpetSizeInfo("1x3M", "866");
    case "867":
      return CarpetSizeInfo("1x4M", "867");
    case "868":
      return CarpetSizeInfo("1x5M", "868");
    case "869":
      return CarpetSizeInfo("2.5x3.5M", "869");
    case "870":
      return CarpetSizeInfo("2x2M", "870");
    case "871":
      return CarpetSizeInfo("2x3M", "871");
    case "872":
      return CarpetSizeInfo("3x4M", "872");
    case "873":
      return CarpetSizeInfo("4x5M", "873");
    case "874":
      return CarpetSizeInfo("4x6M", "874");
    case "875":
      return CarpetSizeInfo("3x5M", "875");
    case "880":
      return CarpetSizeInfo("90x90", "880");
    case "904":
      return CarpetSizeInfo("300x1000cm", "904");
    case "905":
      return CarpetSizeInfo("300x1200cm", "905");
    case "906":
      return CarpetSizeInfo("300x600cm", "906");
    case "907":
      return CarpetSizeInfo("300x800cm", "907");
    case "908":
      return CarpetSizeInfo("400x1000cm", "908");
    case "909":
      return CarpetSizeInfo("400x1200cm", "909");
    case "910":
      return CarpetSizeInfo("400x800cm", "910");
    case "934":
      return CarpetSizeInfo("300x1400cm", "934");
    case "935":
      return CarpetSizeInfo("300x1600cm", "935");
    case "936":
      return CarpetSizeInfo("300x1800cm", "936");
    case "937":
      return CarpetSizeInfo("300x2000cm", "937");

    // Default (Unknown Size)
    default:
      return CarpetSizeInfo("Unknown Size", value);
  }
}

Future<void> handlePermission(
  Permission permission,
  BuildContext context,
) async {
  try {
    // First check if we already have the permission
    var status = await permission.status;

    if (status.isGranted) {
      return; // Already granted
    }

    if (status.isPermanentlyDenied) {
      // Guide user to app settings
      _showPermissionSettingsDialog(permission, context);
      return;
    }

    // Request the permission
    status = await permission.request();

    if (!status.isGranted) {
      log('Permission ${permission.toString()} not granted: $status');
    }
  } catch (e, stackTrace) {
    log(
      'Error handling permission ${permission.toString()}: $e',
      stackTrace: stackTrace,
    );
    rethrow;
  }
}

void _showPermissionSettingsDialog(
  Permission permission,
  BuildContext context,
) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text('Permission required'),
          content: Text(
            '${permission.toString().split('.').last.replaceAll('_', ' ')} '
            'permission is permanently denied. Please enable it in app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: Text('Open Settings'),
            ),
          ],
        ),
  );
}

String normalizeSpecialBarcode(String barcode) {
  // Check if last digit is '1'
  if (!barcode.endsWith('1')) return barcode;

  // Get all digits except the last one
  String prefix = barcode.substring(0, barcode.length - 1);

  // Check if all remaining digits are '0'
  if (prefix.replaceAll('0', '').isEmpty) {
    // If all prefix digits are 0, replace last '1' with '0'
    return '${prefix}0';
  }

  // Check if only the first few digits are non-zero and rest are '0'
  // (e.g., '91160700000001')
  String nonZeroPrefix = prefix.replaceAll('0', '');
  if (nonZeroPrefix == prefix.substring(0, nonZeroPrefix.length)) {
    return '${prefix}0';
  }

  return barcode;
}

String replaceAfterFirstSixWithZero(String barcode) {
  if (barcode.isEmpty) return barcode; // Handle empty input

  // Take first 6 digits, pad the rest with zeros
  String firstSix = barcode.length >= 6 ? barcode.substring(0, 6) : barcode;
  String zeros =
      '0' * (barcode.length - firstSix.length).clamp(0, barcode.length);

  return firstSix + zeros;
}

Future<int> getAndroidSdkVersion() async {
  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;
  return androidInfo.version.sdkInt;
}

String formatDate(dynamic input, {String outputPattern = 'dd/MM/yyyy'}) {
  if (input == null) return '-';

  DateTime? dt;
  try {
    if (input is DateTime) {
      dt = input;
    } else if (input is int) {
      // epoch seconds vs milliseconds
      if (input > 1000000000000) {
        dt = DateTime.fromMillisecondsSinceEpoch(input);
      } else if (input > 1000000000) {
        dt = DateTime.fromMillisecondsSinceEpoch(input * 1000);
      } else {
        dt = DateTime.fromMillisecondsSinceEpoch(input);
      }
    } else if (input is String) {
      dt = DateTime.tryParse(input);
      if (dt == null) {
        for (final p in [
          'yyyy-MM-dd HH:mm:ss',
          'yyyy-MM-ddTHH:mm:ss',
          'yyyy-MM-dd',
          'MM/dd/yyyy',
          'dd/MM/yyyy',
        ]) {
          try {
            dt = DateFormat(p).parseStrict(input);
            if (dt != null) break;
          } catch (_) {}
        }
      }
    }
  } catch (_) {}

  if (dt == null) return input.toString();
  return DateFormat(outputPattern).format(dt);
}

Future<void> requestCameraPermission() async {
  var status = await Permission.camera.request();
  if (status.isDenied || status.isPermanentlyDenied) {
    openAppSettings();
  }
}

sholoadingIndicator(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "",
    pageBuilder: (context, animation, secondaryAnimation) {
      return Container();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      var curve = Curves.easeInOut.transform(animation.value);

      return Transform.scale(
        scale: curve,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 25.0, bottom: 25.0),
                child: Text(
                  "Fetching data....!",
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyL_Bold,
                    color: FontColor.FontPrimary,
                  ),
                ),
              ),
              Lottie.asset('assets/lottie_files/loading.json'),
            ],
          ),
        ),
      );
    },
  );
}

showPickConfirmDialogue(
  BuildContext context,
  String data,
  Function()? onTap,
  String sku,
  String price,
  String qty,
  String name,
  Function()? closeTap,
) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "",
    pageBuilder: (context, animation, secondaryAnimation) {
      return Container();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      var curve = Curves.easeInOut.transform(animation.value);

      return Transform.scale(
        scale: curve,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [InkWell(onTap: closeTap, child: Icon(Icons.close))],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25.0, bottom: 10.0),
                child: Text(
                  "${data}",
                  textAlign: TextAlign.center,
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyL_Bold,
                    color: FontColor.FontPrimary,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text(
                  "$name",
                  textAlign: TextAlign.center,
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyM_Bold,
                    color: FontColor.FontPrimary,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text(
                  "sku : $sku",
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyM_Bold,
                    color: FontColor.FontPrimary,
                  ),
                ),
              ),

              price != "0.00"
                  ? Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Text(
                      "Price : $price",
                      style: customTextStyle(
                        fontStyle: FontStyle.BodyM_Bold,
                        color: FontColor.FontPrimary,
                      ),
                    ),
                  )
                  : SizedBox(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: onTap,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        decoration: BoxDecoration(
                          color: customColors().secretGarden,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Center(
                          child: Text(
                            "Confirm Pick",
                            style: customTextStyle(
                              fontStyle: FontStyle.BodyM_Bold,
                              color: FontColor.White,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void priceMismatchDialog(
  BuildContext context, {
  required dynamic orderItem,
  required dynamic orderResponseItem,
}) {
  // BlocProvider.of<ItemReplacementPageCubit>(context);
  // print("orderItem");
  // print(jsonEncode(orderItem));
  // print("orderResponseItem");
  // print(jsonEncode(orderResponseItem));
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Dismiss",
    barrierColor: Colors.black54,
    transitionDuration: Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: Material(
          type: MaterialType.transparency,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Barcode Mismatched, are you replacing item?",
                  textAlign: TextAlign.center,
                  style: customTextStyle(
                    fontStyle: FontStyle.BodyL_Bold,
                    color: FontColor.FontPrimary,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                        },
                        child: Text(
                          "No",
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyM_Bold,
                            color: FontColor.White,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: customColors().secretGarden,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.gNavigationService
                              .openOrderItemReplacementPage(
                                context,
                                arg: {
                                  'item': orderItem,
                                  'order': orderResponseItem,
                                },
                              );
                        },
                        child: Text(
                          "Yes",
                          style: customTextStyle(
                            fontStyle: FontStyle.BodyM_Bold,
                            color: FontColor.White,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

String getFirstImage(String imagesString) {
  // Check if the string contains a comma
  if (imagesString.contains(',')) {
    // Split and get the first image
    List<String> imagesList =
        imagesString.split(',').map((img) => img.trim()).toList();
    return imagesList.isNotEmpty ? imagesList[0] : '';
  } else {
    // No comma, return the string directly
    return imagesString.trim();
  }
}

class BarcodeUtils {
  static const String _barcodeDataKey = 'barcode_data_list';

  static Future<void> addBarcodeData(String data, String orderid) async {
    final prefs = await SharedPreferences.getInstance();
    final currentList = await getBarcodeDataList(orderid);
    currentList.add(data);
    await prefs.setString(orderid, jsonEncode(currentList));
  }

  static Future<List<String>> getBarcodeDataList(String orderid) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(orderid);
    return jsonString != null ? List<String>.from(jsonDecode(jsonString)) : [];
  }

  static String generateBarcodeSvg(String data) {
    return Barcode.code128().toSvg(data, width: 300, height: 100);
  }
}

String getcurrencyfromurl(String url) {
  switch (url) {
    case 'https://uae.ahmarket.com/':
      return 'AED';
    case 'https://oman.ahmarket.com/':
      return 'OMR';
    case 'https://bahrain.ahmarket.com/':
      return 'BHD';
    default:
      return 'QAR';
  }
}
