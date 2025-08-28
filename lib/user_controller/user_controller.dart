import 'package:picker_driver_api/responses/branch_section_data_response.dart';
import 'package:picker_driver_api/responses/login_response.dart';
import 'package:picker_driver_api/responses/order_response.dart';
import 'package:picker_driver_api/responses/orders_new_response.dart';
import 'package:picker_driver_api/responses/section_item_response.dart';

class UserController {
  UserController._privateConstructor();
  static final UserController userController =
      UserController._privateConstructor();

  factory UserController() {
    return userController;
  }

  bool allowOrderRequest = true;
  bool alloworderupdated = false;
  bool itemreplaced = false;
  List<OrderNew> orderitems = [];
  String appVersion = "";
  String currentTheme = "";
  String userName = "";
  String profileid = "";
  String passWord = "";
  String devicetoken = "";
  String userShortName = "";
  bool iminloginpage = false;
  bool notified = false;
  bool firsttime = true;
  int selectedindex = 0;
  String cancelreason = "Please Select Reason";
  String locationlongitude = "51.50413815416897";
  String locationlatitude = "25.22131574418503";
  List<EndPicking> indexlist = [];
  List<EndPicking> itemnotavailablelist = [];
  List<String> pickerindexlist = [];
  List<String> notavailableindexlist = [];
  List<Sectionitem> sectionitems = [];
  List<Branchdatum> branchdata = [];
  String base = "";
  String producturl = "";
  String applicationpath = "";
  bool scanselection = true;
  final translationCache = <String, String>{};
  bool translate = false;
  Map<String, double> orderdata = {};

  String barwalong = "51.50264277400484";
  String barwalat = "25.219673232058142";
  String app_token = "";
  Profile profile = Profile(
    id: 0,
    empId: "",
    employeeId: "",
    name: "",
    status: 0,
    approveStatus: 0,
    email: "",
    mobileNumber: "",
    vehicleNumber: "",
    availabilityStatus: 0,
    breakStatus: 0,
    vehicleType: "",
    password: "",
    address: "",
    role: 0,
    driverType: "",
    distance: "",
    branchCode: "",
    regularShiftTime: "",
    fridayShiftTime: "",
    offDay: "",
    orderLimit: 0,
    appVersion: "",
    latitude: "",
    longitude: "",
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    rpToken: "",
    rpTokenCreatedAt: DateTime.now(),
    categoryIds: "",
    zoneFlag: 0,
  );

  dispose() {
    appVersion = "";
    currentTheme = "";
    userName = "";
    passWord = "";
    devicetoken = "";
    userShortName = "";
  }

  // void printOrderData() {
  //   // print("🧾 Current Order Data in Memory:");
  //   if (orderdata.isEmpty) {
  //     // print("🚫 No order data found.");
  //   } else {
  //     orderdata.forEach((key, value) {
  //       // print("📦 Order ID: $key ➡️ Price: $value");
  //     });
  //   }
  // }
}
