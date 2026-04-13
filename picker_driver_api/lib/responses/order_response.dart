// To parse this JSON data, do
//
//     final orderResponse = orderResponseFromJson(jsonString);

import 'dart:convert';

OrderResponse orderResponseFromJson(String str) =>
    OrderResponse.fromJson(json.decode(str));

String orderResponseToJson(OrderResponse data) => json.encode(data.toJson());

class OrderResponse {
  List<Order> items;

  OrderResponse({required this.items});

  OrderResponse copyWith({List<Order>? items}) =>
      OrderResponse(items: items ?? this.items);

  factory OrderResponse.fromJson(Map<String, dynamic> json) => OrderResponse(
    items: List<Order>.from(json["items"].map((x) => Order.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class Order {
  int entityId;
  String subgroupIdentifier;
  String status;
  String type;
  DateTime deliveryFrom;
  DateTime deliveryTo;
  String grandTotal;
  dynamic shippedAmount;
  dynamic statusType;
  String? deliveryTimerange;
  String customerFirstname;
  dynamic customerLastname;
  String billingStreet;
  String customerEmail;
  String postcode;
  String? buildingNumber;
  String telephone;
  String latitude;
  String longitude;
  String paymentMethod;
  String deliveryNote;
  String? addressLabel;
  dynamic buildingName;
  dynamic flatNumber;
  dynamic floorNumber;
  Items items;
  int itemCount;
  String shippingCharges;
  DateTime createdAt;

  Order({
    required this.entityId,
    required this.subgroupIdentifier,
    required this.status,
    required this.type,
    required this.deliveryFrom,
    required this.deliveryTo,
    required this.grandTotal,
    required this.shippedAmount,
    required this.statusType,
    required this.deliveryTimerange,
    required this.customerFirstname,
    required this.customerLastname,
    required this.billingStreet,
    required this.customerEmail,
    required this.postcode,
    required this.buildingNumber,
    required this.telephone,
    required this.latitude,
    required this.longitude,
    required this.paymentMethod,
    required this.deliveryNote,
    required this.addressLabel,
    required this.buildingName,
    required this.flatNumber,
    required this.floorNumber,
    required this.items,
    required this.itemCount,
    required this.shippingCharges,
    required this.createdAt,
  });

  Order copyWith({
    int? entityId,
    String? subgroupIdentifier,
    String? status,
    String? type,
    DateTime? deliveryFrom,
    DateTime? deliveryTo,
    String? grandTotal,
    dynamic shippedAmount,
    dynamic statusType,
    String? deliveryTimerange,
    String? customerFirstname,
    dynamic customerLastname,
    String? billingStreet,
    String? customerEmail,
    String? postcode,
    String? buildingNumber,
    String? telephone,
    String? latitude,
    String? longitude,
    String? paymentMethod,
    String? deliveryNote,
    String? addressLabel,
    dynamic buildingName,
    dynamic flatNumber,
    dynamic floorNumber,
    Items? items,
    int? itemCount,
    String? shippingCharges,
    DateTime? createdAt,
  }) => Order(
    entityId: entityId ?? this.entityId,
    subgroupIdentifier: subgroupIdentifier ?? this.subgroupIdentifier,
    status: status ?? this.status,
    type: type ?? this.type,
    deliveryFrom: deliveryFrom ?? this.deliveryFrom,
    deliveryTo: deliveryTo ?? this.deliveryTo,
    grandTotal: grandTotal ?? this.grandTotal,
    shippedAmount: shippedAmount ?? this.shippedAmount,
    statusType: statusType ?? this.statusType,
    deliveryTimerange: deliveryTimerange ?? this.deliveryTimerange,
    customerFirstname: customerFirstname ?? this.customerFirstname,
    customerLastname: customerLastname ?? this.customerLastname,
    billingStreet: billingStreet ?? this.billingStreet,
    customerEmail: customerEmail ?? this.customerEmail,
    postcode: postcode ?? this.postcode,
    buildingNumber: buildingNumber ?? this.buildingNumber,
    telephone: telephone ?? this.telephone,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    deliveryNote: deliveryNote ?? this.deliveryNote,
    addressLabel: addressLabel ?? this.addressLabel,
    buildingName: buildingName ?? this.buildingName,
    flatNumber: flatNumber ?? this.flatNumber,
    floorNumber: floorNumber ?? this.floorNumber,
    items: items ?? this.items,
    itemCount: itemCount ?? this.itemCount,
    shippingCharges: shippingCharges ?? this.shippingCharges,
    createdAt: createdAt ?? this.createdAt,
  );

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    entityId: json["entity_id"],
    subgroupIdentifier: json["subgroup_identifier"],
    status: json["status"],
    type: json["type"],
    deliveryFrom: DateTime.parse(json["delivery_from"]),
    deliveryTo: DateTime.parse(json["delivery_to"]),
    grandTotal: json["grand_total"].toString(),
    shippedAmount: json["shipped_amount"],
    statusType: json["status_type"],
    deliveryTimerange: json["delivery_timerange"],
    customerFirstname: json["customer_firstname"],
    customerLastname: json["customer_lastname"],
    billingStreet: json["billing_street"],
    customerEmail: json["customer_email"] ?? "",
    postcode: json["postcode"] ?? "",
    buildingNumber: json["building_number"] ?? "",
    telephone: json["telephone"] ?? "",
    latitude: json["latitude"] ?? "",
    longitude: json["longitude"] ?? "",
    paymentMethod: json["payment_method"] ?? "",
    deliveryNote: json["delivery_note"] ?? "",
    addressLabel: json["address_label"] ?? "",
    buildingName: json["building_name"] ?? "",
    flatNumber: json["flat_number"] ?? "",
    floorNumber: json["floor_number"] ?? "",
    items: Items.fromJson(json["items"]),
    itemCount: json["item_count"],
    shippingCharges: json["shipping_charge"] ?? "0",
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "entity_id": entityId,
    "subgroup_identifier": subgroupIdentifier,
    "status": status,
    "type": type,
    "delivery_from": deliveryFrom.toIso8601String(),
    "delivery_to": deliveryTo.toIso8601String(),
    "grand_total": grandTotal,
    "shipped_amount": shippedAmount,
    "status_type": statusType,
    "delivery_timerange": deliveryTimerange,
    "customer_firstname": customerFirstname,
    "customer_lastname": customerLastname,
    "billing_street": billingStreet,
    "customer_email": customerEmail,
    "postcode": postcode,
    "building_number": buildingNumber,
    "telephone": telephone,
    "latitude": latitude,
    "longitude": longitude,
    "payment_method": paymentMethod,
    "delivery_note": deliveryNote,
    "address_label": addressLabel,
    "building_name": buildingName,
    "flat_number": flatNumber,
    "floor_number": floorNumber,
    "items": items.toJson(),
    "item_count": itemCount,
    "shipping_charges": shippingCharges,
    "created_at": createdAt.toIso8601String(),
  };
}

class Items {
  List<EndPicking>? assignedPicker;
  List<EndPicking> endPicking;
  List<EndPicking>? canceled;
  List<EndPicking>? itemNotAvailable;
  List<EndPicking>? holded;
  List<EndPicking>? startPicking;
  List<EndPicking>? materialRequest;
  List<EndPicking>? assignedDriver;
  List<EndPicking>? onTheWay;

  Items({
    this.assignedPicker,
    required this.endPicking,
    this.canceled,
    this.itemNotAvailable,
    this.holded,
    this.startPicking,
    this.materialRequest,
    this.assignedDriver,
    this.onTheWay,
  });

  Items copyWith({
    List<EndPicking>? assignedPicker,
    List<EndPicking>? endPicking,
    List<EndPicking>? canceled,
    List<EndPicking>? itemNotAvailable,
    List<EndPicking>? holded,
    List<EndPicking>? startPicking,
    List<EndPicking>? materialRequest,
    List<EndPicking>? assignedDriver,
    List<EndPicking>? onTheWay,
  }) => Items(
    assignedPicker: assignedPicker ?? this.assignedPicker,
    endPicking: endPicking ?? this.endPicking,
    canceled: canceled ?? this.canceled,
    itemNotAvailable: itemNotAvailable ?? this.itemNotAvailable,
    holded: holded ?? this.holded,
    startPicking: startPicking ?? this.startPicking,
    materialRequest: materialRequest ?? this.materialRequest,
    assignedDriver: assignedDriver ?? this.assignedDriver,
    onTheWay: onTheWay ?? this.onTheWay,
  );

  factory Items.fromJson(Map<String, dynamic> json) => Items(
    assignedPicker:
        json["assigned_picker"] == null
            ? []
            : List<EndPicking>.from(
              json["assigned_picker"]!.map((x) => EndPicking.fromJson(x)),
            ),
    endPicking:
        json["end_picking"] == null
            ? []
            : List<EndPicking>.from(
              json["end_picking"].map((x) => EndPicking.fromJson(x)),
            ),
    canceled:
        json["canceled"] == null
            ? []
            : List<EndPicking>.from(
              json["canceled"]!.map((x) => EndPicking.fromJson(x)),
            ),
    itemNotAvailable:
        json["item_not_available"] == null
            ? []
            : List<EndPicking>.from(
              json["item_not_available"]!.map((x) => EndPicking.fromJson(x)),
            ),
    holded:
        json["holded"] == null
            ? []
            : List<EndPicking>.from(
              json["holded"]!.map((x) => EndPicking.fromJson(x)),
            ),
    startPicking:
        json["start_picking"] == null
            ? []
            : List<EndPicking>.from(
              json["start_picking"]!.map((x) => EndPicking.fromJson(x)),
            ),
    materialRequest:
        json["material_request"] == null
            ? []
            : List<EndPicking>.from(
              json["material_request"]!.map((x) => EndPicking.fromJson(x)),
            ),
    assignedDriver:
        json["assigned_driver"] == null
            ? []
            : List<EndPicking>.from(
              json["assigned_driver"]!.map((x) => EndPicking.fromJson(x)),
            ),
    onTheWay:
        json["on_the_way"] == null
            ? []
            : List<EndPicking>.from(
              json["on_the_way"]!.map((x) => EndPicking.fromJson(x)),
            ),
  );

  Map<String, dynamic> toJson() => {
    "assigned_picker":
        assignedPicker == null
            ? []
            : List<dynamic>.from(assignedPicker!.map((x) => x.toJson())),
    "end_picking": List<dynamic>.from(endPicking.map((x) => x.toJson())),
    "canceled":
        canceled == null
            ? []
            : List<dynamic>.from(canceled!.map((x) => x.toJson())),
    "item_not_available":
        itemNotAvailable == null
            ? []
            : List<dynamic>.from(itemNotAvailable!.map((x) => x.toJson())),
    "holded":
        holded == null
            ? []
            : List<dynamic>.from(holded!.map((x) => x.toJson())),
    "start_picking":
        startPicking == null
            ? []
            : List<dynamic>.from(startPicking!.map((x) => x.toJson())),
    "material_request":
        materialRequest == null
            ? []
            : List<dynamic>.from(materialRequest!.map((x) => x.toJson())),
    "assigned_driver":
        assignedDriver == null
            ? []
            : List<dynamic>.from(assignedDriver!.map((x) => x.toJson())),
    "on_the_way":
        onTheWay == null
            ? []
            : List<dynamic>.from(onTheWay!.map((x) => x.toJson())),
  };
}

class EndPicking {
  int itemId;
  int productId;
  String productSku;
  String productName;
  String itemStatus;
  Map<String, dynamic> productOptions;
  String qtyOrdered;
  String qtyCanceled;
  String qtyShipped;
  String price;
  String finalPrice;
  String discountPercent;
  String discountAmount;
  String weight;
  String subtotal;
  String isProduce;
  int categoryId;
  String branchName;
  String catname;
  List<String> productImages;
  String weightUnit;
  String isproduce;
  String itemWeight;

  EndPicking({
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
    required this.weight,
    required this.subtotal,
    required this.isProduce,
    required this.categoryId,
    required this.branchName,
    required this.catname,
    required this.productImages,
    required this.weightUnit,
    required this.isproduce,
    required this.itemWeight,
  });

  EndPicking copyWith({
    int? itemId,
    int? productId,
    String? productSku,
    String? productName,
    String? itemStatus,
    Map<String, dynamic>? productOptions,
    String? qtyOrdered,
    String? qtyCanceled,
    String? qtyShipped,
    String? price,
    String? finalPrice,
    String? discountPercent,
    String? discountAmount,
    String? weight,
    String? subtotal,
    String? isProduce,
    int? categoryId,
    String? catname,
    List<String>? productImages,
    String? weightUnit,
    String? isproduce,
  }) => EndPicking(
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
    weight: weight ?? this.weight,
    subtotal: subtotal ?? this.subtotal,
    isProduce: isProduce ?? this.isProduce,
    categoryId: categoryId ?? this.categoryId,
    catname: catname ?? this.catname,
    productImages: productImages ?? this.productImages,
    weightUnit: weightUnit ?? this.weightUnit,
    isproduce: isproduce ?? this.isproduce,
    itemWeight: itemWeight ?? this.itemWeight,
    branchName: branchName ?? this.branchName,
  );

  factory EndPicking.fromJson(Map<String, dynamic> json) => EndPicking(
    itemId: json["item_id"] ?? 0,
    productId: json["product_id"] ?? 0,
    productSku: json["product_sku"] ?? "",
    productName: json["product_name"] ?? "",
    itemStatus: json["item_status"] ?? "",
    productOptions: jsonDecode(json["product_options"] ?? "{}"),
    qtyOrdered: json["qty_ordered"] ?? 0,
    qtyCanceled: json["qty_canceled"] ?? 0,
    qtyShipped: json["qty_shipped"] ?? 0,
    price: json["price"] ?? 0,
    finalPrice: json["final_price"] ?? 0,
    discountPercent: json["discount_percent"] ?? 0,
    discountAmount: json["discount_amount"],
    weight: json["weight"] ?? "",
    subtotal: json["subtotal"] ?? "",
    isProduce: json["is_produce"],
    categoryId:
        json["category_id"] == null
            ? 2
            : int.parse(json["category_id"].toString()),
    branchName: json["branch_name"] ?? "",
    catname: json["catname"] ?? "",
    productImages: List<String>.from(json["product_images"].map((x) => x)),
    weightUnit: json["weight_unit"],
    isproduce: json["is_produce"] != null ? json["is_produce"].toString() : "0",
    itemWeight: json["weight"],
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
    "weight": weight,
    "subtotal": subtotal,
    "is_produce": isProduce,
    "category_id": categoryId,
    "branch_name": branchName,
    "catname": catname,
    "product_images": List<dynamic>.from(productImages.map((x) => x)),
    "weight_unit": weightUnit,
    "isproduce": isproduce,
    "item_weight": itemWeight,
  };
}
