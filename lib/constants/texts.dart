// const mainimageurl =
//     "https://media-qatar.ahmarket.com/media/catalog/product/cache/2b71e5a2b5266e17ec3596451a32baea/";

import 'package:google_maps_flutter/google_maps_flutter.dart';

const mainimageurl =
    "https://media-qatar.ansargallery.com/catalog/product/cache/eb0cb15e836edfdb24d87d738470728f";

const noimageurl =
    "https://www.ansargallery.com/static/frontend/Ahmarket/ahm/en_US/images/no_image.jpg";

const google_api_key = "AIzaSyDeFN4A3eenCTIUYvCI7dViF-N-V5X8RgA";

const scankey =
    'AlSW+D1UGoSBBqFadcbkguQYVIxyIrL0iiYqSjVDVexqca1CozYZGhNjaYMZTjnwfHrgUENf+Yjqel1kQ1TBP7c6NNFMYHgRdWINNQ09Y7mlDpUP6zJ7z0UEtg+uT299AEZ7obRWo4xaKM2rRkN9vd8wnzJqCi/q2E9X1SNSq9RpdhPjeVp9xm4Hv4JpaNPMuEk+Lhx4fSTTFIDyuVKLKCAbVVcucAU/XHDilQp76HjfWE9ngGIoASM7x+yXfKXo/3TsgAJf+AoMDryUuX7pkABw/HfiByVgqjHallptt2k9d0c81GCpXoEtpULjfYSe1UE9Kn1lLSX5eEyWniF/Rlla/dFQQAPisAaPFW4Y5DwnOvzxe3pvI4ITIUAWfRB0MVwjqzIh0yqFBVL2IynfPVIZU9VTfN0pdgCAubcRqqwldaG3RlSd0O4v3Q9MVPXZbUy4fTd59Jw2avfNTWQWauUCJbLIdzOOQCVNp5heERugVBaFyjcHOG0CvUxRbZCFJWs+NEoGWuOhTquqb0VdLjFfkTmlXo2lknSAkOVEpVkBRCIv3Fu6Jg9YgnDJaaWlMCJN6yBSfR/Wdn/ZaENYs8cIM0VgFunqSnsMJCVlmB4Wd+eykkKaUS4OSRcRUB4dj1/01TxGs4ZuCqygUnXrpDxgeRskV01ko26bbH5dj2E/bv7fHFnCIlQHBWoYa12XN0entN50BMeZQSt8tGkhx/RBDvWrc4JUmBld+a1PzIVKXdhQimsAXqJpkwnGWKUhFEjem68RubtvDi+LB3WF02MWZBgwXJAY4keGJrJUx6SSevjZ+1+C8ZthWi4aS7L92mQiUJZ6zxm5ZA/atTBx5Fh6qlRIVUIVI0aWsTtYZlK9OTB6vXyEW7c364/kWle6W3D/fyl8ZaBfdBFyHAvY56xyds11YzDbyXk3y2FoMS77Z8cwA2lpsrUrh8GvdApI7mhfnelALxUaezd/Y3pekjN3WhKeQ7B7blLJeFCA30ObuoSxxLFVkrFTQGyWDDBTGqSdg2fYueJKLayfQA0iammyom7FtBL+ktlO11b4oB6N3gdOsaMaWvyRBBPhXaXK4szfLLFU6XpftVTLjfwAlFkDFdADGKH3/YyHuv/SZ7GyPOSDzLF0Zo1wISMLwK/n2r+FLGfC0oLQLG1J0+5abmJylmlcx3P25y+uJfbEfkrq6FA7oRkcjt8Oqag8169oB5S0ZYx1LZYPLRhbG04sqDNe+ewaB52K7iZkw+y+o/r7ephq2HfPT4B++rdivu8Ki/HTfHm/RJ+p09tp+ozE3gzVLvGQ7RfSRMhctnskfRT6VO9wv7AdW9LuqSk5rhICAYVxp4JmSGcQb86MatnMjVUsIcIsTQ+NK3wuf1WalilbKyhY7ZSirTaK2lj/jAG84juRqdKqKcC5mukryBjeLro0XDIKmzWoZmqB3yrDJmTjXKNjxlDHvje2LciRKUjskmUrJLdJpMEObwmjC1sOZZgNXy6LC6ng8sc/QIhwGi5cFgZw4YXbtfeDaB+lKhv+Z8uTunAkg9qBhmsNt1jmge9/uh/g/aOyRXvgK+Cj3f1x3Y06dlVZjCyGdb4GJV0hRkzHeF4O+xIVliRyFW4Lp6URuzYrJK6LUfORHlA4OXd7JkCTAU1H8bNKOOwr/TtsclQhYOj6';

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
