// To parse this JSON data, do
//
//     final itemListResponse = itemListResponseFromJson(jsonString);

import 'dart:convert';

ItemListResponse itemListResponseFromJson(String str) =>
    ItemListResponse.fromJson(json.decode(str));

String itemListResponseToJson(ItemListResponse data) =>
    json.encode(data.toJson());

class ItemListResponse {
  List<Item> items;
  int itemCount;

  ItemListResponse({
    required this.items,
    required this.itemCount,
  });

  ItemListResponse copyWith({
    List<Item>? items,
    int? itemCount,
  }) =>
      ItemListResponse(
        items: items ?? this.items,
        itemCount: itemCount ?? this.itemCount,
      );

  factory ItemListResponse.fromJson(Map<String, dynamic> json) =>
      ItemListResponse(
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
        itemCount: json["item_count"],
      );

  Map<String, dynamic> toJson() => {
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
        "item_count": itemCount,
      };
}

class Item {
  String catename;
  List<Itemlist> itemlist;

  Item({
    required this.catename,
    required this.itemlist,
  });

  Item copyWith({
    String? catename,
    List<Itemlist>? itemlist,
  }) =>
      Item(
        catename: catename ?? this.catename,
        itemlist: itemlist ?? this.itemlist,
      );

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        catename: json["catename"],
        itemlist: List<Itemlist>.from(
            json["itemlist"].map((x) => Itemlist.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "catename": catename,
        "itemlist": List<dynamic>.from(itemlist.map((x) => x.toJson())),
      };
}

class Itemlist {
  String itemId;
  String productId;
  String productSku;
  String productName;
  String itemStatus;
  String productOptions;
  String qtyOrdered;
  String qtyCanceled;
  String qtyShipped;
  String price;
  String finalPrice;
  String discountPercent;
  String discountAmount;
  String subtotal;
  String catename;
  List<String> productImages;

  Itemlist({
    required this.itemId,
    required this.productId,
    required this.productSku,
    required this.productName,
    required this.itemStatus,
    required this.productOptions,
    required this.qtyOrdered,
    required this.qtyCanceled,
    required this.qtyShipped,
    required this.price,
    required this.finalPrice,
    required this.discountPercent,
    required this.discountAmount,
    required this.subtotal,
    required this.catename,
    required this.productImages,
  });

  Itemlist copyWith({
    String? itemId,
    String? productId,
    String? productSku,
    String? productName,
    String? itemStatus,
    String? productOptions,
    String? qtyOrdered,
    String? qtyCanceled,
    String? qtyShipped,
    String? price,
    String? finalPrice,
    String? discountPercent,
    String? discountAmount,
    String? subtotal,
    String? catename,
    List<String>? productImages,
  }) =>
      Itemlist(
        itemId: itemId ?? this.itemId,
        productId: productId ?? this.productId,
        productSku: productSku ?? this.productSku,
        productName: productName ?? this.productName,
        itemStatus: itemStatus ?? this.itemStatus,
        productOptions: productOptions ?? this.productOptions,
        qtyOrdered: qtyOrdered ?? this.qtyOrdered,
        qtyCanceled: qtyCanceled ?? this.qtyCanceled,
        qtyShipped: qtyShipped ?? this.qtyShipped,
        price: price ?? this.price,
        finalPrice: finalPrice ?? this.finalPrice,
        discountPercent: discountPercent ?? this.discountPercent,
        discountAmount: discountAmount ?? this.discountAmount,
        subtotal: subtotal ?? this.subtotal,
        catename: catename ?? this.catename,
        productImages: productImages ?? this.productImages,
      );

  factory Itemlist.fromJson(Map<String, dynamic> json) => Itemlist(
        itemId: json["item_id"],
        productId: json["product_id"],
        productSku: json["product_sku"],
        productName: json["product_name"],
        itemStatus: json["item_status"],
        productOptions: json["product_options"],
        qtyOrdered: json["qty_ordered"],
        qtyCanceled: json["qty_canceled"],
        qtyShipped: json["qty_shipped"],
        price: json["price"],
        finalPrice: json["final_price"],
        discountPercent: json["discount_percent"],
        discountAmount: json["discount_amount"],
        subtotal: json["subtotal"],
        catename: json["catename"],
        productImages: List<String>.from(json["product_images"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "item_id": itemId,
        "product_id": productId,
        "product_sku": productSku,
        "product_name": productName,
        "item_status": itemStatus,
        "product_options": productOptions,
        "qty_ordered": qtyOrdered,
        "qty_canceled": qtyCanceled,
        "qty_shipped": qtyShipped,
        "price": price,
        "final_price": finalPrice,
        "discount_percent": discountPercent,
        "discount_amount": discountAmount,
        "subtotal": subtotal,
        "catename": catename,
        "product_images": List<dynamic>.from(productImages.map((x) => x)),
      };
}
