// To parse this JSON data, do
//
//     final checkSectionstatusList = checkSectionstatusListFromJson(jsonString);

import 'dart:convert';

CheckSectionstatusList checkSectionstatusListFromJson(String str) =>
    CheckSectionstatusList.fromJson(json.decode(str));

String checkSectionstatusListToJson(CheckSectionstatusList data) =>
    json.encode(data.toJson());

class CheckSectionstatusList {
  bool success;
  List<StatusHistory> data;
  String message;

  CheckSectionstatusList({
    required this.success,
    required this.data,
    required this.message,
  });

  CheckSectionstatusList copyWith({
    bool? success,
    List<StatusHistory>? data,
    String? message,
  }) => CheckSectionstatusList(
    success: success ?? this.success,
    data: data ?? this.data,
    message: message ?? this.message,
  );

  factory CheckSectionstatusList.fromJson(Map<String, dynamic> json) =>
      CheckSectionstatusList(
        success: json["success"],
        data: List<StatusHistory>.from(
          json["data"].map((x) => StatusHistory.fromJson(x)),
        ),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "message": message,
  };
}

class StatusHistory {
  int id;
  int categoryId;
  String productName;
  String sku;
  int status;
  String userId;
  String branchCode;
  DateTime updatedAt;

  StatusHistory({
    required this.id,
    required this.categoryId,
    required this.productName,
    required this.sku,
    required this.status,
    required this.userId,
    required this.branchCode,
    required this.updatedAt,
  });

  StatusHistory copyWith({
    int? id,
    int? categoryId,
    String? productName,
    String? sku,
    int? status,
    String? userId,
    String? branchCode,
    DateTime? updatedAt,
  }) => StatusHistory(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    productName: productName ?? this.productName,
    sku: sku ?? this.sku,
    status: status ?? this.status,
    userId: userId ?? this.userId,
    branchCode: branchCode ?? this.branchCode,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory StatusHistory.fromJson(Map<String, dynamic> json) => StatusHistory(
    id: json["id"],
    categoryId: json["category_id"],
    productName: json["product_name"],
    sku: json["sku"],
    status: json["status"],
    userId: json["user_id"],
    branchCode: json["branch_code"],
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "category_id": categoryId,
    "product_name": productName,
    "sku": sku,
    "status": status,
    "user_id": userId,
    "branch_code": branchCode,
    "updated_at": updatedAt.toIso8601String(),
  };

  factory StatusHistory.empty() => StatusHistory(
    id: 0,
    categoryId: 0,
    productName: "",
    sku: "",
    status: 0,
    userId: "",
    branchCode: "",
    updatedAt: DateTime.now(),
  );
}
