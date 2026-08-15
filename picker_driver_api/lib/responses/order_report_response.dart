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

  factory OrderReportsResponse.fromJson(Map<String, dynamic> json) {
    final raw = json["data"];
    return OrderReportsResponse(
      success: json["success"] == true || json["success"] == 1,
      count: _asInt(json["count"]),
      data:
          raw is List
              ? raw
                  .whereType<Map>()
                  .map(
                    (item) => Datum.fromJson(Map<String, dynamic>.from(item)),
                  )
                  .toList()
              : [],
    );
  }

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
  List<ReportOrder> orders;

  Datum({
    required this.orderCount,
    required this.status,
    required this.createdAt,
    this.orders = const [],
  });

  factory Datum.fromJson(Map<String, dynamic> json) {
    final raw = json["orders"];
    return Datum(
      orderCount: json["order_count"]?.toString() ?? "0",
      status: json["status"]?.toString() ?? "",
      createdAt: json["created_at"],
      orders:
          raw is List
              ? raw
                  .whereType<Map>()
                  .map(
                    (item) =>
                        ReportOrder.fromJson(Map<String, dynamic>.from(item)),
                  )
                  .toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() => {
    "order_count": orderCount,
    "status": status,
    "created_at": createdAt,
    "orders": List<dynamic>.from(orders.map((x) => x.toJson())),
  };
}

class ReportOrder {
  String subgroupIdentifier;
  List<String> subgroupIdentifiers;
  bool isMerged;
  double posAmount;
  String paymentMethod;
  dynamic createdAt;

  ReportOrder({
    required this.subgroupIdentifier,
    required this.subgroupIdentifiers,
    required this.isMerged,
    required this.posAmount,
    required this.paymentMethod,
    this.createdAt,
  });

  factory ReportOrder.fromJson(Map<String, dynamic> json) {
    final ids = json["subgroup_identifiers"];
    return ReportOrder(
      subgroupIdentifier: json["subgroup_identifier"]?.toString() ?? "",
      subgroupIdentifiers:
          ids is List
              ? ids.map((id) => id.toString()).where((id) => id.isNotEmpty).toList()
              : [],
      isMerged: _asBool(json["is_merged"]),
      posAmount: _asDouble(json["pos_amount"]),
      paymentMethod: json["payment_method"]?.toString() ?? "",
      createdAt: json["created_at"],
    );
  }

  Map<String, dynamic> toJson() => {
    "subgroup_identifier": subgroupIdentifier,
    "subgroup_identifiers": subgroupIdentifiers,
    "is_merged": isMerged,
    "pos_amount": posAmount,
    "payment_method": paymentMethod,
    "created_at": createdAt,
  };
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase();
  return text == 'true' || text == '1';
}
