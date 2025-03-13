// To parse this JSON data, do
//
//     final statusHistoryResponse = statusHistoryResponseFromJson(jsonString);

import 'dart:convert';

StatusHistoryResponse statusHistoryResponseFromJson(String str) =>
    StatusHistoryResponse.fromJson(json.decode(str));

String statusHistoryResponseToJson(StatusHistoryResponse data) =>
    json.encode(data.toJson());

class StatusHistoryResponse {
  List<StatusHistory> items;

  StatusHistoryResponse({
    required this.items,
  });

  StatusHistoryResponse copyWith({
    List<StatusHistory>? items,
  }) =>
      StatusHistoryResponse(
        items: items ?? this.items,
      );

  factory StatusHistoryResponse.fromJson(Map<String, dynamic> json) =>
      StatusHistoryResponse(
        items: List<StatusHistory>.from(
            json["items"].map((x) => StatusHistory.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
      };
}

class StatusHistory {
  String id;
  String parentId;
  String comment;
  String status;
  String statusType;
  String userId;
  DateTime createdAt;

  StatusHistory({
    required this.id,
    required this.parentId,
    required this.comment,
    required this.status,
    required this.statusType,
    required this.userId,
    required this.createdAt,
  });

  StatusHistory copyWith({
    String? id,
    String? parentId,
    String? comment,
    String? status,
    String? statusType,
    String? userId,
    DateTime? createdAt,
  }) =>
      StatusHistory(
        id: id ?? this.id,
        parentId: parentId ?? this.parentId,
        comment: comment ?? this.comment,
        status: status ?? this.status,
        statusType: statusType ?? this.statusType,
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
      );

  factory StatusHistory.fromJson(Map<String, dynamic> json) => StatusHistory(
        id: json["id"].toString(),
        parentId: json["parent_id"].toString(),
        comment: json["comment"],
        status: json["status"],
        statusType: json["status_type"] ?? "",
        userId: json["user_id"].toString(),
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "parent_id": parentId,
        "comment": comment,
        "status": status,
        "status_type": statusType,
        "user_id": userId,
        "created_at": createdAt.toIso8601String(),
      };
}
