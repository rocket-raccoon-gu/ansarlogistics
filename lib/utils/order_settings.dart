class OrderSettings {
  OrderSettings({
    this.entityid = "",
    this.incrementid = "",
    this.subgroupidentifier = "",
    this.status = "",
    this.type = "",
    required this.deliveryfrom,
    required this.deliveryto,
    this.grand_total = "",
    this.shipped_amount = "",
    this.status_type = "",
    this.delivery_timerange = "",
    this.customer_firstname = "",
    this.customer_lastname = "",
    this.billing_street = "",
    this.customer_email = "",
    this.postcode = "",
    this.telephone = "",
    this.latitude = "",
    this.longitude = "",
    this.payment_method = "",
    this.delivery_note = "",
    required this.items,
  });
  String entityid;
  String incrementid;
  String subgroupidentifier;
  String status;
  String type;
  DateTime deliveryfrom = DateTime.now();
  DateTime deliveryto = DateTime.now();
  String grand_total;
  String shipped_amount;
  String status_type;
  String delivery_timerange;
  String customer_firstname;
  String customer_lastname;
  String billing_street;
  String customer_email;
  String postcode;
  String telephone;
  String latitude;
  String longitude;
  String payment_method;
  String delivery_note;
  List<ItemItem> items = [];

  factory OrderSettings.fromJson(Map<String, dynamic> json) => OrderSettings(
    entityid: json['entity_id'],
    incrementid: json['increment_id'] ?? "",
    subgroupidentifier: json['subgroup_identifier'] ?? "",
    status: json['status'],
    type: json['type'],
    grand_total: json['grand_total'],
    shipped_amount: json['grand_total'],
    status_type: json['status_type'],
    customer_firstname: json['customer_firstname'],
    customer_lastname: json['customer_lastname'],
    billing_street: json['billing_street'],
    customer_email: json["customer_email"],
    postcode: json["postcode"],
    telephone: json["telephone"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    payment_method: json["payment_method"],
    delivery_note: json["delivery_note"],
    items: List<ItemItem>.from(json["items"].map((x) => ItemItem.fromJson(x))),
    // deliveryfrom: json['delivery_from'] ?? DateTime.now(),
    // deliveryto: json['delivery_to'] ?? DateTime.now()
    deliveryfrom: DateTime.now(),
    deliveryto: DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    "entity_id": entityid,
    "increment_id": incrementid,
    "subgroup_identifier": subgroupidentifier,
    "status": status,
    "type": type,
    "delivery_from": deliveryfrom.toIso8601String(),
    "delivery_to": deliveryto.toIso8601String(),
    "grand_total": grand_total,
    "shipped_amount": shipped_amount,
    "status_type": status_type,
    "delivery_timerange": delivery_timerange,
    "customer_firstname": customer_firstname,
    "customer_lastname": customer_lastname,
    "billing_street": billing_street,
    "customer_email": customer_email,
    "postcode": postcode,
    "telephone": telephone,
    "latitude": latitude,
    "longitude": longitude,
    "payment_method": payment_method,
    "delivery_note": delivery_note,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };

  OrderSettings copyWith({
    String? entityid,
    String? incrementid,
    String? subgroupidentifier,
    String? status,
    String? type,
    DateTime? deliveryfrom,
    DateTime? deliveryto,
    String? grand_total,
    String? shipped_amount,
    String? status_type,
    String? delivery_timerange,
    String? customer_firstname,
    String? customer_lastname,
    String? billing_street,
    String? customer_email,
    String? postcode,
    String? telephone,
    String? latitude,
    String? longitude,
    String? payment_method,
    String? delivery_note,
    List<ItemItem>? items,
  }) => OrderSettings(
    deliveryfrom: deliveryfrom ?? this.deliveryfrom,
    deliveryto: deliveryto ?? this.deliveryto,
    items: items ?? this.items,
  );
}

class ItemItem {
  String itemId;
  String productSku;
  String productName;
  String itemStatus;
  String productOptions;
  String qtyOrdered;
  String qtyCanceled;
  String qtyShipped;
  String qtyRefunded;
  String price;
  String finalPrice;
  String discountPercent;
  String discountAmount;
  String subtotal;
  List<String> categoryListId;
  List<String> productImages;

  ItemItem({
    required this.itemId,
    required this.productSku,
    required this.productName,
    required this.itemStatus,
    required this.productOptions,
    required this.qtyOrdered,
    required this.qtyCanceled,
    required this.qtyShipped,
    required this.qtyRefunded,
    required this.price,
    required this.finalPrice,
    required this.discountPercent,
    required this.discountAmount,
    required this.subtotal,
    required this.categoryListId,
    required this.productImages,
  });

  ItemItem copyWith({
    String? itemId,
    String? productSku,
    String? productName,
    String? itemStatus,
    String? productOptions,
    String? qtyOrdered,
    String? qtyCanceled,
    String? qtyShipped,
    String? qtyRefunded,
    String? price,
    String? finalPrice,
    String? discountPercent,
    String? discountAmount,
    String? subtotal,
    List<String>? categoryListId,
    List<String>? productImages,
  }) {
    return ItemItem(
      itemId: itemId ?? this.itemId,
      productSku: productSku ?? this.productSku,
      productName: productName ?? this.productName,
      itemStatus: itemStatus ?? this.itemStatus,
      productOptions: productOptions ?? this.productOptions,
      qtyOrdered: qtyOrdered ?? this.qtyOrdered,
      qtyCanceled: qtyCanceled ?? this.qtyCanceled,
      qtyShipped: qtyShipped ?? this.qtyShipped,
      qtyRefunded: qtyRefunded ?? this.qtyRefunded,
      price: price ?? this.price,
      finalPrice: finalPrice ?? this.finalPrice,
      discountPercent: discountPercent ?? this.discountPercent,
      discountAmount: discountAmount ?? this.discountAmount,
      subtotal: subtotal ?? this.subtotal,
      categoryListId: categoryListId ?? this.categoryListId,
      productImages: productImages ?? this.productImages,
    );
  }

  factory ItemItem.fromJson(Map<String, dynamic> json) => ItemItem(
    itemId: json["item_id"]?.toString() ?? "",
    productSku: json["product_sku"]?.toString() ?? "",
    productName: json["product_name"]?.toString() ?? "",
    itemStatus: json["item_status"]?.toString() ?? "",
    productOptions: json["product_options"]?.toString() ?? "",
    qtyOrdered: json["qty_ordered"]?.toString() ?? "",
    qtyCanceled: json["qty_canceled"]?.toString() ?? "",
    qtyShipped: json["qty_shipped"]?.toString() ?? "",
    qtyRefunded: json["qty_refunded"]?.toString() ?? "",
    price: json["price"]?.toString() ?? "",
    finalPrice: json["final_price"]?.toString() ?? "",
    discountPercent: json["discount_percent"]?.toString() ?? "",
    discountAmount: json["discount_amount"]?.toString() ?? "",
    subtotal: json["subtotal"]?.toString() ?? "",
    categoryListId:
        (json["category_list_id"] as List?)
            ?.map((x) => x?.toString() ?? "")
            .where((x) => x.isNotEmpty)
            .toList() ??
        [],
    productImages:
        (json["product_images"] as List?)
            ?.map((x) => x?.toString() ?? "")
            .where((x) => x.isNotEmpty)
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    "item_id": itemId,
    "product_sku": productSku,
    "product_name": productName,
    "item_status": itemStatus,
    "product_options": productOptions,
    "qty_ordered": qtyOrdered,
    "qty_canceled": qtyCanceled,
    "qty_shipped": qtyShipped,
    "qty_refunded": qtyRefunded,
    "price": price,
    "final_price": finalPrice,
    "discount_percent": discountPercent,
    "discount_amount": discountAmount,
    "subtotal": subtotal,
    "category_list_id": categoryListId,
    "product_images": productImages,
  };
}
