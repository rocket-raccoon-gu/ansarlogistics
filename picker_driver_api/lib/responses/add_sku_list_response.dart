// To parse this JSON data, do
//
//     final addSkuListResponce = addSkuListResponceFromJson(jsonString);

import 'dart:convert';

AddSkuListResponce addSkuListResponceFromJson(String str) =>
    AddSkuListResponce.fromJson(json.decode(str));

String addSkuListResponceToJson(AddSkuListResponce data) =>
    json.encode(data.toJson());

class AddSkuListResponce {
  int ok;
  int status;
  String message;
  List<String> available;

  AddSkuListResponce({
    required this.ok,
    required this.status,
    required this.message,
    required this.available,
  });

  factory AddSkuListResponce.fromJson(Map<String, dynamic> json) =>
      AddSkuListResponce(
        ok: json["ok"],
        status: json["status"],
        message: json["message"],
        available:
            json["available"] == null
                ? []
                : List<String>.from(json["available"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "ok": ok,
    "status": status,
    "message": message,
    "available": List<dynamic>.from(available.map((x) => x)),
  };
}
