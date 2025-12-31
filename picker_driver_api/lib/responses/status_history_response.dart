// To parse this JSON data, do
//
//     final statusHistoryResponse = statusHistoryResponseFromJson(jsonString);

import 'dart:convert';

StatusHistoryResponse statusHistoryResponseFromJson(String str) =>
    StatusHistoryResponse.fromJson(json.decode(str));

String statusHistoryResponseToJson(StatusHistoryResponse data) =>
    json.encode(data.toJson());

class StatusHistoryResponse {
  bool success;
  List<StatusHistory> data;
  int length;

  StatusHistoryResponse({
    required this.success,
    required this.data,
    required this.length,
  });

  factory StatusHistoryResponse.fromJson(Map<String, dynamic> json) =>
      StatusHistoryResponse(
        success: json["success"],
        data: List<StatusHistory>.from(
          json["data"].map((x) => StatusHistory.fromJson(x)),
        ),
        length: json["length"],
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "length": length,
  };
}

class StatusHistory {
  int id;
  String parentId;
  String comment;
  String status;
  dynamic statusType;
  int? userId;
  int updatedBy;
  String latitude;
  String longitude;
  DateTime createdAt;

  StatusHistory({
    required this.id,
    required this.parentId,
    required this.comment,
    required this.status,
    required this.statusType,
    required this.userId,
    required this.updatedBy,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  factory StatusHistory.fromJson(Map<String, dynamic> json) => StatusHistory(
    id: json["id"],
    parentId: json["parent_id"],
    comment: json["comment"],
    status: json["status"],
    statusType: json["status_type"],
    userId: json["user_id"],
    updatedBy: json["updated_by"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "parent_id": parentId,
    "comment": comment,
    "status": status,
    "status_type": statusType,
    "user_id": userId,
    "updated_by": updatedBy,
    "latitude": latitude,
    "longitude": longitude,
    "created_at": createdAt.toIso8601String(),
  };
}
