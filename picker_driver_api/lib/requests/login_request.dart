// To parse this JSON data, do
//
//     final loginRequest = loginRequestFromJson(jsonString);

import 'dart:convert';

LoginRequest loginRequestFromJson(String str) =>
    LoginRequest.fromJson(json.decode(str));

String loginRequestToJson(LoginRequest data) => json.encode(data.toJson());

class LoginRequest {
  String empId;
  String password;
  String token;
  String bearertoken;
  String os;
  String version;

  LoginRequest({
    required this.empId,
    required this.password,
    required this.token,
    required this.bearertoken,
    required this.os,
    required this.version,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
    empId: json["username"],
    password: json["password"],
    token: json["device_token"],
    bearertoken: json["bearertoken"],
    os: json["os"],
    version: json["version"],
  );

  Map<String, dynamic> toJson() => {
    "username": empId,
    "password": password,
    "device_token": token,
    "bearertoken": bearertoken,
    "os": os,
    "version": version,
  };
}
