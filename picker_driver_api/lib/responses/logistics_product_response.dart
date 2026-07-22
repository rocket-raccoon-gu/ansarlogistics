// To parse this JSON data, do
//
//     final logisticsProductResponse = logisticsProductResponseFromJson(jsonString);

import 'dart:convert';

LogisticsProductResponse logisticsProductResponseFromJson(String str) =>
    LogisticsProductResponse.fromJson(json.decode(str));

String logisticsProductResponseToJson(LogisticsProductResponse data) =>
    json.encode(data.toJson());

class LogisticsProductResponse {
  final bool success;
  final int count;
  final List<Product> data;

  LogisticsProductResponse({
    required this.success,
    required this.count,
    required this.data,
  });

  factory LogisticsProductResponse.fromJson(Map<String, dynamic> json) =>
      LogisticsProductResponse(
        success: json["success"],
        count: json["count"],
        data: List<Product>.from(json["data"].map((x) => Product.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "count": count,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Product {
  final int entityId;
  final String sku;
  final String nameEn;
  final String nameAr;
  final String image;
  final String price;
  final List<AdditionalImage> additionalImages;

  Product({
    required this.entityId,
    required this.sku,
    required this.nameEn,
    required this.nameAr,
    required this.image,
    required this.price,
    required this.additionalImages,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    entityId: json["entity_id"],
    sku: json["sku"],
    nameEn: json["name_en"],
    nameAr: json["name_ar"],
    image: json["image"] ?? "",
    price: json["price"].toString() ?? "",
    additionalImages: List<AdditionalImage>.from(
      json["additional_images"].map((x) => AdditionalImage.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "entity_id": entityId,
    "sku": sku,
    "name_en": nameEn,
    "name_ar": nameAr,
    "image": image,
    "price": price,
    "additional_images": List<dynamic>.from(
      additionalImages.map((x) => x.toJson()),
    ),
  };
}

class AdditionalImage {
  final String image;
  final dynamic label;
  final int position;

  AdditionalImage({
    required this.image,
    required this.label,
    required this.position,
  });

  factory AdditionalImage.fromJson(Map<String, dynamic> json) =>
      AdditionalImage(
        image: json["image"],
        label: json["label"],
        position: json["position"],
      );

  Map<String, dynamic> toJson() => {
    "image": image,
    "label": label,
    "position": position,
  };
}
