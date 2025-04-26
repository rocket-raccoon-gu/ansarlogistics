// To parse this JSON data, do
//
//     final erPdata = erPdataFromJson(jsonString);

import 'dart:convert';

ErPdata erPdataFromJson(String str) => ErPdata.fromJson(json.decode(str));

String erPdataToJson(ErPdata data) => json.encode(data.toJson());

class ErPdata {
  int erpId;
  String erpSku;
  String erpProductName;
  String mergeBarcode;
  String erpPrice;
  String erpItemNumber;
  String erpUom;
  DateTime createdAt;
  int priority;
  String message;

  ErPdata({
    required this.erpId,
    required this.erpSku,
    required this.erpProductName,
    required this.mergeBarcode,
    required this.erpPrice,
    required this.erpItemNumber,
    required this.erpUom,
    required this.createdAt,
    required this.priority,
    required this.message,
  });

  ErPdata copyWith({
    int? erpId,
    String? erpSku,
    String? erpProductName,
    String? mergeBarcode,
    String? erpPrice,
    String? erpItemNumber,
    String? erpUom,
    DateTime? createdAt,
    int? priority,
    String? message,
  }) => ErPdata(
    erpId: erpId ?? this.erpId,
    erpSku: erpSku ?? this.erpSku,
    erpProductName: erpProductName ?? this.erpProductName,
    mergeBarcode: mergeBarcode ?? this.mergeBarcode,
    erpPrice: erpPrice ?? this.erpPrice,
    erpItemNumber: erpItemNumber ?? this.erpItemNumber,
    erpUom: erpUom ?? this.erpUom,
    createdAt: createdAt ?? this.createdAt,
    priority: priority ?? this.priority,
    message: message ?? this.message,
  );

  factory ErPdata.fromJson(Map<String, dynamic> json) => ErPdata(
    erpId: json["erp_id"],
    erpSku: json["erp_sku"],
    erpProductName: json["erp_product_name"] ?? "",
    mergeBarcode: json["merge_barcode"] ?? "",
    erpPrice: json["erp_price"] ?? "",
    erpItemNumber: json["erp_item_number"],
    erpUom: json["erp_uom"] ?? "",
    createdAt: DateTime.parse(json["created_at"]),
    priority: json["priority"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "erp_id": erpId,
    "erp_sku": erpSku,
    "erp_product_name": erpProductName,
    "merge_barcode": mergeBarcode,
    "erp_price": erpPrice,
    "erp_item_number": erpItemNumber,
    "erp_uom": erpUom,
    "created_at": createdAt.toIso8601String(),
    "priority": priority,
    "message": message,
  };
}
