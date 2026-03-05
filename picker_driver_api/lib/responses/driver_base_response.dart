// To parse this JSON data, do
//
//     final driverBaseOrderResponse = driverBaseOrderResponseFromJson(jsonString);

import 'dart:convert';

import 'package:picker_driver_api/responses/cashier_order_response.dart';

DriverBaseOrderResponse driverBaseOrderResponseFromJson(String str) =>
    DriverBaseOrderResponse.fromJson(json.decode(str));

String driverBaseOrderResponseToJson(DriverBaseOrderResponse data) =>
    json.encode(data.toJson());

class DriverBaseOrderResponse {
  bool success;
  DataItem data;

  DriverBaseOrderResponse({required this.success, required this.data});

  factory DriverBaseOrderResponse.fromJson(Map<String, dynamic> json) =>
      DriverBaseOrderResponse(
        success: json["success"],
        data: DataItem.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"success": success, "data": data.toJson()};
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

  factory DataItem.fromJson(Map<String, dynamic> json) => DataItem(
    locationId: json["location_id"],
    order: Order.fromJson(json["order"]),
    customer: Customer.fromJson(json["customer"]),
    address: Address.fromJson(json["address"]),
    items: List<ItemItem>.from(json["items"].map((x) => ItemItem.fromJson(x))),
  );

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
    name: json["name"],
    apartment: json["apartment"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    building: json["building"],
    floor: json["floor"],
    zone: json["zone"],
    street: json["street"],
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

  factory Customer.fromJson(Map<String, dynamic> json) =>
      Customer(name: json["name"], mobileNumber: json["mobile_number"]);

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

  ItemItem({
    required this.name,
    required this.quantity,
    required this.amount,
    required this.total,
    required this.status,
    required this.sku,
  });

  factory ItemItem.fromJson(Map<String, dynamic> json) => ItemItem(
    name: json["name"],
    quantity: json["quantity"],
    amount: json["amount"]?.toDouble(),
    total: json["total"]?.toDouble(),
    status: json["status"],
    sku: json["sku"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "quantity": quantity,
    "amount": amount,
    "total": total,
    "status": status,
    "sku": sku,
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
    entityId: json["entity_id"],
    subgroupIdentifier: json["subgroup_identifier"],
    status: json["status"],
    deliveryFrom: DateTime.parse(json["deliveryFrom"]),
    deliveryTo: DateTime.parse(json["delivery_to"]),
    subTotal: json["sub_total"]?.toDouble(),
    delivery: json["delivery"],
    total: json["total"]?.toDouble(),
    deliveryNote: json["delivery_note"],
    paymentMode: json["payment_mode"],
    preOrder: json["pre_order"],
    preOrderDate: DateTime.parse(json["pre_order_date"]),
    vehicleChoice: json["vehicle_choice"],
    merchantOrderId: json["merchant_order_id"],
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
