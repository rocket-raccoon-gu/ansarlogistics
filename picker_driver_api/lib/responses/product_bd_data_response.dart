import 'dart:convert';

ProductDBdata productDBdataFromJson(String str) =>
    ProductDBdata.fromJson(json.decode(str));

String productDBdataToJson(ProductDBdata data) => json.encode(data.toJson());

class ProductDBdata {
  int productId;
  String sku;
  String skuName;
  String productType;
  String regularPrice;
  dynamic specialPrice;
  dynamic erpCurrentPrice;
  String deliveryType;
  String currentPromotionPrice;
  String images;
  int priority;
  String barcodes;
  String isProduce;
  String match;

  ProductDBdata({
    required this.productId,
    required this.sku,
    required this.skuName,
    required this.productType,
    required this.regularPrice,
    required this.specialPrice,
    required this.erpCurrentPrice,
    required this.deliveryType,
    required this.currentPromotionPrice,
    required this.images,
    required this.priority,
    required this.barcodes,
    required this.isProduce,
    required this.match,
  });

  ProductDBdata copyWith({
    int? productId,
    String? sku,
    String? skuName,
    String? productType,
    String? regularPrice,
    String? specialPrice,
    String? erpCurrentPrice,
    String? deliveryType,
    String? currentPromotionPrice,
    String? images,
    int? priority,
    String? barcodes,
    String? isProduce,
    String? match,
  }) => ProductDBdata(
    productId: productId ?? this.productId,
    sku: sku ?? this.sku,
    skuName: skuName ?? this.skuName,
    productType: productType ?? this.productType,
    regularPrice: regularPrice ?? this.regularPrice,
    specialPrice: specialPrice ?? this.specialPrice,
    erpCurrentPrice: erpCurrentPrice ?? this.erpCurrentPrice,
    deliveryType: deliveryType ?? this.deliveryType,
    currentPromotionPrice: currentPromotionPrice ?? this.currentPromotionPrice,
    images: images ?? this.images,
    priority: priority ?? this.priority,
    barcodes: barcodes ?? this.barcodes,
    isProduce: isProduce ?? this.isProduce,
    match: match ?? this.match,
  );

  factory ProductDBdata.fromJson(Map<String, dynamic> json) => ProductDBdata(
    productId: json["product_id"] ?? 0,
    sku: json["sku"],
    skuName: json["sku_name"],
    productType: json["product_type"] ?? "",
    regularPrice: json["regular_price"] ?? "",
    specialPrice: json["special_price"] ?? "",
    erpCurrentPrice: json["erp_current_price"] ?? "",
    deliveryType: json["delivery_type"],
    currentPromotionPrice: json["current_promotion_price"] ?? "",
    images: json["images"] ?? "",
    priority: json["priority"],
    barcodes: json["barcodes"] ?? "",
    isProduce: json["is_produce"] ?? "",
    match: json["match"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "sku": sku,
    "sku_name": skuName,
    "product_type": productType,
    "regular_price": regularPrice,
    "special_price": specialPrice,
    "erp_current_price": erpCurrentPrice,
    "delivery_type": deliveryType,
    "current_promotion_price": currentPromotionPrice,
    "images": images,
    "priority": priority,
    "barcodes": barcodes,
    "is_produce": isProduce,
    "match": match,
  };
}
