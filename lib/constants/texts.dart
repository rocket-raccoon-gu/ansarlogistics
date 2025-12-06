// const mainimageurl =
//     "https://media-qatar.ahmarket.com/media/catalog/product/cache/2b71e5a2b5266e17ec3596451a32baea/";

import 'package:google_maps_flutter/google_maps_flutter.dart';

const mainimageurl =
    "https://www.ansargallery.com/media/catalog/product/cache/d3078668c17a3fcf95f19e6d90a1909e/";

const noimageurl =
    "https://www.ansargallery.com/static/frontend/Ahmarket/ahm/en_US/images/no_image.jpg";

const google_api_key = "AIzaSyDeFN4A3eenCTIUYvCI7dViF-N-V5X8RgA";

const scankey =
    'AgNGZCQcA91tO11ulN+F11AecF3/Cv/dqRlZM/k8yZ5uT9727keKJPYfGaXSbQ/xsFJPpTxFGx0EUWl+/FwSnsJGmK1zL6KN22/xhitspdrxJIGWDTxdilQpZ6dSUaMoF14sySZbgeHjS9Ta2EuzJ4RaxFNsI/nBpVAKm0xYlBEKasCuS2k/3epx/+GdV4COExKDY+dpNiUIOkhYnVL0H5s6PsijRniV6FsGrA9frZFNKM2NkFD4uP0OGfsWK8S1a3aoGhJVqP0UIEQQCl36UbJXXtFzMxShkh1y1VhaNWSnZV1m/33i/Ok8XQUmR0EYm1JjtiVH1bhOZFs+lgrWIlhW4CXqVUb8rnCsepVzLfKlYw7DAGqQn2dEwAGmLxZqFGakCjR+xh5hKQAkKl/yBv107GrYF168Y00GSPZrT1Z3eU6xrVEu56FmE4yGZ0MltXj056t0HuTmVNeDiEbBDYNX8dscYG+KXyLLGjpjaY3JdahAiHbYKbJ8XMyPc8GQC12KIJ0F/iDHMXzAQ00UHkFwmgRUGAdGsHWCii16TazdPN70Omwc0qNXjpo/XfPyMx5ufp1d8L8/ToYlXxd/99xOuC4rZfIU+mIM2r9kAv7lauFh2nb8RZgjnfd8RrMx7nNpYvNRDLnKOli82mIjAlVh0MSvexZ6WUDxfABesfWsYQ2xCHlmLcMK0ob2a2NRhQWVseZI3MfkRpYepWmAUPJaWCJvVibB9CXxdQxwbcWmcwSOIRkrKTRH1UXoQGsyAVcrAPBQSGFyVHqwimgDW+VUtsadRsEPrgwT/htIWph9ZO73emcBCvt0VGfYaY2AC2J3QyhfxU39VbLWZEhQpRBYcuBwevGnZnPLQgQoRbwNL7H2NWOT4Ld1+Ct/egLwv3MHyYVnDhiRTM2dejtIDrRZr0/sZj2+j2MhMHkz+sBrU+2liRkmWIIZZDDPcQikGXu1ORxi62gTK05BsW5ceLh5cYm+B3GppnFEn8FLWow5Ya84tSX2+ZIq5U5U93Q5xXhYPGTL/gVWwQWL+XnqhoOyT5LCJYxnIp9VGPlEQ6SA7Hma52Bh6YsUScv3fg5fPVvX862shRAifMnKdLQy6/WXdR0gQypnOxn2NvHcTXnUAOVV5D88pNeZ6phyLQbNiZUYGqFAkTxwmbYPDS0qpW5LXg8O6Lrb2RMOBNqIAiKaJ5laRfaPshY+hx8ige3cLWL6ftNKDko2euIxrO/1NAhx8Av87AOPulLpVHN9i0R5LiYLjKKvxQmbQYuY5yktpDMBuHVS0Q3E8floXY+WmAUhKpzUHFT3Z9/PKAOjZv0jBT81F1Yl/ahJd/L1VoJeStQPa78PiMdOCBzGOFd4mmtF6tOkV6aB1EK6ePSByAEH0p+Y+dOjowh93GT2WSpBYC1TvL2W9jENf5Kdxovh41fwXFnWeuZpaoT0iloIhU9z70dZraCTvTxbIbvNQ/6RaGdkZTQZBbAz7aoo0ShjUob80zHmmDDEfPnBSogu236KRB90QCg2IXynNjgC+XYkGjnozYRqvD3qn/ywItp/RXcn4xARkZzQRBGWzoT6h6FhcTJMbeoP1qzZ30FH/3lzsHH344IFNYlz8bjyTeEeRYT8wvmDweEydhaXOF9TCShKM4/eu8dtyxmO1c58wYVZnOXyRTGi';

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
