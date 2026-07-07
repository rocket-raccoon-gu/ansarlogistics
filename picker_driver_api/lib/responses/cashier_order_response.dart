// To parse this JSON data, do
//
//     final cashierOrders = cashierOrdersFromJson(jsonString);

import 'dart:convert';

CashierOrders cashierOrdersFromJson(String str) =>
    CashierOrders.fromJson(json.decode(str));

String cashierOrdersToJson(CashierOrders data) => json.encode(data.toJson());

CashierOrder cashierOrderFromJson(String str) =>
    CashierOrder.fromJson(json.decode(str));

String cashierOrderToJson(CashierOrder data) => json.encode(data.toJson());

class CashierOrder {
  String orderReference;
  String outletCode;
  String outletAddressCode;
  OutletName outletName;
  String clientCode;
  DropOffAddress dropOffAddress;
  double codValue;
  double prepaidValue;
  int packageCount;
  String packageType;
  List<String> tags;
  String deliveryNotes;
  double riderTip;
  bool isTesting;

  CashierOrder({
    required this.orderReference,
    required this.outletCode,
    required this.outletAddressCode,
    required this.outletName,
    required this.clientCode,
    required this.dropOffAddress,
    required this.codValue,
    required this.prepaidValue,
    required this.packageCount,
    required this.packageType,
    required this.tags,
    required this.deliveryNotes,
    required this.riderTip,
    required this.isTesting,
  });

  factory CashierOrder.fromJson(Map<String, dynamic> json) => CashierOrder(
    orderReference: json["order_reference"] ?? "",
    outletCode: json["outlet_code"] ?? "",
    outletAddressCode: json["outlet_address_code"] ?? "",
    outletName: OutletName.fromJson(json["outlet_name"] ?? {}),
    clientCode: json["client_code"] ?? "",
    dropOffAddress: DropOffAddress.fromJson(json["drop_off_address"] ?? {}),
    codValue:
        (json["cod_value"] is num)
            ? (json["cod_value"] as num).toDouble()
            : double.tryParse('${json["cod_value"] ?? 0}') ?? 0,
    prepaidValue:
        (json["prepaid_value"] is num)
            ? (json["prepaid_value"] as num).toDouble()
            : double.tryParse('${json["prepaid_value"] ?? 0}') ?? 0,
    packageCount:
        json["package_count"] is int
            ? json["package_count"]
            : int.tryParse('${json["package_count"] ?? 0}') ?? 0,
    packageType: json["package_type"] ?? "",
    tags:
        json["tags"] is List
            ? List<String>.from(json["tags"].map((x) => x.toString()))
            : <String>[],
    deliveryNotes: json["delivery_notes"] ?? "",
    riderTip:
        (json["rider_tip"] is num)
            ? (json["rider_tip"] as num).toDouble()
            : double.tryParse('${json["rider_tip"] ?? 0}') ?? 0,
    isTesting: json["is_testing"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "order_reference": orderReference,
    "outlet_code": outletCode,
    "outlet_address_code": outletAddressCode,
    "outlet_name": outletName.toJson(),
    "client_code": clientCode,
    "drop_off_address": dropOffAddress.toJson(),
    "cod_value": codValue,
    "prepaid_value": prepaidValue,
    "package_count": packageCount,
    "package_type": packageType,
    "tags": List<dynamic>.from(tags.map((x) => x)),
    "delivery_notes": deliveryNotes,
    "rider_tip": riderTip,
    "is_testing": isTesting,
  };
}

class OutletName {
  String ar;
  String en;

  OutletName({required this.ar, required this.en});

  factory OutletName.fromJson(Map<String, dynamic> json) =>
      OutletName(ar: json["ar"] ?? "", en: json["en"] ?? "");

  Map<String, dynamic> toJson() => {"ar": ar, "en": en};
}

class DropOffAddress {
  double lat;
  double lng;
  String address;
  String contactName;
  String contactPhoneNumber;
  String countryCode;
  String city;

  DropOffAddress({
    required this.lat,
    required this.lng,
    required this.address,
    required this.contactName,
    required this.contactPhoneNumber,
    required this.countryCode,
    required this.city,
  });

  factory DropOffAddress.fromJson(Map<String, dynamic> json) => DropOffAddress(
    lat:
        (json["lat"] is num)
            ? (json["lat"] as num).toDouble()
            : double.tryParse('${json["lat"] ?? 0}') ?? 0,
    lng:
        (json["lng"] is num)
            ? (json["lng"] as num).toDouble()
            : double.tryParse('${json["lng"] ?? 0}') ?? 0,
    address: json["address"] ?? "",
    contactName: json["contact_name"] ?? "",
    contactPhoneNumber: json["contact_phone_number"] ?? "",
    countryCode: json["country_code"] ?? "",
    city: json["city"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "lat": lat,
    "lng": lng,
    "address": address,
    "contact_name": contactName,
    "contact_phone_number": contactPhoneNumber,
    "country_code": countryCode,
    "city": city,
  };
}

class CashierOrders {
  bool success;
  int count;
  int totalCount;
  Pagination pagination;
  List<Datum> data;
  int totalResults;
  String searchKey;

  CashierOrders({
    required this.success,
    required this.count,
    required this.totalCount,
    required this.pagination,
    required this.data,
    required this.totalResults,
    required this.searchKey,
  });

  factory CashierOrders.fromJson(Map<String, dynamic> json) => CashierOrders(
    success: json["success"],
    count: json["count"] ?? json["totalResults"] ?? 0,
    totalCount: json["totalCount"] ?? json["totalResults"] ?? 0,
    pagination: Pagination.fromJson(json["pagination"] ?? {}),
    data: List<Datum>.from((json["data"] ?? []).map((x) => Datum.fromJson(x))),
    totalResults: json["totalResults"] ?? 0,
    searchKey: json["searchKey"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "count": count,
    "totalCount": totalCount,
    "pagination": pagination.toJson(),
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "totalResults": totalResults,
    "searchKey": searchKey,
  };
}

class Datum {
  String subgroupIdentifier;
  String? branchCode;
  int suborderId;
  int orderSychNo;
  int orderId;
  String orderStatus;
  dynamic statusType;
  DateTime? deliveryFrom;
  DateTime? deliveryTo;
  String? timerange;
  int pickerId;
  int? war_picker_id;
  int? driverId;
  int? cashier_id;
  int driverFlag;
  String? driverType;
  String? tracker_id;
  dynamic war_order_status;
  double payment_collected;
  DateTime createdAt;
  DateTime updatedAt;
  String orderAmount;
  String shippedAmount;
  String shippingCharge;
  dynamic discountValue;
  dynamic discountType;
  String grandTotal;
  dynamic posAmount;
  String dueAmount;
  int orderModifyNotification;
  String? driverLat;
  String? driverLong;
  String? shipmentLabel;
  String? preparationLabel;
  String? bill_image;
  String firstname;
  dynamic lastname;
  String street;
  String? city;
  String region;
  String postcode;
  String telephone;
  String countryId;
  dynamic company;
  String? email;
  String deliveryNote;
  String? pickername;
  String? drivername;
  String? cashierName;
  String paymentMethod;
  String? onlinePaidAmount;
  String base_discount_amount;
  String? couponCode;
  int customer_id;
  String increment_id;
  String order_source;
  int is_already_punched_today;
  StatusHistory? statusHistory;
  int isWhatsappOrder;
  List<Item> items;
  List<String> combinedSubgroupIdentifiers;
  int calculatedShippingCharge;
  double combinedGrandTotal;
  bool isCombinedShipping;
  double orderPlacedTotal;
  double endPickedTotal;
  double totalDue;
  double combinedOrderPlacedTotal;
  double combinedEndPickedTotal;
  double combinedOnlinePaidAmount;
  double combinedCalculatedShippingCharge;
  double combinedTotalDue;
  bool isCombinedOrder;
  List<String> relatedOrdersByTracker;

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
    required this.war_picker_id,
    required this.driverId,
    required this.cashier_id,
    required this.driverFlag,
    required this.driverType,
    required this.tracker_id,
    required this.war_order_status,
    required this.payment_collected,
    required this.createdAt,
    required this.updatedAt,
    required this.orderAmount,
    required this.shippedAmount,
    required this.shippingCharge,
    required this.discountValue,
    required this.discountType,
    required this.grandTotal,
    required this.posAmount,
    required this.dueAmount,
    required this.orderModifyNotification,
    required this.driverLat,
    required this.driverLong,
    required this.shipmentLabel,
    required this.preparationLabel,
    required this.bill_image,
    required this.firstname,
    required this.lastname,
    required this.street,
    required this.city,
    required this.region,
    required this.postcode,
    required this.telephone,
    required this.countryId,
    required this.company,
    required this.email,
    required this.deliveryNote,
    required this.pickername,
    required this.drivername,
    required this.cashierName,
    required this.paymentMethod,
    required this.onlinePaidAmount,
    required this.base_discount_amount,
    required this.couponCode,
    required this.customer_id,
    required this.increment_id,
    required this.order_source,
    required this.is_already_punched_today,
    required this.statusHistory,
    required this.isWhatsappOrder,
    required this.items,
    required this.combinedSubgroupIdentifiers,
    required this.calculatedShippingCharge,
    required this.combinedGrandTotal,
    required this.isCombinedShipping,
    required this.orderPlacedTotal,
    required this.endPickedTotal,
    required this.totalDue,
    required this.combinedOrderPlacedTotal,
    required this.combinedEndPickedTotal,
    required this.combinedOnlinePaidAmount,
    required this.combinedCalculatedShippingCharge,
    required this.combinedTotalDue,
    required this.isCombinedOrder,
    required this.relatedOrdersByTracker,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    subgroupIdentifier: json["subgroup_identifier"] ?? "",
    branchCode: json["branch_code"],
    suborderId: json["suborder_id"] ?? 0,
    orderSychNo: json["order_sych_no"] ?? 0,
    orderId: json["order_id"] ?? 0,
    orderStatus: json["order_status"] ?? "",
    statusType: json["status_type"],
    deliveryFrom:
        json["delivery_from"] == null
            ? null
            : DateTime.parse(json["delivery_from"]),
    deliveryTo:
        json["delivery_to"] == null
            ? null
            : DateTime.parse(json["delivery_to"]),
    timerange: json["timerange"],
    pickerId: json["picker_id"] ?? 0,
    war_picker_id:
        json["war_picker_id"].toString().isNotEmpty
            ? int.tryParse(json["war_picker_id"].toString())
            : null,
    driverId: json["driver_id"],
    cashier_id: json["cashier_id"],
    driverFlag: json["driver_flag"] ?? 0,
    driverType: json["driver_type"] ?? "",
    tracker_id: json["tracker_id"] ?? "",
    war_order_status: json["war_order_status"],
    payment_collected:
        (json["payment_collected"] is num)
            ? (json["payment_collected"] as num).toDouble()
            : double.tryParse('${json["payment_collected"] ?? 0}') ?? 0,
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    orderAmount: json["order_amount"] ?? "",
    shippedAmount: json["shipped_amount"] ?? "",
    shippingCharge: json["shipping_charge"] ?? "",
    discountValue: json["discount_value"],
    discountType: json["discount_type"],
    grandTotal: json["grand_total"]?.toString() ?? "",
    posAmount: json["pos_amount"],
    dueAmount: json["due_amount"]?.toString() ?? "",
    orderModifyNotification: json["order_modify_notification"] ?? 0,
    driverLat: json["driver_lat"] ?? "",
    driverLong: json["driver_long"] ?? "",
    shipmentLabel: json["shipment_label"],
    preparationLabel: json["preparation_label"],
    bill_image: json["bill_image"],
    firstname: json["firstname"] ?? "",
    lastname: json["lastname"],
    street: json["street"] ?? "",
    city: json["city"],
    region: json["region"] ?? "",
    postcode: json["postcode"] ?? "",
    telephone: json["telephone"] ?? "",
    countryId: json["country_id"] ?? "",
    company: json["company"],
    email: json["email"],
    deliveryNote: json["delivery_note"] ?? "",
    pickername: json["picker_name"],
    drivername: json["driver_name"],
    cashierName: json["cashier_name"] ?? "",
    paymentMethod: json["payment_method"] ?? "",
    onlinePaidAmount: json["online_paid_amount"]?.toString(),
    base_discount_amount: json["base_discount_amount"]?.toString() ?? "",
    couponCode: json["coupon_code"],
    customer_id: json["customer_id"] ?? 0,
    increment_id: json["increment_id"] ?? "",
    order_source: json["order_source"] ?? "",
    is_already_punched_today: json["is_already_punched_today"] ?? 0,
    statusHistory:
        json["status_history"] == null
            ? null
            : StatusHistory.fromJson(json["status_history"]),
    isWhatsappOrder: json["is_whatsapp_order"] ?? 0,
    items:
        (() {
          final rawItems = json["items"];
          if (rawItems is List) {
            return rawItems.expand((category) {
              if (category is Map<String, dynamic> &&
                  category["items"] is List) {
                return (category["items"] as List).whereType<Map>().map(
                  (item) => Item.fromJson(Map<String, dynamic>.from(item)),
                );
              }
              if (category is Map<String, dynamic>) {
                return [Item.fromJson(Map<String, dynamic>.from(category))];
              }
              return <Item>[];
            }).toList();
          }
          return <Item>[];
        })(),
    combinedSubgroupIdentifiers:
        json["combined_subgroup_identifiers"] is List
            ? List<String>.from(
              json["combined_subgroup_identifiers"].map((x) => x.toString()),
            )
            : <String>[],
    calculatedShippingCharge:
        json["calculated_shipping_charge"] is num
            ? (json["calculated_shipping_charge"] as num).toInt()
            : int.tryParse('${json["calculated_shipping_charge"] ?? 0}') ?? 0,
    combinedGrandTotal:
        json["combined_grand_total"] is num
            ? (json["combined_grand_total"] as num).toDouble()
            : double.tryParse('${json["combined_grand_total"] ?? 0}') ?? 0,
    isCombinedShipping: json["is_combined_shipping"] ?? false,
    orderPlacedTotal:
        json["order_placed_total"] is num
            ? (json["order_placed_total"] as num).toDouble()
            : double.tryParse('${json["order_placed_total"] ?? 0}') ?? 0,
    endPickedTotal:
        json["end_picked_total"] is num
            ? (json["end_picked_total"] as num).toDouble()
            : double.tryParse('${json["end_picked_total"] ?? 0}') ?? 0,
    totalDue:
        json["total_due"] is num
            ? (json["total_due"] as num).toDouble()
            : double.tryParse('${json["total_due"] ?? 0}') ?? 0,
    combinedOrderPlacedTotal:
        json["combined_order_placed_total"] is num
            ? (json["combined_order_placed_total"] as num).toDouble()
            : double.tryParse('${json["combined_order_placed_total"] ?? 0}') ??
                0,
    combinedEndPickedTotal:
        json["combined_end_picked_total"] is num
            ? (json["combined_end_picked_total"] as num).toDouble()
            : double.tryParse('${json["combined_end_picked_total"] ?? 0}') ?? 0,
    combinedOnlinePaidAmount:
        json["combined_online_paid_amount"] is num
            ? (json["combined_online_paid_amount"] as num).toDouble()
            : double.tryParse('${json["combined_online_paid_amount"] ?? 0}') ??
                0,
    combinedCalculatedShippingCharge:
        json["combined_calculated_shipping_charge"] is num
            ? (json["combined_calculated_shipping_charge"] as num).toDouble()
            : double.tryParse(
                  '${json["combined_calculated_shipping_charge"] ?? 0}',
                ) ??
                0,
    combinedTotalDue:
        json["combined_total_due"] is num
            ? (json["combined_total_due"] as num).toDouble()
            : double.tryParse('${json["combined_total_due"] ?? 0}') ?? 0,
    isCombinedOrder: json["is_combined_order"] ?? false,
    relatedOrdersByTracker:
        json["related_orders_by_tracker"] is List
            ? List<String>.from(
              json["related_orders_by_tracker"].map((x) => x.toString()),
            )
            : <String>[],
  );

  Map<String, dynamic> toJson() => {
    "subgroup_identifier": subgroupIdentifier,
    "branch_code": branchCode,
    "suborder_id": suborderId,
    "order_sych_no": orderSychNo,
    "order_id": orderId,
    "order_status": orderStatus,
    "status_type": statusType,
    "delivery_from": deliveryFrom?.toIso8601String(),
    "delivery_to": deliveryTo?.toIso8601String(),
    "timerange": timerange,
    "picker_id": pickerId,
    "war_picker_id": war_picker_id,
    "driver_id": driverId,
    "cashier_id": cashier_id,
    "driver_flag": driverFlag,
    "driver_type": driverType,
    "tracker_id": tracker_id,
    "war_order_status": war_order_status,
    "payment_collected": payment_collected,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "order_amount": orderAmount,
    "shipped_amount": shippedAmount,
    "shipping_charge": shippingCharge,
    "discount_value": discountValue,
    "discount_type": discountType,
    "grand_total": grandTotal,
    "pos_amount": posAmount,
    "due_amount": dueAmount,
    "order_modify_notification": orderModifyNotification,
    "driver_lat": driverLat,
    "driver_long": driverLong,
    "shipment_label": shipmentLabel,
    "preparation_label": preparationLabel,
    "bill_image": bill_image,
    "firstname": firstname,
    "lastname": lastname,
    "street": street,
    "city": city,
    "region": region,
    "postcode": postcode,
    "telephone": telephone,
    "country_id": countryId,
    "company": company,
    "email": email,
    "delivery_note": deliveryNote,
    "picker_name": pickername,
    "driver_name": drivername,
    "cashier_name": cashierName,
    "payment_method": paymentMethod,
    "online_paid_amount": onlinePaidAmount,
    "base_discount_amount": base_discount_amount,
    "coupon_code": couponCode,
    "customer_id": customer_id,
    "increment_id": increment_id,
    "order_source": order_source,
    "is_already_punched_today": is_already_punched_today,
    "status_history": statusHistory?.toJson(),
    "is_whatsapp_order": isWhatsappOrder,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
    "combined_subgroup_identifiers": List<dynamic>.from(
      combinedSubgroupIdentifiers.map((x) => x),
    ),
    "calculated_shipping_charge": calculatedShippingCharge,
    "combined_grand_total": combinedGrandTotal,
    "is_combined_shipping": isCombinedShipping,
    "order_placed_total": orderPlacedTotal,
    "end_picked_total": endPickedTotal,
    "total_due": totalDue,
    "combined_order_placed_total": combinedOrderPlacedTotal,
    "combined_end_picked_total": combinedEndPickedTotal,
    "combined_online_paid_amount": combinedOnlinePaidAmount,
    "combined_calculated_shipping_charge": combinedCalculatedShippingCharge,
    "combined_total_due": combinedTotalDue,
    "is_combined_order": isCombinedOrder,
    "related_orders_by_tracker": List<dynamic>.from(
      relatedOrdersByTracker.map((x) => x),
    ),
  };
}

class Item {
  int itemId;
  int productId;
  String sku;
  String name;
  String? name_en;
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
  String? branchName;
  String? productType;
  String? productOptions;
  int? orderId;
  int? quoteItemId;
  int? categoryId;
  String? categoryName;
  String? deliveryType;
  int? an_picker_id;
  int? an_driver_id;
  String? branchCode;
  String? erp_promo_price;
  String? basePrice;
  String? originalPrice;

  Item({
    required this.itemId,
    required this.productId,
    required this.sku,
    required this.name,
    this.name_en,
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
    required this.branchName,
    this.productType,
    this.productOptions,
    this.orderId,
    this.quoteItemId,
    this.categoryId,
    this.categoryName,
    this.deliveryType,
    this.an_picker_id,
    this.an_driver_id,
    this.branchCode,
    this.erp_promo_price,
    this.basePrice,
    this.originalPrice,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    itemId: json["item_id"] ?? 0,
    productId: json["product_id"] ?? 0,
    sku: json["sku"] ?? "",
    name: json["name"] ?? "",
    name_en: json["name_en"],
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
    branchName: json["branch_name"] ?? "",
    productType: json["product_type"],
    productOptions: json["product_options"],
    orderId: json["order_id"],
    quoteItemId: json["quote_item_id"],
    categoryId: json["category_id"],
    categoryName: json["category_name"],
    deliveryType: json["delivery_type"],
    an_picker_id: json["an_picker_id"],
    an_driver_id: json["an_driver_id"],
    branchCode: json["branch_code"],
    erp_promo_price: json["erp_promo_price"],
    basePrice: json["base_price"],
    originalPrice: json["original_price"],
  );

  Map<String, dynamic> toJson() => {
    "item_id": itemId,
    "product_id": productId,
    "sku": sku,
    "name": name,
    "name_en": name_en,
    "price": price,
    "item_type": itemType,
    "item_status": itemStatus,
    "qty_ordered": qtyOrdered,
    "qty_shipped": qtyShipped,
    "qty_canceled": qtyCanceled,
    "row_total": rowTotal,
    "final_price": finalPrice,
    "web_price": webprice,
    "image_url": imageurl,
    "product_name": productName,
    "branch_name": branchName,
    "product_type": productType,
    "product_options": productOptions,
    "order_id": orderId,
    "quote_item_id": quoteItemId,
    "category_id": categoryId,
    "category_name": categoryName,
    "delivery_type": deliveryType,
    "an_picker_id": an_picker_id,
    "an_driver_id": an_driver_id,
    "branch_code": branchCode,
    "erp_promo_price": erp_promo_price,
    "base_price": basePrice,
    "original_price": originalPrice,
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
