// To parse this JSON data, do
//
//     final driverBaseOrderResponse = driverBaseOrderResponseFromJson(jsonString);

import 'dart:convert';
import 'dart:developer';

DriverBaseOrderResponse driverBaseOrderResponseFromJson(String str) =>
    DriverBaseOrderResponse.fromJson(json.decode(str));

String driverBaseOrderResponseToJson(DriverBaseOrderResponse data) =>
    json.encode(data.toJson());

class DriverBaseOrderResponse {
  bool success;
  int count;
  int? currentPage;
  int? lastPage;
  String? nextPageUrl;
  bool? hasNextPage;
  List<DataItem> data;

  DriverBaseOrderResponse({
    required this.success,
    required this.count,
    required this.data,
    this.currentPage,
    this.lastPage,
    this.nextPageUrl,
    this.hasNextPage,
  });

  bool hasMorePages(int pageSize) {
    if (hasNextPage != null) return hasNextPage!;
    if (nextPageUrl != null && nextPageUrl!.trim().isNotEmpty) return true;
    if (currentPage != null && lastPage != null) {
      return currentPage! < lastPage!;
    }
    return data.length >= pageSize;
  }

  factory DriverBaseOrderResponse.fromJson(Map<String, dynamic> json) {
    final root = _asMap(json["data"]) ?? json;
    final list = _extractOrderList(json["data"]);
    final items =
        list.map((item) {
          if (item is! Map) return null;
          try {
            return DataItem.fromJson(_asMap(item)!);
          } catch (e, st) {
            log('Driver order parse failed: $e', stackTrace: st);
            return null;
          }
        }).whereType<DataItem>().toList();

    final pagination = _asMap(root["pagination"]);

    return DriverBaseOrderResponse(
      success: json["success"] == true || json["success"] == 1,
      count: _extractCount(json, pagination, items.length),
      data: items,
      currentPage: _toIntOrNull(
        pagination?["page"] ?? root["current_page"] ?? json["current_page"],
      ),
      lastPage: _toIntOrNull(
        pagination?["total_pages"] ?? root["last_page"] ?? json["last_page"],
      ),
      nextPageUrl:
          (root["next_page_url"] ?? json["next_page_url"])?.toString(),
      hasNextPage:
          pagination == null
              ? null
              : pagination["has_next_page"] == true ||
                  pagination["has_next_page"] == 1,
    );
  }

  /// Handles `{ data: [...] }`, `{ data: { data: [...], pagination } }`.
  static List<dynamic> _extractOrderList(dynamic raw) {
    if (raw is List) return raw;
    final map = _asMap(raw);
    if (map == null) return const [];
    final nested = map["data"] ?? map["orders"] ?? map["items"];
    if (nested is List) return nested;
    if (nested is Map) return _extractOrderList(nested);
    if (map.containsKey("id") ||
        map.containsKey("subgroup_identifier") ||
        map.containsKey("order")) {
      return [map];
    }
    return const [];
  }

  static int _extractCount(
    Map<String, dynamic> json,
    Map<String, dynamic>? pagination,
    int fallback,
  ) {
    final candidates = <dynamic>[
      pagination?["total"],
      json["count"],
      json["total"],
      if (json["data"] is Map) ...[
        json["data"]["count"],
        json["data"]["total"],
        json["data"]["total_count"],
      ],
    ];
    for (final value in candidates) {
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "count": count,
    "data": data.map((x) => x.toJson()).toList(),
  };
}

class DataItem {
  int locationId;
  Order order;
  Customer customer;
  Address address;
  List<ItemItem> items;

  DataItem({
    required this.locationId,
    required this.order,
    required this.customer,
    required this.address,
    required this.items,
  });

  factory DataItem.fromJson(Map<String, dynamic> json) {
    if (_asMap(json["order"]) != null) {
      return DataItem(
        locationId: _toInt(json["location_id"] ?? json["driver_id"]),
        order: Order.fromJson(_asMap(json["order"])!),
        customer: Customer.fromJson(_asMap(json["customer"]) ?? const {}),
        address: Address.fromJson(_asMap(json["address"]) ?? const {}),
        items: _parseItems(json["items"]),
      );
    }

    final dropoff = _asMap(json["dropoff"]) ?? const <String, dynamic>{};
    final customerJson = _asMap(json["customer"]) ?? const <String, dynamic>{};

    return DataItem(
      locationId: _toInt(json["driver_id"]),
      order: Order.fromDriverListJson(json),
      customer: Customer.fromJson(customerJson),
      address: Address.fromJson({
        "name": dropoff["name"] ?? customerJson["name"] ?? "",
        "apartment": dropoff["zone"] ?? "",
        "latitude": dropoff["latitude"] ?? "",
        "longitude": dropoff["longitude"] ?? "",
        "building": dropoff["building"] ?? "",
        "floor": dropoff["city"] ?? "",
        "zone": dropoff["zone"] ?? "",
        "street": dropoff["street"] ?? "",
      }),
      items: _parseItems(json["items"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "location_id": locationId,
    "order": order.toJson(),
    "customer": customer.toJson(),
    "address": address.toJson(),
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class Address {
  String name;
  String apartment;
  String latitude;
  String longitude;
  String building;
  String floor;
  String zone;
  String street;

  Address({
    required this.name,
    required this.apartment,
    required this.latitude,
    required this.longitude,
    required this.building,
    required this.floor,
    required this.zone,
    required this.street,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    name: json["name"]?.toString() ?? "",
    apartment: json["apartment"]?.toString() ?? "",
    latitude: json["latitude"]?.toString() ?? "",
    longitude: json["longitude"]?.toString() ?? "",
    building: json["building"]?.toString() ?? "",
    floor: json["floor"]?.toString() ?? "",
    zone: json["zone"]?.toString() ?? "",
    street: json["street"]?.toString() ?? "",
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "apartment": apartment,
    "latitude": latitude,
    "longitude": longitude,
    "building": building,
    "floor": floor,
    "zone": zone,
    "street": street,
  };
}

class Customer {
  String name;
  String mobileNumber;
  String email;

  Customer({
    required this.name,
    required this.mobileNumber,
    this.email = "",
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    name: json["name"]?.toString() ?? "",
    mobileNumber:
        json["mobile_number"]?.toString() ??
        json["phone"]?.toString() ??
        json["telephone"]?.toString() ??
        "",
    email:
        json["email"]?.toString() ??
        json["customer_email"]?.toString() ??
        "",
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "mobile_number": mobileNumber,
    "email": email,
  };
}

class ItemItem {
  int itemId;
  int productId;
  String name;
  int quantity;
  double amount;
  double total;
  String status;
  String sku;
  String image;
  String subgroupIdentifier;
  String deliveryType;

  ItemItem({
    this.itemId = 0,
    this.productId = 0,
    required this.name,
    required this.quantity,
    required this.amount,
    required this.total,
    required this.status,
    required this.sku,
    required this.image,
    this.subgroupIdentifier = "",
    this.deliveryType = "",
  });

  factory ItemItem.fromJson(Map<String, dynamic> json) {
    final subgroup = json["subgroup_identifier"]?.toString() ?? "";
    return ItemItem(
      itemId: _toInt(json["item_id"]),
      productId: _toInt(json["product_id"]),
      name: json["name"]?.toString() ?? "",
      quantity: _toInt(json["quantity"]),
      amount: _toDouble(json["amount"]),
      total: _toDouble(json["total"] ?? json["row_total"] ?? json["price"]),
      status: json["status"]?.toString() ?? "",
      sku: json["sku"]?.toString() ?? "",
      image: json["image"]?.toString() ?? "",
      subgroupIdentifier: subgroup,
      deliveryType:
          (json["order_type"] ?? json["delivery_type"] ?? json["deliveryType"])
              ?.toString() ??
          (subgroup.contains('-') ? subgroup.split('-').first : ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "item_id": itemId,
    "product_id": productId,
    "name": name,
    "quantity": quantity,
    "amount": amount,
    "total": total,
    "status": status,
    "sku": sku,
    "image": image,
    "subgroup_identifier": subgroupIdentifier,
    "order_type": deliveryType,
  };
}

class SuborderStatus {
  String subgroupIdentifier;
  String orderType;
  String status;

  SuborderStatus({
    required this.subgroupIdentifier,
    required this.orderType,
    required this.status,
  });

  factory SuborderStatus.fromJson(Map<String, dynamic> json) => SuborderStatus(
    subgroupIdentifier: json["subgroup_identifier"]?.toString() ?? "",
    orderType: json["order_type"]?.toString() ?? "",
    status: json["status"]?.toString() ?? "",
  );

  Map<String, dynamic> toJson() => {
    "subgroup_identifier": subgroupIdentifier,
    "order_type": orderType,
    "status": status,
  };
}

class Order {
  int entityId;
  String subgroupIdentifier;
  String status;
  DateTime deliveryFrom;
  DateTime deliveryTo;
  double subTotal;
  int delivery;
  double total;
  double orderValue;
  double posAmount;
  String deliveryNote;
  String paymentMode;
  String paymentMethod;
  int preOrder;
  DateTime preOrderDate;
  String vehicleChoice;
  String merchantOrderId;
  bool isMerged;
  bool isReturn;
  String returnId;
  String apiId;
  double totalReturnAmount;
  String orderType;
  List<String> subgroupIdentifiers;
  List<SuborderStatus> suborderStatuses;
  String? billImage;

  Order({
    required this.entityId,
    required this.subgroupIdentifier,
    required this.status,
    required this.deliveryFrom,
    required this.deliveryTo,
    required this.subTotal,
    required this.delivery,
    required this.total,
    this.orderValue = 0,
    this.posAmount = 0,
    required this.deliveryNote,
    required this.paymentMode,
    this.paymentMethod = "",
    required this.preOrder,
    required this.preOrderDate,
    required this.vehicleChoice,
    required this.merchantOrderId,
    this.isMerged = false,
    this.isReturn = false,
    this.returnId = "",
    this.apiId = "",
    this.totalReturnAmount = 0,
    this.orderType = "",
    this.subgroupIdentifiers = const [],
    this.suborderStatuses = const [],
    this.billImage,
  });

  factory Order.fromJson(Map<String, dynamic> json) =>
      Order.fromDriverListJson(json);

  factory Order.fromDriverListJson(Map<String, dynamic> json) {
    final identifiers = _stringList(json["subgroup_identifiers"]);
    final returnId = _returnIdFromJson(json);
    return Order(
      entityId: _toInt(json["entity_id"]),
      subgroupIdentifier:
          json["subgroup_identifier"]?.toString() ??
          json["id"]?.toString() ??
          "",
      status:
          json["driver_status"]?.toString() ??
          json["order_status"]?.toString() ??
          json["status"]?.toString() ??
          "",
      deliveryFrom: _toDate(json["deliveryFrom"] ?? json["delivery_from"]),
      deliveryTo: _toDate(json["delivery_to"]),
      subTotal: _toDouble(json["order_sub_total_value"] ?? json["sub_total"]),
      delivery: _toInt(json["delivery"]),
      total: _toDouble(json["amount_to_collect"]),
      orderValue: _toDouble(
        json["total_order_value"] ?? json["total"] ?? json["amount_to_collect"],
      ),
      posAmount: _toDouble(json["pos_amount"] ?? json["posAmount"]),
      deliveryNote: json["delivery_note"]?.toString() ?? "",
      paymentMode: json["payment_mode"]?.toString() ?? "",
      paymentMethod: json["payment_method"]?.toString() ?? "",
      preOrder: _toInt(json["pre_order"]),
      preOrderDate: _toDate(json["pre_order_date"]),
      vehicleChoice: json["vehicle_choice"]?.toString() ?? json["driver_type"]?.toString() ?? "",
      merchantOrderId:
          json["order_number"]?.toString() ??
          json["merchant_order_id"]?.toString() ??
          "",
      isMerged: _isMergedFlag(json, identifiers),
      isReturn: _isReturnFlag(json, returnId),
      returnId: returnId,
      apiId: json["id"]?.toString() ?? "",
      totalReturnAmount: _toDouble(json["total_return_amount"]),
      orderType: json["order_type"]?.toString() ?? "",
      subgroupIdentifiers: identifiers,
      suborderStatuses: _parseSuborderStatuses(json["suborder_statuses"]),
      billImage: json["bill_image"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "entity_id": entityId,
    "id": apiId.isNotEmpty ? apiId : subgroupIdentifier,
    "subgroup_identifier": subgroupIdentifier,
    "status": status,
    "deliveryFrom": deliveryFrom.toIso8601String(),
    "delivery_to": deliveryTo.toIso8601String(),
    "sub_total": subTotal,
    "delivery": delivery,
    "amount_to_collect": total,
    "total_order_value": orderValue,
    "pos_amount": posAmount,
    "delivery_note": deliveryNote,
    "payment_mode": paymentMode,
    "payment_method": paymentMethod,
    "pre_order": preOrder,
    "pre_order_date": preOrderDate.toIso8601String(),
    "vehicle_choice": vehicleChoice,
    "order_number": merchantOrderId,
    "is_merged": isMerged,
    "is_return": isReturn,
    "return_id": returnId,
    "total_return_amount": totalReturnAmount,
    "order_type": orderType,
    "subgroup_identifiers": subgroupIdentifiers,
    "suborder_statuses":
        suborderStatuses.map((status) => status.toJson()).toList(),
    "bill_image": billImage,
  };
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<String> _stringList(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((e) => e.toString().trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

List<SuborderStatus> _parseSuborderStatuses(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .map((entry) {
        final map = _asMap(entry);
        return map == null ? null : SuborderStatus.fromJson(map);
      })
      .whereType<SuborderStatus>()
      .toList();
}

int? _toIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim());
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim()) ?? 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim()) ?? 0;
}

DateTime _toDate(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString()) ?? DateTime.now();
}

List<ItemItem> _parseItems(dynamic raw) {
  if (raw is! List) return const [];
  final items = <ItemItem>[];
  for (final entry in raw) {
    final map = _asMap(entry);
    if (map == null) continue;
    if (map["items"] is List) {
      items.addAll(_parseItems(map["items"]));
      continue;
    }
    items.add(ItemItem.fromJson(map));
  }
  return items;
}

bool _isReturnFlag(Map<String, dynamic> json, String returnId) {
  final flag = json["is_return"];
  if (flag == true || flag == 1 || flag == '1' || flag == 'true') {
    return true;
  }
  if (json["order_type"]?.toString().toUpperCase() == "RET") return true;
  if (returnId.isNotEmpty) return true;
  final id = json["id"]?.toString().toUpperCase() ?? "";
  return id.startsWith("RETURN:");
}

String _returnIdFromJson(Map<String, dynamic> json) {
  final fromField = json["return_id"]?.toString().trim() ?? "";
  if (fromField.isNotEmpty) return fromField;
  final raw = json["id"]?.toString() ?? "";
  if (raw.toUpperCase().startsWith("RETURN:")) {
    final parts = raw.split(':');
    if (parts.length >= 2 && parts[1].trim().isNotEmpty) {
      return parts[1].trim();
    }
  }
  return "";
}

bool _isMergedFlag(Map<String, dynamic> json, List<String> identifiers) {
  final merged = json["is_merged"];
  if (merged == true || merged == 1 || merged == '1' || merged == 'true') {
    return true;
  }
  if (merged == false || merged == 0 || merged == '0' || merged == 'false') {
    return false;
  }
  return identifiers.length > 1;
}