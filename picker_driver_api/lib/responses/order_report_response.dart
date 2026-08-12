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
  List<ReportOrderDetail> orders;

  StatusHistory({
    required this.orderCount,
    required this.status,
    this.createdAt,
    this.orderIds,
    this.orders = const [],
  });

  StatusHistory copyWith({
    dynamic orderCount,
    String? status,
    DateTime? createdAt,
    List<String>? orderIds,
    List<ReportOrderDetail>? orders,
  }) => StatusHistory(
    orderCount: orderCount ?? this.orderCount,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    orderIds: orderIds ?? this.orderIds,
    orders: orders ?? this.orders,
  );

  factory StatusHistory.fromJson(Map<String, dynamic> json) {
    final rawOrderIds = json["order_ids"];
    final List<String>? parsedOrderIds =
        rawOrderIds == null
            ? null
            : rawOrderIds is List
            ? rawOrderIds.map((e) => e.toString().trim()).toList()
            : rawOrderIds
                .toString()
                .split(',')
                .map((id) => id.trim())
                .where((id) => id.isNotEmpty)
                .toList();

    final rawOrders = json["orders"];
    final List<ReportOrderDetail> parsedOrders =
        rawOrders is List
            ? rawOrders
                .whereType<Map<String, dynamic>>()
                .map(ReportOrderDetail.fromJson)
                .toList()
            : const [];

    return StatusHistory(
      orderCount: json["order_count"],
      status: json["status"]?.toString() ?? "",
      createdAt:
          json["created_at"] == null
              ? null
              : DateTime.tryParse(json["created_at"].toString()),
      orderIds: parsedOrderIds,
      orders: parsedOrders,
    );
  }

  Map<String, dynamic> toJson() => {
    "order_count": orderCount,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "order_ids": orderIds?.join(','),
    "orders": orders.map((x) => x.toJson()).toList(),
  };
}

class ReportOrderDetail {
  final String subgroupIdentifier;
  final String paymentMethod;
  final String posAmount;

  ReportOrderDetail({
    required this.subgroupIdentifier,
    required this.paymentMethod,
    required this.posAmount,
  });

  factory ReportOrderDetail.fromJson(Map<String, dynamic> json) =>
      ReportOrderDetail(
        subgroupIdentifier: json["subgroup_identifier"]?.toString() ?? "",
        paymentMethod: json["payment_method"]?.toString() ?? "",
        posAmount: json["pos_amount"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
    "subgroup_identifier": subgroupIdentifier,
    "payment_method": paymentMethod,
    "pos_amount": posAmount,
  };
}
