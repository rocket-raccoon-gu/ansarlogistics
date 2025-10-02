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
  List<String> barcodes; // Changed to List<String>
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
    dynamic? specialPrice,
    dynamic? erpCurrentPrice,
    String? deliveryType,
    String? currentPromotionPrice,
    String? images,
    int? priority,
    List<String>? barcodes,
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
    sku: json["sku"] ?? "",
    skuName: json["sku_name"] ?? "",
    productType: json["product_type"] ?? "",
    regularPrice: double.parse(
      json["regular_price"] ?? "0.00",
    ).toStringAsFixed(2),
    specialPrice: json["special_price"],
    erpCurrentPrice: json["erp_current_price"],
    deliveryType: json["delivery_type"] ?? "",
    currentPromotionPrice: json["current_promotion_price"] ?? "",
    images: json["images"] ?? "",
    priority: json["priority"] ?? 0,
    barcodes: _parseBarcodes(json["barcodes"]), // Use helper function
    isProduce: json["is_produce"] ?? "",
    match: json["match"] ?? "",
  );

  // Helper function to parse barcodes from comma-separated string
  static List<String> _parseBarcodes(dynamic barcodesData) {
    if (barcodesData == null) {
      return [];
    }

    if (barcodesData is List) {
      return barcodesData.map((e) => e.toString()).toList();
    }

    final String barcodesString = barcodesData.toString();
    if (barcodesString.isEmpty) {
      return [];
    }

    return barcodesString
        .split(',')
        .map((barcode) => barcode.trim())
        .where((barcode) => barcode.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "sku": sku,
    "sku_name": skuName,
    "product_type": productType,
    "regular_price": double.parse(regularPrice ?? "0.00").toStringAsFixed(2),
    "special_price": specialPrice,
    "erp_current_price": erpCurrentPrice,
    "delivery_type": deliveryType,
    "current_promotion_price": currentPromotionPrice,
    "images": images,
    "priority": priority,
    "barcodes": barcodes.join(","), // Convert back to comma-separated string
    "is_produce": isProduce,
    "match": match,
  };
}
