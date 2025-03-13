import 'dart:convert';

ProductResponse productResponseFromJson(String str) =>
    ProductResponse.fromJson(json.decode(str));

String productResponseToJson(ProductResponse data) =>
    json.encode(data.toJson());

class ProductResponse {
  ProductResponse({
    required this.id,
    required this.sku,
    required this.name,
    required this.price,
    required this.status,
    required this.typeId,
    required this.createdAt,
    required this.extensionAttributes,
    required this.mediaGalleryEntries,
    required this.tierPrices,
    required this.customAttributes,
  });

  int id;
  String sku;
  String name;
  String price;
  int status;
  String typeId;
  DateTime createdAt;
  ExtensionAttributes extensionAttributes;
  List<MediaGalleryEntry1> mediaGalleryEntries;
  List<dynamic> tierPrices;
  List<CustomAttribute> customAttributes;

  factory ProductResponse.fromJson(Map<String, dynamic> json) =>
      ProductResponse(
        id: json["id"],
        sku: json["sku"],
        name: json["name"],
        price: json["price"] != null ? json["price"].toString() : "0.0",
        status: json["status"],
        typeId: json["type_id"],
        createdAt: DateTime.parse(json["created_at"]),
        extensionAttributes:
            ExtensionAttributes.fromJson(json["extension_attributes"]),
        mediaGalleryEntries: List<MediaGalleryEntry1>.from(
            json["media_gallery_entries"]
                .map((x) => MediaGalleryEntry1.fromJson(x))),
        tierPrices: List<dynamic>.from(json["tier_prices"].map((x) => x)),
        customAttributes: List<CustomAttribute>.from(
            json["custom_attributes"].map((x) => CustomAttribute.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "sku": sku,
        "id": id,
        "name": name,
        "price": price,
        "status": status,
        "type_id": typeId,
        "created_at": createdAt.toIso8601String(),
        "extension_attributes": extensionAttributes.toJson(),
        "media_gallery_entries":
            List<dynamic>.from(mediaGalleryEntries.map((x) => x.toJson())),
        "tier_prices": List<dynamic>.from(tierPrices.map((x) => x)),
        "custom_attributes":
            List<dynamic>.from(customAttributes.map((x) => x.toJson())),
      };
}

class CustomAttribute {
  CustomAttribute({
    required this.attributeCode,
    required this.value,
  });

  String attributeCode;
  dynamic value;

  factory CustomAttribute.fromJson(Map<String, dynamic> json) =>
      CustomAttribute(
        attributeCode: json["attribute_code"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "attribute_code": attributeCode,
        "value": value,
      };
}

class ExtensionAttributes {
  ExtensionAttributes(
      {
      // required this.websiteIds,
      required this.categoryLinks,
      this.configurableProductOptions
      // required this.stockItem,
      });

  // List<int> websiteIds;
  List<CategoryLink> categoryLinks;
  List<ConfigurableProductOption>? configurableProductOptions;
  // StockItem stockItem;

  factory ExtensionAttributes.fromJson(Map<String, dynamic> json) =>
      ExtensionAttributes(
        categoryLinks: json["category_links"] == null
            ? []
            : List<CategoryLink>.from(
                json["category_links"].map((x) => CategoryLink.fromJson(x))),
        configurableProductOptions: json["configurable_product_options"] == null
            ? []
            : List<ConfigurableProductOption>.from(
                json["configurable_product_options"]
                    .map((x) => ConfigurableProductOption.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "category_links":
            List<dynamic>.from(categoryLinks.map((x) => x.toJson())),
        "configurable_product_options": List<dynamic>.from(
            configurableProductOptions!.map((x) => x.toJson())),
      };
}

class CategoryLink {
  CategoryLink({
    required this.position,
    required this.categoryId,
  });

  int position;
  String categoryId;

  factory CategoryLink.fromJson(Map<String, dynamic> json) => CategoryLink(
        position: json["position"],
        categoryId: json["category_id"],
      );

  Map<String, dynamic> toJson() => {
        "position": position,
        "category_id": categoryId,
      };
}

class ConfigurableProductOption {
  int id;
  String attributeId;
  String label;
  int position;
  List<ValueElement> values;
  int productId;

  ConfigurableProductOption({
    required this.id,
    required this.attributeId,
    required this.label,
    required this.position,
    required this.values,
    required this.productId,
  });

  factory ConfigurableProductOption.fromJson(Map<String, dynamic> json) =>
      ConfigurableProductOption(
        id: json["id"],
        attributeId: json["attribute_id"],
        label: json["label"],
        position: json["position"],
        values: List<ValueElement>.from(
            json["values"].map((x) => ValueElement.fromJson(x))),
        productId: json["product_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "attribute_id": attributeId,
        "label": label,
        "position": position,
        "values": List<dynamic>.from(values.map((x) => x.toJson())),
        "product_id": productId,
      };
}

class ValueElement {
  String valueIndex;
  String label;
  String sku;

  ValueElement({
    required this.valueIndex,
    required this.label,
    required this.sku,
  });

  factory ValueElement.fromJson(Map<String, dynamic> json) => ValueElement(
        valueIndex: json["value_index"].toString(),
        label: json["label"] ?? "",
        sku: json["sku"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "value_index": valueIndex,
        "label": label,
        "sku": sku,
      };
}

class StockItem {
  StockItem({
    required this.isInStock,
  });

  bool isInStock;

  factory StockItem.fromJson(Map<String, dynamic> json) => StockItem(
        isInStock: json["is_in_stock"],
      );

  Map<String, dynamic> toJson() => {
        "is_in_stock": isInStock,
      };
}

class MediaGalleryEntry1 {
  MediaGalleryEntry1({
    required this.id,
    required this.mediaType,
    this.label,
    required this.position,
    required this.disabled,
    required this.types,
    required this.file,
  });

  int id;
  String mediaType;
  String? label;
  int position;
  bool disabled;
  List<String> types;
  String file;

  factory MediaGalleryEntry1.fromJson(Map<String, dynamic> json) =>
      MediaGalleryEntry1(
        id: json["id"],
        mediaType: json["media_type"],
        label: json["label"],
        position: json["position"],
        disabled: json["disabled"],
        types: List<String>.from(json["types"].map((x) => x)),
        file: json["file"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "media_type": mediaType,
        "label": label,
        "position": position,
        "disabled": disabled,
        "types": List<dynamic>.from(types.map((x) => x)),
        "file": file,
      };
}

class ProductLink {
  ProductLink({
    required this.sku,
    required this.linkType,
    required this.linkedProductSku,
    required this.linkedProductType,
    required this.position,
  });

  String sku;
  String linkType;
  String linkedProductSku;
  String linkedProductType;
  int position;

  factory ProductLink.fromJson(Map<String, dynamic> json) => ProductLink(
        sku: json["sku"],
        linkType: json["link_type"],
        linkedProductSku: json["linked_product_sku"],
        linkedProductType: json["linked_product_type"],
        position: json["position"],
      );

  Map<String, dynamic> toJson() => {
        "sku": sku,
        "link_type": linkType,
        "linked_product_sku": linkedProductSku,
        "linked_product_type": linkedProductType,
        "position": position,
      };
}
