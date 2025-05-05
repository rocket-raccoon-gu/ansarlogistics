import 'package:picker_driver_api/responses/branch_section_data_response.dart';
import 'package:picker_driver_api/responses/login_response.dart';
import 'package:picker_driver_api/responses/order_response.dart';
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
  List<Order> orderitems = [];
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
  Map<String, dynamic> orderdata = {};

  String barwalong = "51.50264277400484";
  String barwalat = "25.219673232058142";
  Profile profile = Profile(
    id: "",
    empId: "",
    name: "",
    status: "",
    approveStatus: "",
    email: "",
    mobileNumber: "",
    vehicleNumber: "",
    availabilityStatus: "",
    breakStatus: "",
    vehicleType: "",
    password: "",
    address: "",
    role: "",
    driverType: "",
    distance: "",
    branchCode: "",
    regularShiftTime: "",
    fridayShiftTime: "",
    offDay: "",
    orderLimit: "",
    appVersion: "",
    latitude: "",
    longitude: "",
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    rpToken: "",
    rpTokenCreatedAt: DateTime.now(),
  );

  dispose() {
    appVersion = "";
    currentTheme = "";
    userName = "";
    passWord = "";
    devicetoken = "";
    userShortName = "";
  }
}
