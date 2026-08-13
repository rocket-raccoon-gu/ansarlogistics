// To parse this JSON data, do
//
//     final driverBaseOrderResponse = driverBaseOrderResponseFromJson(jsonString);

import 'dart:convert';

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
  List<DataItem> data;

  DriverBaseOrderResponse({
    required this.success,
    required this.count,
    required this.data,
    this.currentPage,
    this.lastPage,
    this.nextPageUrl,
  });

  bool hasMorePages(int pageSize) {
    if (nextPageUrl != null && nextPageUrl!.trim().isNotEmpty) return true;
    if (currentPage != null && lastPage != null) {
      return currentPage! < lastPage!;
    }
    return data.length >= pageSize;
  }

  factory DriverBaseOrderResponse.fromJson(Map<String, dynamic> json) {
    final list = _extractOrderList(json["data"]);
    final items =
        list.whereType<Map<String, dynamic>>().map((item) {
          try {
            return DataItem.fromJson(item);
          } catch (_) {
            return null;
          }
        }).whereType<DataItem>().toList();
    final meta = json["data"] is Map<String, dynamic>
        ? json["data"] as Map<String, dynamic>
        : json;

    return DriverBaseOrderResponse(
      success: json["success"] == true || json["success"] == 1,
      count: _extractCount(json, items.length),
      data: items,
      currentPage: _toIntOrNull(meta["current_page"] ?? json["current_page"]),
      lastPage: _toIntOrNull(meta["last_page"] ?? json["last_page"]),
      nextPageUrl:
          (meta["next_page_url"] ?? json["next_page_url"])?.toString(),
    );
  }

  /// Handles both `{ data: [...] }` and `{ data: { data: [...] } }`.
  static List<dynamic> _extractOrderList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map<String, dynamic>) {
      final nested = raw["data"] ?? raw["orders"] ?? raw["items"];
      if (nested is List) return nested;
      if (nested is Map<String, dynamic>) {
        return _extractOrderList(nested);
      }
      if (raw.containsKey("id") ||
          raw.containsKey("subgroup_identifier") ||
          raw.containsKey("order")) {
        return [raw];
      }
    }
    return const [];
  }

  static int _extractCount(Map<String, dynamic> json, int fallback) {
    final candidates = <dynamic>[
      json["count"],
      json["total"],
      if (json["data"] is Map<String, dynamic>) ...[
        (json["data"] as Map)["count"],
        (json["data"] as Map)["total"],
        (json["data"] as Map)["total_count"],
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
    if (json["order"] is Map<String, dynamic>) {
      return DataItem(
        locationId: _toInt(json["location_id"]),
        order: Order.fromJson(json["order"] as Map<String, dynamic>),
        customer: Customer.fromJson(
          json["customer"] is Map<String, dynamic>
              ? json["customer"] as Map<String, dynamic>
              : const {},
        ),
        address: Address.fromJson(
          json["address"] is Map<String, dynamic>
              ? json["address"] as Map<String, dynamic>
              : const {},
        ),
        items:
            json["items"] is List
                ? List<ItemItem>.from(
                  (json["items"] as List)
                      .whereType<Map<String, dynamic>>()
                      .map(ItemItem.fromJson),
                )
                : const [],
      );
    }

    final dropoff =
        json["dropoff"] is Map<String, dynamic>
            ? json["dropoff"] as Map<String, dynamic>
            : const <String, dynamic>{};
    final customerJson =
        json["customer"] is Map<String, dynamic>
            ? json["customer"] as Map<String, dynamic>
            : const <String, dynamic>{};

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
      items:
          json["items"] is List
              ? List<ItemItem>.from(
                (json["items"] as List)
                    .whereType<Map<String, dynamic>>()
                    .map(ItemItem.fromJson),
              )
              : const [],
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

  Customer({required this.name, required this.mobileNumber});

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    name: json["name"]?.toString() ?? "",
    mobileNumber: json["mobile_number"]?.toString() ?? "",
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "mobile_number": mobileNumber,
  };
}

class ItemItem {
  String name;
  int quantity;
  double amount;
  double total;
  String status;
  String sku;
  String image;

  ItemItem({
    required this.name,
    required this.quantity,
    required this.amount,
    required this.total,
    required this.status,
    required this.sku,
    required this.image,
  });

  factory ItemItem.fromJson(Map<String, dynamic> json) => ItemItem(
    name: json["name"]?.toString() ?? "",
    quantity: _toInt(json["quantity"]),
    amount: _toDouble(json["amount"]),
    total: _toDouble(json["total"]),
    status: json["status"]?.toString() ?? "",
    sku: json["sku"]?.toString() ?? "",
    image: json["image"]?.toString() ?? "",
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "quantity": quantity,
    "amount": amount,
    "total": total,
    "status": status,
    "sku": sku,
    "image": image,
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
  String deliveryNote;
  String paymentMode;
  int preOrder;
  DateTime preOrderDate;
  String vehicleChoice;
  String merchantOrderId;

  Order({
    required this.entityId,
    required this.subgroupIdentifier,
    required this.status,
    required this.deliveryFrom,
    required this.deliveryTo,
    required this.subTotal,
    required this.delivery,
    required this.total,
    required this.deliveryNote,
    required this.paymentMode,
    required this.preOrder,
    required this.preOrderDate,
    required this.vehicleChoice,
    required this.merchantOrderId,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    entityId: _toInt(json["entity_id"]),
    subgroupIdentifier:
        json["subgroup_identifier"]?.toString() ?? json["id"]?.toString() ?? "",
    status: json["status"]?.toString() ?? "",
    deliveryFrom: _toDate(json["deliveryFrom"] ?? json["delivery_from"]),
    deliveryTo: _toDate(json["delivery_to"]),
    subTotal: _toDouble(json["sub_total"] ?? json["order_sub_total_value"]),
    delivery: _toInt(json["delivery"]),
    total: _toDouble(json["total"] ?? json["total_order_value"]),
    deliveryNote: json["delivery_note"]?.toString() ?? "",
    paymentMode: json["payment_mode"]?.toString() ?? "",
    preOrder: _toInt(json["pre_order"]),
    preOrderDate: _toDate(json["pre_order_date"]),
    vehicleChoice: json["vehicle_choice"]?.toString() ?? "",
    merchantOrderId: json["merchant_order_id"]?.toString() ?? "",
  );

  factory Order.fromDriverListJson(Map<String, dynamic> json) => Order(
    entityId: _toInt(json["driver_id"]),
    subgroupIdentifier:
        json["subgroup_identifier"]?.toString() ?? json["id"]?.toString() ?? "",
    status:
        json["driver_status"]?.toString() ??
        json["order_status"]?.toString() ??
        "",
    deliveryFrom: _toDate(json["delivery_from"]),
    deliveryTo: _toDate(json["delivery_to"]),
    subTotal: _toDouble(json["order_sub_total_value"]),
    delivery: 0,
    total: _toDouble(json["amount_to_collect"] ?? json["total_order_value"]),
    deliveryNote: json["delivery_note"]?.toString() ?? "",
    paymentMode: json["payment_mode"]?.toString() ?? "",
    preOrder: 0,
    preOrderDate: DateTime.now(),
    vehicleChoice: json["driver_type"]?.toString() ?? "",
    merchantOrderId: json["order_number"]?.toString() ?? "",
  );

  Map<String, dynamic> toJson() => {
    "entity_id": entityId,
    "subgroup_identifier": subgroupIdentifier,
    "status": status,
    "deliveryFrom": deliveryFrom.toIso8601String(),
    "delivery_to": deliveryTo.toIso8601String(),
    "sub_total": subTotal,
    "delivery": delivery,
    "total": total,
    "delivery_note": deliveryNote,
    "payment_mode": paymentMode,
    "pre_order": preOrder,
    "pre_order_date": preOrderDate.toIso8601String(),
    "vehicle_choice": vehicleChoice,
    "merchant_order_id": merchantOrderId,
  };
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
