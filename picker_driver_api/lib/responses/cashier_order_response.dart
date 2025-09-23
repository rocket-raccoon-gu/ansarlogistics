// To parse this JSON data, do
//
//     final cashierOrders = cashierOrdersFromJson(jsonString);

import 'dart:convert';

CashierOrders cashierOrdersFromJson(String str) =>
    CashierOrders.fromJson(json.decode(str));

String cashierOrdersToJson(CashierOrders data) => json.encode(data.toJson());

class CashierOrders {
  bool success;
  int count;
  int totalCount;
  Pagination pagination;
  List<Datum> data;

  CashierOrders({
    required this.success,
    required this.count,
    required this.totalCount,
    required this.pagination,
    required this.data,
  });

  factory CashierOrders.fromJson(Map<String, dynamic> json) => CashierOrders(
    success: json["success"],
    count: json["count"] ?? 0,
    totalCount: json["totalCount"] ?? 0,
    pagination: Pagination.fromJson(json["pagination"] ?? {}),
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "count": count,
    "totalCount": totalCount,
    "pagination": pagination.toJson(),
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  String subgroupIdentifier;
  BranchCode branchCode;
  int suborderId;
  int orderSychNo;
  int orderId;
  String orderStatus;
  dynamic statusType;
  DateTime deliveryFrom;
  DateTime? deliveryTo;
  String? timerange;
  int pickerId;
  int? driverId;
  int driverFlag;
  DateTime createdAt;
  DateTime updatedAt;
  String orderAmount;
  String shippedAmount;
  String shippingCharge;
  dynamic discountValue;
  dynamic discountType;
  String grandTotal;
  dynamic posAmount;
  String? onlinePaidAmount;
  int orderModifyNotification;
  String? driverLat;
  String? driverLong;
  String shipmentLabel;
  String preparationLabel;
  String firstname;
  dynamic lastname;
  String street;
  String? city;
  String? region;
  String postcode;
  String telephone;
  CountryId countryId;
  dynamic company;
  List<Item> items;
  List<String> combinedSubgroupIdentifiers;
  int calculatedShippingCharge;
  double combinedGrandTotal;
  bool isCombinedShipping;
  String? deliveryNote;
  String? pickername;
  String? drivername;
  String? paymentMethod;
  StatusHistory? statusHistory;
  int isWhatsappOrder;
  String? endPickTotal;
  String? driverType;

  Datum({
    required this.subgroupIdentifier,
    required this.branchCode,
    required this.suborderId,
    required this.orderSychNo,
    required this.orderId,
    required this.orderStatus,
    required this.statusType,
    required this.deliveryFrom,
    required this.deliveryTo,
    required this.timerange,
    required this.pickerId,
    required this.driverId,
    required this.driverFlag,
    required this.createdAt,
    required this.updatedAt,
    required this.orderAmount,
    required this.shippedAmount,
    required this.shippingCharge,
    required this.discountValue,
    required this.discountType,
    required this.grandTotal,
    required this.posAmount,
    required this.onlinePaidAmount,
    required this.orderModifyNotification,
    required this.driverLat,
    required this.driverLong,
    required this.shipmentLabel,
    required this.preparationLabel,
    required this.firstname,
    required this.lastname,
    required this.street,
    required this.city,
    required this.region,
    required this.postcode,
    required this.telephone,
    required this.countryId,
    required this.company,
    required this.items,
    required this.combinedSubgroupIdentifiers,
    required this.calculatedShippingCharge,
    required this.combinedGrandTotal,
    required this.isCombinedShipping,
    required this.deliveryNote,
    required this.pickername,
    required this.drivername,
    required this.paymentMethod,
    required this.statusHistory,
    required this.isWhatsappOrder,
    required this.endPickTotal,
    required this.driverType,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    subgroupIdentifier: json["subgroup_identifier"],
    branchCode: branchCodeValues.map[json["branch_code"]]!,
    suborderId: json["suborder_id"] ?? 0,
    orderSychNo: json["order_sych_no"] ?? 0,
    orderId: json["order_id"] ?? 0,
    orderStatus: json["order_status"] ?? "",
    statusType: json["status_type"] ?? "",
    deliveryFrom: DateTime.parse(json["delivery_from"]),
    deliveryTo:
        json["delivery_to"] == null
            ? null
            : DateTime.parse(json["delivery_to"]),
    timerange: json["timerange"],
    pickerId: json["picker_id"] ?? 0,
    driverId: json["driver_id"] ?? 0,
    driverFlag: json["driver_flag"] ?? 0,
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    orderAmount: json["order_amount"],
    shippedAmount: json["shipped_amount"] ?? "",
    shippingCharge: json["shipping_charge"] ?? "",
    discountValue: json["discount_value"] ?? "",
    discountType: json["discount_type"] ?? "",
    grandTotal: json["grand_total"].toString(),
    posAmount: json["pos_amount"] ?? "",
    onlinePaidAmount: json["online_paid_amount"]?.toString() ?? "",
    orderModifyNotification: json["order_modify_notification"] ?? 0,
    driverLat: json["driver_lat"] ?? "",
    driverLong: json["driver_long"] ?? "",
    shipmentLabel: json["shipment_label"] ?? "",
    preparationLabel: json["preparation_label"] ?? "",
    firstname: json["firstname"] ?? "",
    lastname: json["lastname"] ?? "",
    street: json["street"] ?? "",
    city: json["city"] ?? "",
    region: json["region"] ?? "",
    postcode: json["postcode"] ?? "",
    telephone: json["telephone"] ?? "",
    countryId: countryIdValues.map[json["country_id"]]!,
    company: json["company"] ?? "",
    items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
    combinedSubgroupIdentifiers: List<String>.from(
      json["combined_subgroup_identifiers"].map((x) => x),
    ),
    calculatedShippingCharge: json["calculated_shipping_charge"] ?? 0,
    combinedGrandTotal: json["combined_grand_total"]?.toDouble() ?? 0,
    isCombinedShipping: json["is_combined_shipping"] ?? false,
    deliveryNote: json["delivery_note"] ?? "",
    pickername: json["picker_name"] ?? "",
    drivername: json["driver_name"] ?? "",
    paymentMethod: json["payment_method"] ?? "",
    statusHistory:
        json["status_history"] == null
            ? null
            : StatusHistory.fromJson(json["status_history"]),
    isWhatsappOrder: json["is_whatsapp_order"] ?? 0,
    endPickTotal: json["end_picked_total"].toString(),
    driverType: json["driver_type"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "subgroup_identifier": subgroupIdentifier,
    "branch_code": branchCodeValues.reverse[branchCode],
    "suborder_id": suborderId,
    "order_sych_no": orderSychNo,
    "order_id": orderId,
    "order_status": orderStatus,
    "status_type": statusType,
    "delivery_from": deliveryFrom.toIso8601String(),
    "delivery_to": deliveryTo?.toIso8601String(),
    "timerange": timerange,
    "picker_id": pickerId ?? 0,
    "driver_id": driverId ?? 0,
    "driver_flag": driverFlag ?? 0,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "order_amount": orderAmount,
    "shipped_amount": shippedAmount,
    "shipping_charge": shippingCharge,
    "discount_value": discountValue ?? "",
    "discount_type": discountType ?? "",
    "grand_total": grandTotal,
    "pos_amount": posAmount,
    "online_paid_amount": onlinePaidAmount,
    "order_modify_notification": orderModifyNotification,
    "driver_lat": driverLat,
    "driver_long": driverLong,
    "shipment_label": shipmentLabel,
    "preparation_label": preparationLabel,
    "firstname": firstname,
    "lastname": lastname,
    "street": street,
    "city": city,
    "region": region,
    "postcode": postcode,
    "telephone": telephone,
    "country_id": countryIdValues.reverse[countryId],
    "company": company,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
    "combined_subgroup_identifiers": List<dynamic>.from(
      combinedSubgroupIdentifiers.map((x) => x),
    ),
    "calculated_shipping_charge": calculatedShippingCharge,
    "combined_grand_total": combinedGrandTotal,
    "is_combined_shipping": isCombinedShipping,
    "delivery_note": deliveryNote,
    "picker_name": pickername,
    "driver_name": drivername,
    "payment_method": paymentMethod,
    "status_history": statusHistory?.toJson(),
    "is_whatsapp_order": isWhatsappOrder,
    "end_picked_total": endPickTotal,
    "driver_type": driverType,
  };
}

enum BranchCode { Q013 }

final branchCodeValues = EnumValues({"Q013": BranchCode.Q013});

enum CountryId { QA }

final countryIdValues = EnumValues({"QA": CountryId.QA});

class Item {
  int itemId;
  int productId;
  String sku;
  String name;
  String price;
  String itemType;
  String itemStatus;
  String qtyOrdered;
  String qtyShipped;
  String qtyCanceled;
  String rowTotal;
  String finalPrice;
  String webprice;
  String? imageurl;
  String? productName;

  Item({
    required this.itemId,
    required this.productId,
    required this.sku,
    required this.name,
    required this.price,
    required this.itemType,
    required this.itemStatus,
    required this.qtyOrdered,
    required this.qtyShipped,
    required this.qtyCanceled,
    required this.rowTotal,
    required this.finalPrice,
    required this.webprice,
    required this.imageurl,
    required this.productName,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    itemId: json["item_id"] ?? 0,
    productId: json["product_id"] ?? 0,
    sku: json["sku"] ?? "",
    name: json["name"] ?? "",
    price: json["price"] ?? "",
    itemType: json["item_type"] ?? "",
    itemStatus: json["item_status"] ?? "",
    qtyOrdered: json["qty_ordered"] ?? "",
    qtyShipped: json["qty_shipped"] ?? "",
    qtyCanceled: json["qty_canceled"] ?? "",
    rowTotal: json["row_total"] ?? "",
    finalPrice: json["final_price"] ?? "",
    webprice: json["web_price"] ?? "",
    imageurl: json["image_url"] ?? "",
    productName: json["product_name"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "item_id": itemId,
    "product_id": productId,
    "sku": sku,
    "name": name,
    "price": price,
    "item_type": itemType,
    "item_status": itemStatus,
    "qty_ordered": qtyOrdered,
    "qty_shipped": qtyShipped,
    "qty_canceled": qtyCanceled,
    "row_total": rowTotal,
    "final_price": finalPrice,
    "webprice": webprice,
    "image_url": imageurl,
    "product_name": productName,
  };
}

enum ItemType { ORDERED }

final itemTypeValues = EnumValues({"ordered": ItemType.ORDERED});

class Pagination {
  int currentPage;
  int totalPages;
  int totalItems;
  int itemsPerPage;
  bool hasNext;
  bool hasPrev;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNext,
    required this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["currentPage"] ?? 0,
    totalPages: json["totalPages"] ?? 0,
    totalItems: json["totalItems"] ?? 0,
    itemsPerPage: json["itemsPerPage"] ?? 0,
    hasNext: json["hasNext"] ?? false,
    hasPrev: json["hasPrev"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "currentPage": currentPage,
    "totalPages": totalPages,
    "totalItems": totalItems,
    "itemsPerPage": itemsPerPage,
    "hasNext": hasNext,
    "hasPrev": hasPrev,
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

class StatusHistory {
  String status;
  DateTime createdAt;

  StatusHistory({required this.status, required this.createdAt});

  factory StatusHistory.fromJson(Map<String, dynamic> json) => StatusHistory(
    status: json["status"],
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "created_at": createdAt.toIso8601String(),
  };
}
