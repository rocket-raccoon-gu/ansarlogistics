import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:ansarlogistics/constants/texts.dart';
// import 'package:ansarlogistics/localization/app_localizations.dart';
import 'package:ansarlogistics/themes/style.dart';
import 'package:ansarlogistics/user_controller/user_controller.dart';
import 'package:ansarlogistics/utils/preference_utils.dart';
import 'package:ansarlogistics/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:translator/translator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final translator = GoogleTranslator();

final arabicRegex = RegExp(r'[\u0600-\u06FF]');

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

String resolveImageUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  final p = path.trim();
  if (p.startsWith('http://') || p.startsWith('https://')) return p;
  // ensure single slash between base and path
  final base = mainimageurl; // assumed defined in constants/methods.dart
  if (p.startsWith('/')) {
    if (base.endsWith('/')) {
      return base.substring(0, base.length - 1) + p;
    }
    return base + p;
  } else {
    if (base.endsWith('/')) {
      return base + p;
    }
    return '$base/$p';
  }
}

String getStatus(String? stat) {
  if (stat == null) return "";
  switch (stat) {
    case "pending_payment":
      return "Pending Payment";
    case "processing":
      return "Processing";
    case "end_picking":
      return "End Picking";
    case "pending":
      return "Pending";
    case "complete":
      return "Delivered";
    case "start_picking":
      return "Start Picking";
    case "holded":
      return "On Hold";
    case "on_the_way":
      return "On The Way";
    case "payment_captured":
      return "Payment Captured";
    case "cancel_request":
      return "Cancel Request";
    case "assigned_picker":
      return "Assigned Picker";
    case "closed":
      return "Closed";
    case "payment_failed":
      return "Payment Failed";
    case "sfo_order":
      return "SFO Order";
    case "canceled":
      return "Canceled";
    case "canceled_by_team":
      return "Canceled By Team";
    case "rescheduled":
      return "Rescheduled";
    case "material_request":
      return "Material Request";
    case "assigned_driver":
      return "Assigned Driver";
    case "customer_not_answer":
      return "Customer Not Answer";
    case "cancel_request":
      return "Cancel Request";
    case "ready_to_dispatch":
      return "Ready To Dispatch";
    default:
      return "";
  }
}

Color getOrderWidgetColor(String status) {
  switch (status) {
    case "pending_payment":
      return customColors().mattPurple;
    case "processing":
      return customColors().secretGarden;
    case "end_picking":
      return customColors().islandAqua;
    case "pending":
      return yellow500;
    case "complete":
      return customColors().danger;
    case "start_picking":
      return customColors().info;
    case "holded":
      return customColors().ultraviolet;
    case "on_the_way":
      return customColors().green1;
    case "payment_captured":
      return customColors().dodgerBlue;
    case "assigned":
      return customColors().green3;
    case "cancel_request":
      return customColors().red1;
    case "assigned_picker":
      return customColors().green3;
    case "assigned_driver":
      return customColors().green600;
    case "closed":
      return customColors().grey;
    case "payment_failed":
      return customColors().red2;
    case "sfo_order":
      return customColors().pTokenBackground;
    case "canceled":
      return customColors().red3;
    case "canceled_by_team":
      return Colors.red;
    case "refund_request":
      return HexColor("#5189ad");
    case "partial_refund":
      return HexColor("#e8fc05");
    case "rescheduled":
      return HexColor("#134569");
    case "material_request":
      return HexColor('#5e0e9f');
    case "order_collected":
      return HexColor('#7b98c9');
    default:
      return customColors().accent;
  }
}

// getTranslate(BuildContext context, String key) {
//   if (arabicRegex.hasMatch(key.toString())) {
//     getTranslateWord(key);
//   } else {
//     return AppLocalizations.of(context)!.translate(key);
//   }
// }

Future<String?> getTranslateto(String keyword) async {
  try {
    // Regular expression to check for Arabic characters

    String? langval = await PreferenceUtils.getDataFromShared('language');

    var translatedText;

    if (langval == 'en' || langval == null) {
      // Translate from Arabic to English
      translatedText = await translator.translate(keyword, to: 'en');
    } else {
      // Translate from English to Arabic
      translatedText = await translator.translate(keyword, to: 'ar');
    }

    log("Original: $keyword | Translated: $translatedText");
    return translatedText.toString();
  } catch (e) {
    log("Translation Error: $e");
    return null;
  }
}

Future<String> getTranslateWord(String keyword) async {
  // Regular expression to check if the string contains Arabic characters

  if (arabicRegex.hasMatch(keyword)) {
    var translation = await translator.translate(keyword, to: 'en');
    log("-------------------------------------------");
    log(translation.toString());

    return translation.toString();
  } else {
    return keyword;
  }
}

String getTranslateWord11(String keyword) {
  // Regular expression to check if the string contains Arabic characters
  final arabicRegex = RegExp(r'[\u0600-\u06FF]');

  if (arabicRegex.hasMatch(keyword)) {
    // Return the translation promise directly
    return translator.translate(keyword, to: 'en').toString();
  } else {
    return keyword;
  }
}

getFormatedDate(String _date) {
  var inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  var date1 = inputFormat.parse(_date);

  var outputFormat = DateFormat('dd/MM/yyyy');
  var date2 = outputFormat.format(date1);

  return date2.toString();
}

Color getTypeColor(String type) {
  switch (type) {
    case "EXP":
      return HexColor('#FF6E40');
    case "NOL":
      return HexColor('#ffc160');
    case "VPO":
      return HexColor('#f64e4b');
    case "SUP":
      return HexColor('#20c9a6');
    case "CAK":
      return HexColor('#ff4081');
    case "WAR":
      return HexColor('#ff4081');
    case "ABY":
      return HexColor('#04a6c7');

    default:
      return customColors().fontPrimary;
  }
}

// Reference to the specific Firestore document
final DocumentReference documentReference = FirebaseFirestore.instance
    .collection('base_path')
    .doc('7F32CBHMHACadSeNRWsY');

// Function to fetch data from the Firestore document
Future<Map<String, dynamic>> getData() async {
  try {
    DocumentSnapshot snapshot = await documentReference.get();
    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    } else {
      throw Exception('Document does not exist');
    }
  } catch (e) {
    log(e.toString());
    throw Exception('Document does not exist');
  }
}

Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
      return customColors().secretGarden;
    case 'canceled':
      return customColors().carnationRed;
    case 'assigned':
      return customColors().green2;
    case 'on_the_way':
      return customColors().green4;
    case 'delivered':
      return customColors().secretGarden;
    case 'assigned_picker':
      return customColors().green2;
    case 'assigned_driver':
      return customColors().green2;
    case 'start_picking':
      return customColors().dodgerBlue;
    case 'end_picking':
      return customColors().mattPurple;
    case 'start_delivery':
      return customColors().green2;
    case 'end_delivery':
      return customColors().green2;
    case 'itemnotavailable':
      return const Color.fromARGB(255, 243, 18, 18);
    case 'customer_not_answering':
      return const Color.fromARGB(255, 243, 18, 18);
    case 'material_request':
      return customColors().ultraviolet;
    case 'customer_not_answer':
      return const Color.fromARGB(255, 243, 18, 18);
    case 'cancel_request':
      return const Color.fromARGB(255, 243, 18, 18);
    case 'ready_to_dispatch':
      return customColors().green2;
    default:
      return const Color.fromARGB(255, 243, 18, 18);
  }
}

String getcatecoryname(String id) {
  switch (id) {
    case "3":
      return "Grocery";
    case "8":
      return "Fruits & Vegetables";
    case "10":
      return "Vegetables";
    case "9":
      return "Fruits";
    case "11":
      return "Herbs";
    case "744":
      return "Cut Fruits & Salads";
    case "17":
      return "Fresh Chicken & Meat";
    case "18":
      return "Fresh Chicken";
    case "19":
      return "Beef";
    case "20":
      return "Mutton";
    case "22":
      return "Lamb";
    case "21":
      return "Camel";
    case "761":
      return "Fish & Sea Food";
    case "762":
    case "764":
    case "763":
      return "Fish";
    case "239":
    case "242":
      return "Dairy - Egg & Cheese";
    case "243":
    case "745":
      return "Milk & Flavored Milk";
    case "241":
    case "932":
    case "933":
    case "934":
      return "Yoghurt";
    case "781":
    case "793":
    case "41":
    case "782":
    case "747":
    case "944":
      return "Delicatessen";
    case "945":
      return "Flavoured Laban";
    case "246":
    case "941":
    case "942":
    case "943":
      return "Cream";
    case "240":
    case "947":
      return "Desserts";
    case "23":
    case "24":
    case "1055":
    case "1056":
    case "29":
    case "1057":
    case "1058":
    case "1059":
    case "1060":
    case "1061":
      return "Beverages";
    case "26":
    case "27":
    case "1062":
    case "1063":
    case "28":
    case "1064":
    case "1065":
    case "30":
    case "1067":
    case "1068":
    case "1054":
    case "1066":
    case "794":
    case "1069":
    case "1070":
    case "1071":
    case "1072":
    case "1073":
      return "Fresh Juice";
    case "46":
    case "47":
    case "1233":
    case "1234":
    case "1235":
    case "1236":
    case "1237":
    case "49":
    case "1238":
    case "1239":
    case "1281":
    case "1282":
    case "751":
    case "1283":
    case "1285":
    case "1286":
    case "1287":
    case "1288":
    case "1289":
    case "1290":
    case "48":
    case "1291":
    case "830":
    case "739":
    case "1292":
    case "1284":
      return "Bakery";
    case "50":
    case "51":
    case "1074":
    case "1075":
    case "1076":
    case "1077":
    case "53":
    case "1088":
    case "1089":
    case "1090":
    case "1091":
    case "1092":
    case "1093":
    case "54":
    case "52":
    case "1082":
    case "1083":
    case "1084":
    case "55":
    case "1078":
    case "1079":
    case "1080":
    case "1081":
    case "56":
    case "1085":
    case "1086":
    case "1087":
      return "Snacks & Candy";
    case "1094":
    case "16":
    case "15":
      return "Seeds & Nuts";
    case "14":
      return "Dry Fruits";
    case "65":
    case "67":
    case "1165":
    case "1166":
    case "1168":
    case "69":
    case "1169":
    case "1170":
    case "1171":
    case "753":
    case "1173":
    case "1174":
    case "66":
    case "1200":
    case "1201":
    case "1202":
    case "1203":
    case "1204":
    case "70":
    case "1175":
    case "1176":
    case "1177":
    case "1178":
    case "1179":
    case "1167":
    case "1180":
    case "1181":
    case "1182":
    case "1183":
    case "1186":
    case "1187":
      return "Frozen Food";
    case "68":
    case "1184":
    case "1185":
      return "Bakery & Desserts";
    case "62":
    case "63":
    case "64":
    case "752":
      return "Ice Cream";
    case "42":
    case "43":
    case "968":
    case "969":
    case "970":
    case "971":
    case "972":
    case "973":
    case "44":
    case "45":
    case "974":
    case "975":
    case "976":
    case "977":
    case "978":
      return "Breakfast Food";
    case "765":
    case "797":
    case "1050":
    case "1051":
    case "1052":
    case "1053":
    case "766":
    case "1044":
    case "1045":
    case "1046":
    case "1047":
    case "1048":
    case "1049":
      return "Coffee - Tea & Sugar";
    case "767":
      return "Creamers";
    case "32":
    case "995":
    case "996":
    case "997":
    case "998":
    case "1299":
      return "Rice";
    case "35":
    case "1009":
    case "1010":
    case "1011":
    case "1012":
    case "1013":
    case "1014":
    case "1015":
    case "1016":
    case "1017":
      return "Pulses & Grains";
    case "37":
    case "999":
    case "1000":
    case "1001":
    case "1002":
    case "1003":
      return "Pastas";
    case "749":
    case "1004":
    case "1005":
    case "1006":
    case "1007":
    case "1008":
      return "Noodles & Soups";
    case "748":
    case "768":
    case "1018":
    case "1019":
    case "1020":
    case "1021":
    case "33":
    case "988":
    case "989":
    case "990":
    case "991":
    case "992":
    case "993":
    case "994":
    case "799":
    case "36":
    case "750":
    case "979":
    case "980":
    case "981":
    case "982":
    case "983":
    case "984":
    case "985":
    case "986":
    case "987":
      return "Cooking & Baking";
    case "31":
      return "Condiments & Seasoning";
    case "38":
    case "1095":
    case "1096":
    case "1097":
    case "1098":
    case "1099":
    case "1100":
      return "Salt & Spices";
    case "39":
    case "1101":
    case "1102":
    case "1103":
    case "1104":
    case "1105":
    case "1106":
    case "1107":
    case "1108":
    case "1109":
    case "1110":
    case "1111":
    case "1112":
    case "1113":
    case "1114":
    case "1115":
      return "Sauces & Dressings";
    case "34":
      return "Herbs & Seasonings";
    case "40":
      return "Vinegar & Concentrates";
    case "57":
    case "58":
    case "1149":
    case "60":
    case "1159":
    case "1160":
    case "1161":
    case "59":
    case "1162":
    case "1164":
    case "1163":
    case "1150":
    case "1151":
    case "1152":
    case "1153":
    case "1154":
    case "1155":
    case "1156":
    case "1157":
    case "1158":
      return "Canned & Jarred Food";
    case "61":
      return "Ready-to-Eat Canned Meals";
    case "772":
    case "778":
    case "774":
    case "779":
    case "777":
    case "776":
    case "773":
    case "780":
    case "775":
      return "International Food";
    case "71":
    case "73":
    case "1022":
    case "1023":
    case "1024":
    case "1025":
    case "1026":
    case "1205":
    case "74":
    case "1035":
    case "1036":
    case "1037":
    case "72":
    case "1027":
    case "1028":
    case "1029":
    case "1030":
    case "1031":
    case "1032":
    case "1033":
    case "1034":
    case "76":
      return "Cleaning & Laundry";
    case "75":
    case "1038":
    case "1039":
    case "1040":
    case "1041":
    case "1042":
      return "Air Fresheners";
    case "754":
    case "1263":
    case "1264":
    case "1265":
    case "1266":
      return "Cleaning Tools";
    case "800":
    case "1298":
      return "Insects & Pest Control";
    case "78":
    case "82":
    case "1127":
    case "1128":
    case "1129":
    case "1130":
      return "Disposable & Storage";
    case "77":
    case "1143":
    case "1144":
    case "1145":
    case "1146":
      return "Sponges & Gloves";
    case "80":
    case "1135":
    case "1136":
    case "1137":
    case "1138":
    case "1139":
      return "Food Storage & Wraps";
    case "81":
    case "1140":
    case "1141":
    case "1142":
      return "Trash Bags";
    case "96":
      return "Disposable Tableware";
    case "36735":
      return "Foil & Cling Film";
    case "120":
      return "Pet Food & Care";
    case "122":
      return "Cat Food";
    case "36737":
      return "Dog Food";
    case "36740":
      return "Pet Litter";
    case "121":
      return "Bird Food";
    case "36739":
      return "Pet Accessories & Toys";
    case "36738":
      return "Fish Food";
    case "36779":
      return "Other Pet Food";
    case "36719":
      return "Celebrations & Occasions";
    case "36750":
      return "Chocolate Baskets";
    case "36752":
      return "Special Cakes";
    case "36751":
      return "Flowers";
    case "36765":
      return "Healthy & Organic Foods";
    case "36772":
      return "Organic Fruits & Vegetables";
    case "36768":
      return "Organic Beverages";
    case "36769":
      return "Organic Condiments";
    case "36770":
      return "Organic Food";
    case "36774":
      return "Sugar Free Food & Snacks";
    case "36773":
      return "Special Diet";
    case "36767":
      return "Healthy & Protein Snacks";
    case "36766":
      return "Gluten Free Food & Snacks";
    case "124":
      return "Grab & Go";
    case "100":
      return "Health & Wellness";
    case "103":
      return "Vitamins & Supplements";
    case "104":
      return "Medications & First Aid";
    case "102":
      return "Pain Relief";
    case "105":
      return "Adult Care";
    case "101":
      return "Sanitizers & Masks";
    case "36736":
      return "Health & Fitness Devices";
    case "4":
      return "Mobile Phones";
    case "125":
      return "Smartphones";
    case "126":
      return "Apple iPhone";
    case "127":
      return "Samsung Phones";
    case "33948":
      return "Xiaomi Phones";
    case "128":
      return "Vivo Phones";
    case "130":
      return "Lenovo Phones";
    case "131":
      return "Oppo Phones";
    case "132":
      return "Nokia Phones";
    case "133":
      return "Motorola Phones";
    case "134":
      return "Huawei Phones";
    case "135":
      return "Honor Phones";
    case "36694":
      return "Realme Phones";
    case "36695":
      return "OnePlus Phones";
    case "36696":
      return "Lava Phones";
    case "36697":
      return "Poco Phones";
    case "136":
      return "Other Smartphones";
    case "137":
      return "Feature Phones";
    case "138":
      return "Nokia Feature Phones";
    case "139":
      return "Samsung Feature Phones";
    case "140":
      return "Other Feature Phones";
    case "36663":
      return "Landline Phones";
    case "141":
      return "Smart Wearables";
    case "142":
      return "Smart Watches";
    case "143":
      return "Smart Bands";
    case "144":
      return "Smart Watch & Bands Accessories";
    case "145":
      return "Mobile Accessories";
    case "36698":
      return "Cases & Covers";
    case "147":
      return "Chargers & Cables";
    case "36699":
      return "Screen Protectors";
    case "36685":
      return "Phone Stands & Holders";
    case "150":
      return "Storage Cards";
    case "151":
      return "Mobile Phones";
    case "5":
      return "Electronics";
    case "152":
      return "Computers";
    case "153":
      return "Tablets";
    case "154":
      return "Laptops & PC";
    case "155":
      return "Printers & Scanners";
    case "160":
      return "Mouse & Keyboard";
    case "156":
      return "Monitors & Projectors";
    case "157":
      return "Router & Range Extender";
    case "158":
      return "Cartridge & Ink";
    case "159":
      return "Cables & IT Accessories";
    case "164":
      return "Web Camera";
    case "161":
      return "External Storage";
    case "162":
      return "Cooling Pad";
    case "163":
      return "Laptop Bags";
    case "36788":
      return "Cables";
    case "165":
      return "TV";
    case "166":
      return "Samsung TV";
    case "167":
      return "Geepas TV";
    case "168":
      return "TCL TV";
    case "169":
      return "Skyworth TV";
    case "170":
      return "Sony TV";
    case "171":
      return "Nikai TV";
    case "172":
      return "Oscar TV";
    case "173":
      return "LG TV";
    case "36682":
      return "Sharp TV";
    case "36683":
      return "Toshiba TV";
    case "174":
      return "Other TV";
    case "175":
      return "TV Accessories";
    case "176":
      return "Cameras";
    case "177":
      return "DSLR Cameras";
    case "178":
      return "Digital Cameras";
    case "179":
      return "Action Cameras";
    case "180":
      return "Camera Accessories";
    case "181":
      return "Audio";
    case "182":
      return "Headphones & Earbuds";
    case "183":
      return "Soundbars & Home Theaters";
    case "184":
      return "Bluetooth Speakers";
    case "185":
      return "Radio";
    case "186":
      return "Other Audio";
    case "188":
      return "Personal Grooming";
    case "36677":
      return "Shavers";
    case "36678":
      return "Clippers";
    case "36679":
      return "Groomers";
    case "36680":
      return "Hair Laser & Epilators";
    case "36681":
      return "Trimmers";
    case "189":
      return "Hair Dryers & Stylers";
    case "191":
      return "Gaming";
    case "192":
      return "Gaming Consoles";
    case "193":
      return "Gaming Accessories";
    case "194":
      return "Games";
    case "195":
      return "Home Appliances";
    case "196":
      return "Air Conditioners";
    case "197":
      return "Washing Machines & Dryers";
    case "198":
      return "Vacuum Cleaners";
    case "199":
      return "Pressure Washers";
    case "200":
      return "Sewing Machines";
    case "201":
      return "Irons & Garment Steamers";
    case "202":
      return "Heaters";
    case "203":
      return "Air Purifiers";
    case "204":
      return "Fans & Coolers";
    case "205":
      return "Lanterns & Flashlights";
    case "206":
      return "Kitchen Appliances";
    case "207":
      return "Refrigerators";
    case "208":
      return "Cooking Range";
    case "209":
      return "Cooking Hoods";
    case "210":
      return "Cooking Hobs";
    case "211":
      return "Blenders & Mixers";
    case "219":
      return "Healthy Fryers & Steamers";
    case "212":
      return "Rice Cookers";
    case "213":
      return "Microwave Ovens";
    case "214":
      return "Electric Grills";
    case "215":
      return "Coffee Makers";
    case "216":
      return "Food Processors";
    case "217":
      return "Electric Kettles";
    case "218":
      return "Toasters";
    case "220":
      return "Water Dispensers";
    case "221":
      return "Dishwashers";
    case "222":
      return "Other Kitchen Appliances";
    case "223":
      return "Plugs & Extensions";
    case "224":
      return "Batteries-Power";
    case "148":
      return "Power Banks";
    case "36793":
      return "Batteries & Chargers";
    case "35731":
      return "Household";
    case "35732":
      return "Home Linen";
    case "36600":
      return "Bathroom";
    case "36552":
      return "Towels";
    case "36660":
      return "Bath Mat";
    case "36661":
      return "Door Mat";
    case "36662":
      return "Shower Curtains";
    case "36630":
      return "Bedding";
    case "36646":
      return "Bed Sheet";
    case "36647":
      return "Fitted Sheet";
    case "36648":
      return "Quilt Cover";
    case "36649":
      return "Sofa Cover";
    case "36650":
      return "Cushion";
    case "36651":
      return "Cushion Cover";
    case "36652":
      return "Pillow";
    case "36653":
      return "Neck Pillow";
    case "36654":
      return "Pillow Cover";
    case "36655":
      return "Mattress";
    case "36656":
      return "Prayer Mat";
    case "36657":
      return "Picnic Mat";
    case "36658":
      return "Bed Cover";
    case "36659":
      return "Duvet";
    case "36631":
      return "Blanket";
    case "36641":
      return "Standard Blanket";
    case "36642":
      return "Fleece Blanket";
    case "36632":
      return "Comforter";
    case "36636":
      return "Table Cloth";
    case "36637":
      return "Place Mat";
    case "36638":
      return "Table Mat";
    case "36639":
      return "Hanging Quran";
    case "36629":
      return "Kitchen Table Mat";
    case "36644":
      return "Napkin";
    case "35733":
      return "Kitchen & Dining";
    case "36070":
      return "Storages & Organizers";
    case "36071":
      return "Cookware";
    case "36072":
      return "Pans";
    case "36073":
      return "Pots";
    case "36074":
      return "Kettles";
    case "36075":
      return "Pressure Cookers";
    case "36676":
      return "Large Size Cookwares";
    case "36076":
      return "Dinnerwares & Servewares";
    case "36077":
      return "Cutlery";
    case "36078":
      return "Utensils & Gadgets";
    case "36079":
      return "Glasswares & Drinkwares";
    case "36693":
      return "Kitchen & Dining Accessories";
    case "35734":
      return "Bath & Laundry";
    case "36084":
      return "Laundry Accessories";
    case "36085":
      return "Iron Boards";
    case "36086":
      return "Hangers";
    case "36180":
      return "Trash Cans";
    case "35735":
      return "Household";
    case "6":
      return "Home Essentials";
    case "489":
      return "Beauty & Care";
    case "396":
      return "Cosmetics ";
    case "397":
      return "Lip Liners & Lipsticks";
    case "398":
      return "Mascara";
    case "399":
      return "Foundation";
    case "400":
      return "Eyeshadows";
    case "401":
      return "Blushes";
    case "402":
      return "Nail Polish";
    case "403":
      return "Makeup Kit";
    case "404":
      return "Makeup Removers";
    case "405":
      return "Makeup Brushes";
    case "406":
      return "Cosmetics Accessories";
    case "407":
      return "Concealers & Correctors";
    case "408":
      return "Eyeliners";
    case "409":
      return "Eyebrow Pencil & Powder";
    case "389":
      return "Perfumes & Fragrances";
    case "390":
      return "Men Perfumes";
    case "391":
      return "Women Perfumes";
    case "36780":
      return "Unisex Perfumes";
    case "392":
      return "Arabic Perfumes & Fragrances";
    case "393":
      return "Perfumes & Fragrances Gift Sets";
    case "394":
      return "Men Gift Set";
    case "395":
      return "Women Gift Set";
    case "106":
      return "Personal Care";
    case "107":
      return "Hair Care";
    case "108":
      return "Bath & Body Care";
    case "110":
      return "Skin Care";
    case "111":
      return "Oral Care";
    case "112":
      return "Shaving & Hair Removal";
    case "113":
      return "Feminine Care";
    case "114":
      return "Deodorants & Anti-Perspirant";
    case "115":
      return "Personal Care Tools";
    //need to change
    //
    case "7":
      return "Sports & Fitness";
    case "8":
      return "Gift & Bundle Offers";
    // need to change
    //
    case "9":
      return "Fashion";
    case "35560":
      return "Men";
    case "286":
      return "Men Clothing";
    case "287":
      return "Men Top Wear";
    case "35541":
      return "Men Shirts";
    case "35542":
      return "Men T-Shirts & Polos";
    case "35543":
      return "Jackets & Coats";
    case "35544":
      return "Men Sweater & Hoodies";
    case "292":
      return "Men Bottom Wear";
    case "35548":
      return "Men Pants";
    case "294":
      return "Men Jeans";
    case "35547":
      return "Men Shorts";
    case "35549":
      return "Men Ethnic Wear";
    case "297":
      return "Men Suit";
    case "35550":
      return "Men Blazer";
    case "35551":
      return "Men Innerwear";
    case "35552":
      return "Men Briefs";
    case "35553":
      return "Men Vests & Under Shirts";
    case "35554":
      return "Men Socks";
    case "35555":
      return "Men Thermal Innerwear";
    case "35556":
      return "Men Sportswear";
    case "35557":
      return "Men Tracksuits";
    case "35558":
      return "Men Sports Shirts";
    case "35559":
      return "Men Track Pant";
    case "35561":
      return "Men Shoes";
    case "35564":
      return "Men Formal Shoes";
    case "35565":
      return "Men Sports Shoes";
    case "35566":
      return "Men Sandals";
    case "35567":
      return "Men Slippers";
    case "35568":
      return "Men Casuals";
    case "35569":
      return "Men Shoe Accessories";
    case "35562":
      return "Men Eyewear";
    case "35570":
      return "Men Sunglasses";
    case "35571":
      return "Men Frames";
    case "35572":
      return "Men Eyewear Accessories";
    case "35563":
      return "Men Watches";
    case "35573":
      return "Men Formal Watches";
    case "35574":
      return "Men Sports Watches";
    case "35575":
      return "Men Watch Accessories";
    case "302":
      return "Men Accessories";
    case "35576":
      return "Men Bow & Tie";
    case "35577":
      return "Men Caps & Hats";
    case "35578":
      return "Men Wallets";
    case "35579":
      return "Men Belts";
    case "307":
      return "Other Men Accessories";
    case "35580":
      return "Women";
    case "35584":
      return "Women Clothing";
    case "35593":
      return "Women Top Wear";
    case "35623":
      return "Tops & Blouses";
    case "35624":
      return "Women T-Shirts & Polos";
    case "35625":
      return "Long Dresses";
    case "35626":
      return "Women Jackets";
    case "35627":
      return "Women Sweaters Hoodies";
    case "35594":
      return "Women Bottom Wear";
    case "35628":
      return "Women Pants";
    case "35629":
      return "Women Jeans";
    case "35630":
      return "Leggings";
    case "312":
      return "Abayas";
    case "36711":
      return "Women 2 Pieces Set";
    case "35595":
      return "Lingerie";
    case "35631":
    case "35632":
      return "Panties";
    case "35633":
      return "Full Sets";
    case "35634":
      return "Vests & Under Shirts";
    case "35635":
      return "Socks";
    case "35596":
      return "Nightwear";
    case "35636":
      return "Pajama Set";
    case "35637":
      return "Women Night Dresses";
    case "35597":
      return "Women Sportswear";
    case "35638":
      return "Women Track Suits";
    case "35639":
      return "Women Track Pants";
    case "35598":
      return "Maternity Clothes";
    case "35599":
      return "Women Party Wear";
    case "35600":
      return "Women Ethnic Wear";
    case "35601":
      return "Uniforms";
    case "35585":
      return "Women Shoes";
    case "35602":
      return "Women Formal Shoes";
    case "35603":
      return "Women Sports Shoes";
    case "35604":
      return "Women Sandals";
    case "35640":
      return "High Heel Sandals";
    case "35641":
      return "Flat Sandals";
    case "35642":
      return "Mid Heel Sandals";
    case "35643":
      return "Wedge Sandals";
    case "35644":
      return "Slides";
    case "36511":
      return "Women Slippers";
    case "35605":
      return "Women Slippers";
    case "35606":
      return "Women Casuals";
    case "35607":
      return "Women Footwear Accessories";
    case "35586":
      return "Women Eyewear";
    case "35608":
      return "Women Sunglasses";
    case "35609":
      return "Women Eyewear Frames";
    case "35610":
      return "Women Eyewear Accessories";
    case "35587":
      return "Women Watches";
    case "35611":
      return "Women Formal Watches";
    case "35612":
      return "Women Sports Watches";
    case "35613":
      return "Women Watch Accessories";
    case "35588":
      return "Women Accessories";
    case "35614":
      return "Women Caps";
    case "35615":
      return "Women Belts";
    case "35616":
      return "Other Women Accessories";
    case "35589":
      return "Women Bags";
    case "35617":
      return "Hand Bags";
    case "35618":
      return "Wallets";
    case "35619":
      return "Tote Bags";
    case "35620":
      return "Cross Bags";
    case "35621":
      return "Shoulder Bags";
    case "35622":
      return "Clutches";
    case "35590":
      return "Jewellery";
    case "35646":
      return "Boys";
    case "35648":
      return "Boys Clothing";
    case "35653":
      return "Boys Top Wear";
    case "35669":
      return "Boys Shirts";
    case "35670":
      return "Boys T-Shirts & Polos";
    case "35671":
      return "Boys Jackets";
    case "35672":
      return "Boys Sweaters";
    case "35654":
      return "Boys Bottom Wear";
    case "35673":
      return "Boys Pants";
    case "35674":
      return "Boys Jeans";
    case "35675":
      return "Boys Shorts";
    case "35655":
      return "Boys Innerwear";
    case "35676":
      return "Boys Briefs";
    case "35677":
      return "Boys Vests & Undershirts";
    case "35678":
      return "Boys Socks";
    case "35656":
      return "Boys Sportswear";
    case "35679":
      return "Boys Sports Shirts";
    case "35680":
      return "Boys Track Suits";
    case "35649":
      return "Boys Shoes";
    case "35657":
      return "Boys Formal Shoes";
    case "35658":
      return "Boys Sports Shoes";
    case "35659":
      return "Boys Sandals";
    case "35660":
      return "Boys Slippers";
    case "35661":
      return "Boys Casual Shoes";
    case "35662":
      return "Boys Shoe Accessories";
    case "35650":
      return "Boys Eyewear";
    case "35663":
      return "Boys Sunglasses";
    case "35664":
      return "Boys Eyewear Frames";
    case "35665":
      return "Boys Eyewear Accessories";
    case "35651":
      return "Boys Watches";
    case "35652":
      return "Boys Fashion Accessories";
    case "35666":
      return "Boys Belts";
    case "35667":
      return "Boys Caps & Hats";
    case "35668":
      return "Boys Other Accessories";
    case "35647":
    case "35681":
      return "Girls Clothing";
    case "35686":
      return "Girls Top Wear";
    case "35704":
      return "Tops & Blouses";
    case "35705":
      return "Girls T-Shirts";
    case "35706":
      return "Girls Long Dresses";
    case "35707":
      return "Girls Jackets";
    case "35708":
      return "Girls Sweater";
    case "35687":
      return "Girls Bottom Wear";
    case "35709":
      return "Girls Pants";
    case "35710":
      return "Girls Jeans";
    case "35711":
      return "Girls Leggings";
    case "35688":
      return "Girls Innerwear";
    case "35712":
    case "35713":
      return "Panties";
    case "35714":
      return "Girls Vests & Under Shirts";
    case "36692":
      return "Girls Socks";
    case "35689":
      return "Girls Nightwear";
    case "35716":
      return "Girls Pajama Set";
    case "35717":
      return "Girls Night Dresses";
    case "35690":
      return "Girls Sportswear";
    case "35718":
      return "Girls Sports T-Shirts";
    case "35719":
      return "Girls Tracksuit";
    case "35682":
      return "Girls Shoes";
    case "35691":
      return "Girls Formal Shoes";
    case "35692":
      return "Girls Flat Shoes";
    case "35693":
      return "Girls Sports Shoes";
    case "35694":
      return "Girls Sandals";
    case "35695":
      return "Girls Slippers";
    case "35696":
      return "Girls Shoe Accessories";
    case "35683":
      return "Girls Eyewear";
    case "35697":
      return "Girls Sunglasses";
    case "35698":
      return "Girls Frames";
    case "35699":
      return "Girls Eyewear Accessories";
    case "35684":
      return "Girls Watches";
    case "35685":
      return "Girls Fashion Accessories";
    case "35700":
      return "Girls Bags";
    case "35701":
      return "Girls Caps & Hats";
    case "35702":
      return "Girls Belts";
    case "35703":
      return "Girls Other Accessories";
    case "36716":
      return "Tailoring Accessories";
    case "36712":
      return "Travel Bags & Luggage";
    case "35721":
      return "Trolley Bags";
    case "35722":
      return "Backpacks";
    case "35723":
      return "Travel Accessories";
    case "35724":
      return "Umbrella";
    case "35725":
      return "Packing Organizers";
    case "35726":
      return "Luggage Scales";
    case "35727":
      return "Luggage Locks";
    case "35728":
      return "Luggage Covers";
    case "35729":
      return "Fashion";
    case "36395":
      return "Sports & Outdoors";
    case "36396":
      return "Fitness Equipments";
    case "36410":
      return "Treadmills";
    case "36411":
      return "Exercise Bikes";
    case "36412":
      return "Rowers";
    case "36413":
      return "Ellipticals";
    case "36529":
      return "Weights";
    case "36397":
      return "Sports";
    case "36423":
      return "Cycling";
    case "36532":
      return "Bicycles";
    case "36534":
      return "Cycling Accessories";
    case "36414":
      return "Football";
    case "36415":
      return "Basketball";
    case "36416":
      return "Racket & Padel";
    case "36417":
      return "Cricket";
    case "36418":
      return "Martial Art & Boxing";
    case "36419":
      return "Volley Ball";
    case "36420":
      return "Water Sports";
    case "36671":
      return "Table Sports & Games";
    case "36672":
      return "Air Hokey Tables";
    case "36673":
      return "Soccer Tables";
    case "36674":
      return "Ping Pong Table";
    case "36675":
      return "Billiards";
    case "36422":
      return "Trampoline";
    case "36424":
      return "Skateboarding";
    case "36425":
      return "Other Sports";
    case "36398":
      return "Sports & Fitness Accessories";
    case "36426":
      return "Belts";
    case "36427":
    case "36690":
    case "36428":
    case "36429":
    case "36430":
    case "36432":
    case "36433":
    case "36434":
    case "36435":
    case "36684":
    case "190":
    case "36436":
    case "36437":
    case "36400":
    case "36401":
    case "36406":
    case "36407":
    case "36408":
    case "36409":
    case "36403":
    case "36404":
    case "36405":
      return "Sports & Outdoors";

    case "36814":
    case "36817":
      return "Books";

    case "33741":
      return "Toys & Outdoors";
    case "36147":
    case "36148":
    case "36149":
    case "36150":
    case "35151":
    case "35152":
    case "35153":
    case "36539":
    case "36823":
    case "467":
    case "36154":
    case "36155":
    case "36156":
    case "36157":
    case "36158":
    case "36159":
    case "36160":
    case "36161":
    case "36162":
    case "36163":
    case "36164":
    case "36172":
    case "36171":
    case "36285":
    case "36186":
    case "36187":
    case "36188":
    case "36189":
    case "36190":
    case "36191":
    case "36192":
    case "36193":
    case "36194":
    case "36195":
    case "36196":
    case "36197":
    case "36174":
    case "36175":
      return "Building Material & Hardware";

    case "11":
      return "Building Materials & Ceramics";
    case "12":
      return "Home & Office Furnishing";
    case "13":
      return "Promotions & Offers";

    case "36165":
      return "Dates & Dry Fruits";
    case "36166":
      return "Dates";

    case "36378":
      return "Powdered Drink mixes & Flavouring";

    // return "Breakfast Food";

    case "36796":
      return "Office & School Supplies";

    case "116":
      return "Baby Food & Care";

    case "123":
      return "Chocolate Hampers";
    case "33949":
      return "Diary";

    case "187":
      return "Healthy Lifestyle";

    case "225":
      return "Cooking & Dining";
    case "235":
      return "Kitchenware";
    case "240":
      return "Home Linen";
    case "247":
      return "Luggages";
    case "251":
      return "Stationery";
    case "272":
      return "Sports & Fitness";
    case "277":
      return "Sports & Fitness";

    case "35645":
      return "Kids";
    case "35720":
      return "Bags & Luggage";
    case "308":
      return "Women Clothing";
    case "334":
      return "Kids Clothing";
    case "349":
      return "Baby & Infants Clothing";
    case "355":
      return "Sportswear & Tracksuits";
    case "359":
      return "Eyewear";
    case "368":
      return "Eyewear Accessories";
    case "371":
      return "Footwear";
    case "372":
      return "Footwear";
    case "373":
      return "Footwear";
    case "385":
      return "Watches";
    case "36247":
      return "Baby & Infants";
    case "33754":
      return "Toys";
    case "33756":
      return "Musical Instruments";
    case "447":
      return "Ceramics";
    case "453":
      return "Tiles";
    case "459":
      return "Hardware & Tools";
    case "36171":
      return "Bathroom Essentials";
    case "469":
      return "Furniture";
    case "36087":
      return "Home Décor";
    case "477":
      return "Lights & Chandeliers";
    case "35591":
      return "New Arrivals";
    case "36399":
      return "Sports Medicine";
    case "36500":
      return "Trending";
    case "36523":
      return "Grocery Offers";

    case "36700":
      return "Promotions & Offers";

    case "36248":
    case "36283":
    case "36285":
    case "36286":
    case "36287":
    case "36288":
    case "36290":
    case "36289":
    case "36291":
    case "36292":
    case "36293":
    case "36294":
    case "36295":
    case "36296":
    case "36284":
    case "36297":
    case "36298":
    case "36249":
    case "36301":
    case "36308":
    case "36309":
    case "36310":
    case "36311":
    case "36312":
    case "36313":
    case "36314":
    case "36315":
    case "36316":
    case "36317":
    case "36318":
    case "36319":
    case "36320":
    case "36321":
    case "36302":
    case "36303":
    case "36304":
    case "36305":
    case "36306":
    case "36307":
    case "36541":
    case "36542":
    case "36543":
    case "36250":
    case "36272":
    case "36273":
    case "36274":
    case "36275":
    case "36276":
    case "36277":
    case "36278":
    case "36279":
    case "36280":
    case "36281":
    case "36282":
      return "Baby & Infants";
    case "36601":
      return "Toys";
    case "36603":
      return "Toys";
    case "36161":
      return "Tiles";
    case "36824":
      return "Toys";
    case "36088":
      return "Carpets & Rugs";

    case "36606":
      return "Toys";
    case "36604":
      return "Toys";
    case "36175":
      return "Bathroom Accessories";
    case "33742":
      return "Party & Celebrations";
    case "36833":
    case "36834":
    case "36835":
    case "36836":
    case "36837":
    case "36838":
    case "36839":
    case "36840":
    case "36841":
    case "36842":
    case "36843":
    case "36844":
    case "36845":
    case "36846":
    case "36847":
    case "36848":
    case "36849":
    case "36850":
    case "36851":
    case "36852":
      return "Tools & Home Improvement";
    case "36853":
    case "36854":
    case "36855":
    case "36856":
    case "36857":
    case "36858":
      return "Music";
    case "36540":
      return "Automotive";
    case "36535":
      return "Car Accessories";
    default:
      return "Others";
  }
}

class CallLogs {
  void call(String text, Function()? onTapClose) async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(text);

    if (onTapClose != null && res == true) {
      onTapClose();
    }
  }
}

whatsapp(
  String msg,
  String contact,
  BuildContext contxt,
  String ordernum,
) async {
  var androidUrl = "";

  if (contact == "+97460094446") {
    androidUrl = "whatsapp://send?phone=$contact&text=Hi, ${msg}";
  } else {
    String contactsplit = "";

    if (contact.startsWith('+974') || contact.startsWith('974')) {
      contactsplit = contact;
    } else {
      contactsplit = "+974${contact}";
    }

    log(contactsplit);

    if (UserController.userController.profile.role == "1") {
      androidUrl =
          "whatsapp://send?phone=${contactsplit}&text=Hello,this is ${UserController.userController.profile.name} Your *Ansar Gallery Order Picker*. I am here to assist with Preparing your order ${ordernum}";
    } else {
      androidUrl =
          "whatsapp://send?phone=${contactsplit}&text=Hello,this is ${UserController.userController.profile.name} Your *Ansar Gallery Order Driver*. I am here to assist with Deliver your order ${ordernum}";
    }
  }
  var iosUrl =
      "https://wa.me/$contact?text=${Uri.parse('Hi, I need some help')}";

  try {
    if (Platform.isIOS) {
      await launchUrl(Uri.parse(iosUrl));
    } else {
      await launchUrl(Uri.parse(androidUrl));
    }
  } on Exception {
    //  EasyLoading.showError('WhatsApp is not installed.');
    showSnackBar(
      context: contxt,
      snackBar: showErrorDialogue(errorMessage: "Whatsapp msg not sended..!"),
    );
  }
}

String getDelivery(String dtcode) {
  switch (dtcode) {
    case "858":
    case "exp":
      return "EXP";
    case "4":
    case "nol":
      return "NOL";
    case "5":
      return "SUP";
    case "6":
      return "WAR";
    case "438":
      return "NOL";
    default:
      return "";
  }
}

int getUserCategory(String user) {
  switch (user) {
    case "ahqa_veg":
      return 14;
    case "ahqa_butch":
      return 23;
    case "ahqa_fish":
      return 36741;
    case "ahqa_deli":
      return 36762;
    case "veg_alkhor":
      return 14;
    case "fish_alkhor":
      return 36741;
    case "alkhor_butch":
      return 23;
    case "alkhor_deli":
      return 36762;
    case "ah_grabgo":
      return 101;
    default:
      return 14;
  }
}

String getPaymentMethod(String method) {
  switch (method) {
    case "cashondelivery":
      return "Cash On Delivery";
    case "banktransfer":
      return "Card On Delivery";
    case "sadadqa":
      return "Credit / Debit / Wallet";
    default:
      return "";
  }
}
