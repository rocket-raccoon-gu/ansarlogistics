import 'dart:convert';

LoginResponse loginResponseFromJson(String str) =>
    LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  bool success;
  Profile profile;
  String token;

  LoginResponse({
    required this.success,
    required this.profile,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    success: json["success"] ?? false,
    profile: Profile.fromJson(json["user"]),
    token: json["token"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "user": profile.toJson(),
    "token": token,
  };
}

class Profile {
  int id;
  String empId;
  String employeeId;
  String name;
  String distance;
  String latitude;
  String longitude;
  int status;
  int approveStatus;
  String email;
  String mobileNumber;
  String vehicleNumber;
  int availabilityStatus;
  int breakStatus;
  String vehicleType;
  String password;
  String address;
  int role;
  String driverType;
  int zoneFlag;
  String branchCode;
  String categoryIds;
  String regularShiftTime;
  String fridayShiftTime;
  String offDay;
  int orderLimit;
  String appVersion;
  DateTime createdAt;
  DateTime updatedAt;
  String rpToken;
  DateTime rpTokenCreatedAt;

  Profile({
    required this.id,
    required this.empId,
    required this.employeeId,
    required this.name,
    required this.distance,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.approveStatus,
    required this.email,
    required this.mobileNumber,
    required this.vehicleNumber,
    required this.availabilityStatus,
    required this.breakStatus,
    required this.vehicleType,
    required this.password,
    required this.address,
    required this.role,
    required this.driverType,
    required this.zoneFlag,
    required this.branchCode,
    required this.categoryIds,
    required this.regularShiftTime,
    required this.fridayShiftTime,
    required this.offDay,
    required this.orderLimit,
    required this.appVersion,
    required this.createdAt,
    required this.updatedAt,
    required this.rpToken,
    required this.rpTokenCreatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json["id"] ?? 0,
    empId: json["emp_id"] ?? "",
    employeeId: json["employee_id"] ?? "",
    name: json["name"] ?? "",
    distance: json["distance"] ?? "",
    latitude: json["latitude"] ?? "",
    longitude: json["longitude"] ?? "",
    status: json["status"] ?? 0,
    approveStatus: json["approve_status"] ?? 0,
    email: json["email"] ?? "",
    mobileNumber: json["mobile_number"] ?? "",
    vehicleNumber: json["vehicle_number"] ?? "",
    availabilityStatus: json["availability_status"] ?? 0,
    breakStatus: json["break_status"] ?? 0,
    vehicleType: json["vehicle_type"] ?? "",
    password: json["password"] ?? "",
    address: json["address"] ?? "",
    role: json["role"] ?? 0,
    driverType: json["driver_type"] ?? "",
    zoneFlag: json["zone_flag"] ?? 0,
    branchCode: json["branch_code"] ?? "",
    categoryIds: json["category_ids"] ?? "",
    regularShiftTime: json["regular_shift_time"] ?? "",
    fridayShiftTime: json["friday_shift_time"] ?? "",
    offDay: json["off_day"] ?? "",
    orderLimit: json["order_limit"] ?? 0,
    appVersion: json["app_version"] ?? "",
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    rpToken: json["rp_token"] ?? "",
    rpTokenCreatedAt: DateTime.parse(json["rp_token_created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "emp_id": empId,
    "employee_id": employeeId,
    "name": name,
    "distance": distance,
    "latitude": latitude,
    "longitude": longitude,
    "status": status,
    "approve_status": approveStatus,
    "email": email,
    "mobile_number": mobileNumber,
    "vehicle_number": vehicleNumber,
    "availability_status": availabilityStatus,
    "break_status": breakStatus,
    "vehicle_type": vehicleType,
    "password": password,
    "address": address,
    "role": role,
    "driver_type": driverType,
    "zone_flag": zoneFlag,
    "branch_code": branchCode,
    "category_ids": categoryIds,
    "regular_shift_time": regularShiftTime,
    "friday_shift_time": fridayShiftTime,
    "off_day": offDay,
    "order_limit": orderLimit,
    "app_version": appVersion,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "rp_token": rpToken,
    "rp_token_created_at": rpTokenCreatedAt.toIso8601String(),
  };
}
