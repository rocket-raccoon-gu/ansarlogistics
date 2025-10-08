// To parse this JSON data, do
//
//     final orderReportsResponse = orderReportsResponseFromJson(jsonString);

import 'dart:convert';

OrderReportsResponse orderReportsResponseFromJson(String str) =>
    OrderReportsResponse.fromJson(json.decode(str));

String orderReportsResponseToJson(OrderReportsResponse data) =>
    json.encode(data.toJson());

class OrderReportsResponse {
  int success;
  List<StatusHistory> statusHistories;

  OrderReportsResponse({required this.success, required this.statusHistories});

  OrderReportsResponse copyWith({
    int? success,
    List<StatusHistory>? statusHistories,
  }) => OrderReportsResponse(
    success: success ?? this.success,
    statusHistories: statusHistories ?? this.statusHistories,
  );

  factory OrderReportsResponse.fromJson(Map<String, dynamic> json) =>
      OrderReportsResponse(
        success: json["success"],
        statusHistories: List<StatusHistory>.from(
          json["status_histories"].map((x) => StatusHistory.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "status_histories": List<dynamic>.from(
      statusHistories.map((x) => x.toJson()),
    ),
  };
}

class StatusHistory {
  dynamic orderCount;
  String status;
  DateTime? createdAt;
  List<String>? orderIds;

  StatusHistory({
    required this.orderCount,
    required this.status,
    this.createdAt,
    this.orderIds,
  });

  StatusHistory copyWith({
    dynamic orderCount,
    String? status,
    DateTime? createdAt,
    List<String>? orderIds,
  }) => StatusHistory(
    orderCount: orderCount ?? this.orderCount,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    orderIds: orderIds ?? this.orderIds,
  );

  factory StatusHistory.fromJson(Map<String, dynamic> json) => StatusHistory(
    orderCount: json["order_count"],
    status: json["status"],
    createdAt:
        json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    orderIds:
        json["order_ids"] == null
            ? null
            : (json["order_ids"] as String)
                .split(',')
                .map((id) => id.trim())
                .toList(),
  );

  Map<String, dynamic> toJson() => {
    "order_count": orderCount,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "order_ids": orderIds?.join(','),
  };
}
