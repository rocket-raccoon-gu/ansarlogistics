// To parse this JSON data, do
//
//     final orderReportsResponse = orderReportsResponseFromJson(jsonString);

import 'dart:convert';

OrderReportsResponse orderReportsResponseFromJson(String str) =>
    OrderReportsResponse.fromJson(json.decode(str));

String orderReportsResponseToJson(OrderReportsResponse data) =>
    json.encode(data.toJson());

class OrderReportsResponse {
  bool success;
  int count;
  List<Datum> data;

  OrderReportsResponse({
    required this.success,
    required this.count,
    required this.data,
  });

  factory OrderReportsResponse.fromJson(Map<String, dynamic> json) =>
      OrderReportsResponse(
        success: json["success"],
        count: json["count"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "count": count,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  String orderCount;
  String status;
  dynamic createdAt;

  Datum({
    required this.orderCount,
    required this.status,
    required this.createdAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    orderCount: json["order_count"],
    status: json["status"],
    createdAt: json["created_at"],
  );

  Map<String, dynamic> toJson() => {
    "order_count": orderCount,
    "status": status,
    "created_at": createdAt,
  };
}
