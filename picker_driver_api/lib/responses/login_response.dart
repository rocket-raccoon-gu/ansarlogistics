// To parse this JSON data, do
//
//     final loginResponse = loginResponseFromJson(jsonString);

import 'dart:convert';

LoginResponse loginResponseFromJson(String str) =>
    LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  int success;
  String message;
  String token;
  Profile profile;

  LoginResponse({
    required this.success,
    required this.message,
    required this.token,
    required this.profile,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    success: json["success"],
    message: json["message"],
    token: json["token"] ?? "",
    profile: Profile.fromJson(json["profile"] ?? null),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "token": token,
    "profile": profile.toJson(),
  };
}

class Profile {
  String id;
  String empId;
  String name;
  String status;
  String approveStatus;
  String email;
  String mobileNumber;
  String vehicleNumber;
  String availabilityStatus;
  String breakStatus;
  String vehicleType;
  String password;
  String address;
  String role;
  dynamic driverType;
  String distance;
  String branchCode;
  String regularShiftTime;
  String fridayShiftTime;
  String offDay;
  String orderLimit;
  String appVersion;
  String latitude;
  String longitude;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic rpToken;
  DateTime rpTokenCreatedAt;
  String categoryIds;
  String section;

  Profile({
    required this.id,
    required this.empId,
    required this.name,
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
    required this.distance,
    required this.branchCode,
    required this.regularShiftTime,
    required this.fridayShiftTime,
    required this.offDay,
    required this.orderLimit,
    required this.appVersion,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
    required this.rpToken,
    required this.rpTokenCreatedAt,
    required this.categoryIds,
    required this.section,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json["id"].toString(),
    empId: json["emp_id"] ?? "",
    name: json["name"] ?? "",
    status: json["status"].toString() ?? "",
    approveStatus: json["approve_status"].toString() ?? "",
    email: json["email"] ?? "",
    mobileNumber: json["mobile_number"] ?? "",
    vehicleNumber: json["vehicle_number"] ?? "",
    availabilityStatus: json["availability_status"].toString() ?? "",
    breakStatus: json["break_status"].toString() ?? "",
    vehicleType: json["vehicle_type"] ?? "",
    password: json["password"] ?? "",
    address: json["address"] ?? "",
    role: json["role"].toString() ?? "",
    driverType: json["driver_type"] ?? "",
    distance: json["distance"] ?? "",
    branchCode: json["branch_code"] ?? "",
    regularShiftTime: json["regular_shift_time"] ?? "",
    fridayShiftTime: json["friday_shift_time"] ?? "",
    offDay: json["off_day"] ?? "",
    orderLimit: json["order_limit"].toString() ?? "",
    appVersion: json["app_version"] ?? "",
    latitude: json["latitude"] ?? "",
    longitude: json["longitude"] ?? "",
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    rpToken: json["rp_token"] ?? "",
    rpTokenCreatedAt: DateTime.parse(json["rp_token_created_at"]),
    categoryIds: json["category_ids"] ?? "",
    section: json["section"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "emp_id": empId,
    "name": name,
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
    "distance": distance,
    "branch_code": branchCode,
    "regular_shift_time": regularShiftTime,
    "friday_shift_time": fridayShiftTime,
    "off_day": offDay,
    "order_limit": orderLimit,
    "app_version": appVersion,
    "latitude": latitude,
    "longitude": longitude,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "rp_token": rpToken,
    "rp_token_created_at": rpTokenCreatedAt.toIso8601String(),
    "category_ids": categoryIds,
    "section": section,
  };
}
