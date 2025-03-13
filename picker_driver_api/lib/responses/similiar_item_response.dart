// To parse this JSON data, do
//
//     final similialItemsResponse = similialItemsResponseFromJson(jsonString);

import 'dart:convert';

SimilialItemsResponse similialItemsResponseFromJson(String str) =>
    SimilialItemsResponse.fromJson(json.decode(str));

String similialItemsResponseToJson(SimilialItemsResponse data) =>
    json.encode(data.toJson());

class SimilialItemsResponse {
  List<SimiliarItems> items;
  SearchCriteria searchCriteria;
  int totalCount;

  SimilialItemsResponse({
    required this.items,
    required this.searchCriteria,
    required this.totalCount,
  });

  factory SimilialItemsResponse.fromJson(Map<String, dynamic> json) =>
      SimilialItemsResponse(
        items: List<SimiliarItems>.from(
            json["items"].map((x) => SimiliarItems.fromJson(x))),
        searchCriteria: SearchCriteria.fromJson(json["search_criteria"]),
        totalCount: json["total_count"],
      );

  Map<String, dynamic> toJson() => {
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
        "search_criteria": searchCriteria.toJson(),
        "total_count": totalCount,
      };
}

class SimiliarItems {
  String entityId;
  String attributeSetId;
  TypeId typeId;
  String sku;
  String hasOptions;
  String requiredOptions;
  DateTime createdAt;
  DateTime updatedAt;
  String status;
  String visibility;
  String taxClassId;
  String deliveryType;
  String? couponApply;
  String? simpleReturn;
  String name;
  String? metaTitle;
  String? metaDescription;
  String image;
  String smallImage;
  String thumbnail;
  OptionsContainer optionsContainer;
  String? imageLabel;
  String? smallImageLabel;
  String? thumbnailLabel;
  String msrpDisplayActualPriceType;
  String urlKey;
  String? giftMessageAvailable;
  String? swatchImage;
  String itemNumber;
  String? vendorName;
  String? vendorCode;
  String thresholdQty;
  String? metaKeyword;
  String? swissupRatingSummary;
  String price;
  int storeId;
  int ahQty;
  int ahIsInStock;
  int ahMaxQty;
  String? quantityAndStockStatus;
  String? specialPrice;
  DateTime? specialFromDate;
  DateTime? specialToDate;
  String? color;
  String? pageLayout;
  DateTime? newsFromDate;
  DateTime? newsToDate;
  String? description;
  String? shortDescription;

  SimiliarItems({
    required this.entityId,
    required this.attributeSetId,
    required this.typeId,
    required this.sku,
    required this.hasOptions,
    required this.requiredOptions,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.visibility,
    required this.taxClassId,
    required this.deliveryType,
    this.couponApply,
    this.simpleReturn,
    required this.name,
    this.metaTitle,
    this.metaDescription,
    required this.image,
    required this.smallImage,
    required this.thumbnail,
    required this.optionsContainer,
    this.imageLabel,
    this.smallImageLabel,
    this.thumbnailLabel,
    required this.msrpDisplayActualPriceType,
    required this.urlKey,
    this.giftMessageAvailable,
    this.swatchImage,
    required this.itemNumber,
    this.vendorName,
    this.vendorCode,
    required this.thresholdQty,
    this.metaKeyword,
    this.swissupRatingSummary,
    required this.price,
    required this.storeId,
    required this.ahQty,
    required this.ahIsInStock,
    required this.ahMaxQty,
    this.quantityAndStockStatus,
    this.specialPrice,
    this.specialFromDate,
    this.specialToDate,
    this.color,
    this.pageLayout,
    this.newsFromDate,
    this.newsToDate,
    this.description,
    this.shortDescription,
  });

  factory SimiliarItems.fromJson(Map<String, dynamic> json) => SimiliarItems(
        entityId: json["entity_id"],
        attributeSetId: json["attribute_set_id"],
        typeId: typeIdValues.map[json["type_id"]]!,
        sku: json["sku"],
        hasOptions: json["has_options"] ?? "",
        requiredOptions: json["required_options"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        status: json["status"],
        visibility: json["visibility"],
        taxClassId: json["tax_class_id"],
        deliveryType: json["delivery_type"] ?? "",
        couponApply: json["coupon_apply"] ?? "",
        simpleReturn: json["simple_return"],
        name: json["name"],
        metaTitle: json["meta_title"],
        metaDescription: json["meta_description"],
        image: json["image"],
        smallImage: json["small_image"],
        thumbnail: json["thumbnail"],
        optionsContainer:
            optionsContainerValues.map[json["options_container"]]!,
        imageLabel: json["image_label"] ?? "",
        smallImageLabel: json["small_image_label"] ?? "",
        thumbnailLabel: json["thumbnail_label"] ?? "",
        msrpDisplayActualPriceType: json["msrp_display_actual_price_type"],
        urlKey: json["url_key"],
        giftMessageAvailable: json["gift_message_available"],
        swatchImage: json["swatch_image"] ?? "",
        itemNumber: json["item_number"] ?? "",
        vendorName: json["vendor_name"] ?? "",
        vendorCode: json["vendor_code"] ?? "",
        thresholdQty: json["threshold_qty"] ?? "",
        metaKeyword: json["meta_keyword"],
        swissupRatingSummary: json["swissup_rating_summary"],
        price: json["price"],
        storeId: json["store_id"],
        ahQty: json["ah_qty"],
        ahIsInStock: json["ah_is_in_stock"],
        ahMaxQty: json["ah_max_qty"],
        quantityAndStockStatus: json["quantity_and_stock_status"],
        specialPrice: json["special_price"] ?? "",
        specialFromDate: json["special_from_date"] == null
            ? null
            : DateTime.parse(json["special_from_date"]),
        specialToDate: json["special_to_date"] == null
            ? null
            : DateTime.parse(json["special_to_date"]),
        color: json["color"],
        pageLayout: json["page_layout"],
        newsFromDate: json["news_from_date"] == null
            ? null
            : DateTime.parse(json["news_from_date"]),
        newsToDate: json["news_to_date"] == null
            ? null
            : DateTime.parse(json["news_to_date"]),
        description: json["description"],
        shortDescription: json["short_description"],
      );

  Map<String, dynamic> toJson() => {
        "entity_id": entityId,
        "attribute_set_id": attributeSetId,
        "type_id": typeIdValues.reverse[typeId],
        "sku": sku,
        "has_options": hasOptions,
        "required_options": requiredOptions,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "status": status,
        "visibility": visibility,
        "tax_class_id": taxClassId,
        "delivery_type": deliveryType,
        "coupon_apply": couponApply,
        "simple_return": simpleReturn,
        "name": name,
        "meta_title": metaTitle,
        "meta_description": metaDescription,
        "image": image,
        "small_image": smallImage,
        "thumbnail": thumbnail,
        "options_container": optionsContainerValues.reverse[optionsContainer],
        "image_label": imageLabel,
        "small_image_label": smallImageLabel,
        "thumbnail_label": thumbnailLabel,
        "msrp_display_actual_price_type": msrpDisplayActualPriceType,
        "url_key": urlKey,
        "gift_message_available": giftMessageAvailable,
        "swatch_image": swatchImage,
        "item_number": itemNumber,
        "vendor_name": vendorName,
        "vendor_code": vendorCode,
        "threshold_qty": thresholdQty,
        "meta_keyword": metaKeyword,
        "swissup_rating_summary": swissupRatingSummary,
        "price": price,
        "store_id": storeId,
        "ah_qty": ahQty,
        "ah_is_in_stock": ahIsInStock,
        "ah_max_qty": ahMaxQty,
        "quantity_and_stock_status": quantityAndStockStatus,
        "special_price": specialPrice,
        "special_from_date": specialFromDate?.toIso8601String(),
        "special_to_date": specialToDate?.toIso8601String(),
        "color": color,
        "page_layout": pageLayout,
        "news_from_date": newsFromDate?.toIso8601String(),
        "news_to_date": newsToDate?.toIso8601String(),
        "description": description,
        "short_description": shortDescription,
      };
}

enum OptionsContainer { CONTAINER2 }

final optionsContainerValues =
    EnumValues({"container2": OptionsContainer.CONTAINER2});

enum TypeId { SIMPLE }

final typeIdValues = EnumValues({"simple": TypeId.SIMPLE});

class SearchCriteria {
  int pageSize;
  int currentPage;

  SearchCriteria({
    required this.pageSize,
    required this.currentPage,
  });

  factory SearchCriteria.fromJson(Map<String, dynamic> json) => SearchCriteria(
        pageSize: json["page_size"],
        currentPage: json["current_page"],
      );

  Map<String, dynamic> toJson() => {
        "page_size": pageSize,
        "current_page": currentPage,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
