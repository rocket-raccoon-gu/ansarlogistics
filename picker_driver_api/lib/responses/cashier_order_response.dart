// To parse this JSON data, do
//
//     final cashierOrders = cashierOrdersFromJson(jsonString);

import 'dart:convert';

CashierOrders cashierOrdersFromJson(String str) =>
    CashierOrders.fromJson(json.decode(str));

String cashierOrdersToJson(CashierOrders data) => json.encode(data.toJson());

class CashierOrders {
  bool success;
  int count;
  int totalCount;
  Pagination pagination;
  List<Datum> data;

  CashierOrders({
    required this.success,
    required this.count,
    required this.totalCount,
    required this.pagination,
    required this.data,
  });

  factory CashierOrders.fromJson(Map<String, dynamic> json) => CashierOrders(
    success: json["success"],
    count: json["count"],
    totalCount: json["totalCount"],
    pagination: Pagination.fromJson(json["pagination"]),
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "count": count,
    "totalCount": totalCount,
    "pagination": pagination.toJson(),
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  String subgroupIdentifier;
  String branchCode;
  int suborderId;
  int orderSychNo;
  int orderId;
  String orderStatus;
  dynamic statusType;
  DateTime deliveryFrom;
  DateTime? deliveryTo;
  String? timerange;
  int pickerId;
  int? driverId;
  int driverFlag;
  DateTime createdAt;
  DateTime updatedAt;
  String orderAmount;
  String shippedAmount;
  String shippingCharge;
  dynamic discountValue;
  dynamic discountType;
  String grandTotal;
  dynamic posAmount;
  int orderModifyNotification;
  String? driverLat;
  String? driverLong;
  String shipmentLabel;
  String preparationLabel;

  Datum({
    required this.subgroupIdentifier,
    required this.branchCode,
    required this.suborderId,
    required this.orderSychNo,
    required this.orderId,
    required this.orderStatus,
    required this.statusType,
    required this.deliveryFrom,
    required this.deliveryTo,
    required this.timerange,
    required this.pickerId,
    required this.driverId,
    required this.driverFlag,
    required this.createdAt,
    required this.updatedAt,
    required this.orderAmount,
    required this.shippedAmount,
    required this.shippingCharge,
    required this.discountValue,
    required this.discountType,
    required this.grandTotal,
    required this.posAmount,
    required this.orderModifyNotification,
    required this.driverLat,
    required this.driverLong,
    required this.shipmentLabel,
    required this.preparationLabel,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    subgroupIdentifier: json["subgroup_identifier"],
    branchCode: json["branch_code"],
    suborderId: json["suborder_id"],
    orderSychNo: json["order_sych_no"],
    orderId: json["order_id"],
    orderStatus: json["order_status"],
    statusType: json["status_type"],
    deliveryFrom: DateTime.parse(json["delivery_from"]),
    deliveryTo:
        json["delivery_to"] == null
            ? null
            : DateTime.parse(json["delivery_to"]),
    timerange: json["timerange"],
    pickerId: json["picker_id"],
    driverId: json["driver_id"],
    driverFlag: json["driver_flag"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    orderAmount: json["order_amount"],
    shippedAmount: json["shipped_amount"],
    shippingCharge: json["shipping_charge"],
    discountValue: json["discount_value"],
    discountType: json["discount_type"],
    grandTotal: json["grand_total"],
    posAmount: json["pos_amount"],
    orderModifyNotification: json["order_modify_notification"],
    driverLat: json["driver_lat"],
    driverLong: json["driver_long"],
    shipmentLabel: json["shipment_label"],
    preparationLabel: json["preparation_label"],
  );

  Map<String, dynamic> toJson() => {
    "subgroup_identifier": subgroupIdentifier,
    "branch_code": branchCode,
    "suborder_id": suborderId,
    "order_sych_no": orderSychNo,
    "order_id": orderId,
    "order_status": orderStatus,
    "status_type": statusType,
    "delivery_from": deliveryFrom.toIso8601String(),
    "delivery_to": deliveryTo?.toIso8601String(),
    "timerange": timerange,
    "picker_id": pickerId,
    "driver_id": driverId,
    "driver_flag": driverFlag,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "order_amount": orderAmount,
    "shipped_amount": shippedAmount,
    "shipping_charge": shippingCharge,
    "discount_value": discountValue,
    "discount_type": discountType,
    "grand_total": grandTotal,
    "pos_amount": posAmount,
    "order_modify_notification": orderModifyNotification,
    "driver_lat": driverLat,
    "driver_long": driverLong,
    "shipment_label": shipmentLabel,
    "preparation_label": preparationLabel,
  };
}

class Pagination {
  int currentPage;
  int totalPages;
  int totalItems;
  int itemsPerPage;
  bool hasNext;
  bool hasPrev;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNext,
    required this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["currentPage"],
    totalPages: json["totalPages"],
    totalItems: json["totalItems"],
    itemsPerPage: json["itemsPerPage"],
    hasNext: json["hasNext"],
    hasPrev: json["hasPrev"],
  );

  Map<String, dynamic> toJson() => {
    "currentPage": currentPage,
    "totalPages": totalPages,
    "totalItems": totalItems,
    "itemsPerPage": itemsPerPage,
    "hasNext": hasNext,
    "hasPrev": hasPrev,
  };
}
