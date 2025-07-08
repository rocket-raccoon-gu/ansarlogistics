// const mainimageurl =
//     "https://media-qatar.ahmarket.com/media/catalog/product/cache/2b71e5a2b5266e17ec3596451a32baea/";

import 'package:google_maps_flutter/google_maps_flutter.dart';

const mainimageurl =
    "https://www.ansargallery.com/media/catalog/product/cache/d3078668c17a3fcf95f19e6d90a1909e/";

const noimageurl =
    "https://www.ansargallery.com/static/frontend/Ahmarket/ahm/en_US/images/no_image.jpg";

const google_api_key = "AIzaSyDeFN4A3eenCTIUYvCI7dViF-N-V5X8RgA";

class PickerTexts {
  static String bottomBarItem1 = "Orders";
  static String bottomBarItem2 = "My Report";
  static String bottomBarItem3 = "Products";
  static String bottomBarItem4 = "Profile";
}

class DriverTexts {
  static String bottomBarItem1 = "Orders";
  static String bottomBarItem2 = "My Report";
  static String bottomBarItem3 = "Summery";
  static String bottomBarItem4 = "Profile";
}

LatLng ansarlocation = LatLng(25.218370965115195, 51.50143763314008);

List<Map<String, dynamic>> statuslist = [
  {"index": 0, "name": "All", "status": "all"},
  {"index": 1, "name": "Assigned", "status": "assigned_picker"},
  {"index": 2, "name": "Start Pick", "status": "start_picking"},
  {"index": 3, "name": "End Pick", "status": "end_picking"},
  {"index": 4, "name": "On Hold", "status": "holded"},
  {"index": 5, "name": "Material Request", "status": "material_request"},
];

List<Map<String, dynamic>> driverstatuslist = [
  {"index": 0, "name": "All", "status": "all"},
  {"index": 1, "name": "Assigned", "status": "assigned_driver"},
  {"index": 2, "name": "OnTheWay", "status": "on_the_way"},
  {"index": 3, "name": "Delivered", "status": "complete"},
];

List driverbottomlist = [
  "assigned_picker",
  "end_picking",
  "item_not_available",
  "replacement",
];

final items = [
  'Duplicate order',
  'Cancel due to late delivery',
  'Item is not available',
  'Customer will place other order',
  'Customer not answering',
  'Customer mind changed',
  'Other Reasons',
];

final replacereasons = [
  'Item Out Of Stock',
  'Replacement From Customer Suggesion',
  'Barcode Not Found ',
  'Other Reasons',
];

final List<String> timerangelist = [
  "10:00 — 11:00",
  "11:00 — 12:00",
  "12:00 — 13:00",
  "13:00 — 14:00",
  "14:00 — 15:00",
  "15:00 — 16:00",
  "16:00 — 17:00",
  "17:00 — 18:00",
  "18:00 — 19:00",
  "19:00 — 20:00",
  "20:00 — 21:00",
  "21:00 — 22:00",
];

final regular_shifts = [
  "08:00 AM - 06:00 PM",
  "09:30 AM - 07:30 PM",
  "10:00 AM - 08:00 PM",
  "12:00 PM - 10:00 PM",
  "01:00 PM - 11:00 PM",
  "02:00 PM - 12:00 PM",
  "08:00 AM - 02:00 PM & 06:00 PM - 12:00 PM",
  "08:00 AM - 02:00 PM & 07:00 PM - 11:00 PM",
  "08:00 AM - 10:00 AM & 04:00 PM - 12:00 PM",
];

final friday_shifts = [
  "08:00 AM - 06:00 PM",
  "09:30 AM - 07:30 PM",
  "10:00 AM - 08:00 PM",
  "12:00 PM - 10:00 PM",
  "01:00 PM - 11:00 PM",
  "02:00 PM - 12:00 PM",
  "08:00 AM - 02:00 PM & 06:00 PM - 12:00 PM",
  "08:00 AM - 02:00 PM & 07:00 PM - 11:00 PM",
  "08:00 AM - 10:00 AM & 04:00 PM - 12:00 PM",
  "Day Off",
];

final dayoffs = [
  "Sunday",
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
];

String getUserType(String name) {
  switch (name) {
    case "Picker":
      return "1";
    case "Driver":
      return "3";
    default:
      return "2";
  }
}
