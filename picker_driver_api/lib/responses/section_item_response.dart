// To parse this JSON data, do
//
//     final sectionItemResponse = sectionItemResponseFromJson(jsonString);

import 'dart:convert';

SectionItemResponse sectionItemResponseFromJson(String str) =>
    SectionItemResponse.fromJson(json.decode(str));

String sectionItemResponseToJson(SectionItemResponse data) =>
    json.encode(data.toJson());

class SectionItemResponse {
  bool success;
  List<Sectionitem> data;

  SectionItemResponse({
    required this.success,
    required this.data,
  });

  SectionItemResponse copyWith({
    bool? success,
    List<Sectionitem>? data,
  }) =>
      SectionItemResponse(
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory SectionItemResponse.fromJson(Map<String, dynamic> json) =>
      SectionItemResponse(
        success: json["success"],
        data: List<Sectionitem>.from(
            json["data"].map((x) => Sectionitem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Sectionitem {
  String sku;
  String productName;
  String stockQty;
  int isInStock;
  String imageUrl;

  Sectionitem({
    required this.sku,
    required this.productName,
    required this.stockQty,
    required this.isInStock,
    required this.imageUrl,
  });

  Sectionitem copyWith({
    String? sku,
    String? productName,
    String? stockQty,
    int? isInStock,
    String? imageUrl,
  }) =>
      Sectionitem(
        sku: sku ?? this.sku,
        productName: productName ?? this.productName,
        stockQty: stockQty ?? this.stockQty,
        isInStock: isInStock ?? this.isInStock,
        imageUrl: imageUrl ?? this.imageUrl,
      );

  factory Sectionitem.fromJson(Map<String, dynamic> json) => Sectionitem(
        sku: json["sku"],
        productName: json["product_name"],
        stockQty: json["stock_qty"],
        isInStock: json["is_in_stock"],
        imageUrl: json["image_url"],
      );

  Map<String, dynamic> toJson() => {
        "sku": sku,
        "product_name": productName,
        "stock_qty": stockQty,
        "is_in_stock": isInStock,
        "image_url": imageUrl,
      };
}
