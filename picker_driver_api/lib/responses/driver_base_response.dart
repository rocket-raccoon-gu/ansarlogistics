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
  Data data;

  DriverBaseOrderResponse({
    required this.success,
    required this.count,
    required this.data,
  });

  factory DriverBaseOrderResponse.fromJson(Map<String, dynamic> json) =>
      DriverBaseOrderResponse(
        success: json["success"],
        count: json["count"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "count": count,
    "data": data.toJson(),
  };
}

class Data {
  List<DataItem> items;

  Data({required this.items});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    items: List<DataItem>.from(json["items"].map((x) => DataItem.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class DataItem {
  int entityId;
  String subgroupIdentifier;
  String status;
  String type;
  DateTime deliveryFrom;
  DateTime deliveryTo;
  String grandTotal;
  String shippedAmount;
  dynamic statusType;
  dynamic deliveryTimerange;
  String customerFirstname;
  dynamic customerLastname;
  String billingStreet;
  String customerEmail;
  String postcode;
  dynamic buildingNumber;
  String telephone;
  String latitude;
  String longitude;
  String paymentMethod;
  String deliveryNote;
  dynamic addressLabel;
  dynamic buildingName;
  dynamic flatNumber;
  dynamic floorNumber;
  String shippingCharge;
  DateTime createdAt;
  int driverId;
  String city;
  List<ItemItem> items;

  DataItem({
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
    required this.shippingCharge,
    required this.createdAt,
    required this.driverId,
    required this.city,
    required this.items,
  });

  factory DataItem.fromJson(Map<String, dynamic> json) => DataItem(
    entityId: json["entity_id"],
    subgroupIdentifier: json["subgroup_identifier"],
    status: json["status"],
    type: json["type"],
    deliveryFrom: DateTime.parse(json["delivery_from"]),
    deliveryTo: DateTime.parse(json["delivery_to"]),
    grandTotal: json["grand_total"],
    shippedAmount: json["shipped_amount"],
    statusType: json["status_type"],
    deliveryTimerange: json["delivery_timerange"],
    customerFirstname: json["customer_firstname"],
    customerLastname: json["customer_lastname"],
    billingStreet: json["billing_street"],
    customerEmail: json["customer_email"],
    postcode: json["postcode"],
    buildingNumber: json["building_number"],
    telephone: json["telephone"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    paymentMethod: json["payment_method"],
    deliveryNote: json["delivery_note"],
    addressLabel: json["address_label"],
    buildingName: json["building_name"],
    flatNumber: json["flat_number"],
    floorNumber: json["floor_number"],
    shippingCharge: json["shipping_charge"],
    createdAt: DateTime.parse(json["created_at"]),
    driverId: json["driver_id"],
    city: json["city"],
    items: List<ItemItem>.from(json["items"].map((x) => ItemItem.fromJson(x))),
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
    "shipping_charge": shippingCharge,
    "created_at": createdAt.toIso8601String(),
    "driver_id": driverId,
    "city": city,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
  };
}

class ItemItem {
  String name;
  String sku;
  int qty;
  double price;

  ItemItem({
    required this.name,
    required this.sku,
    required this.qty,
    required this.price,
  });

  factory ItemItem.fromJson(Map<String, dynamic> json) => ItemItem(
    name: json["name"],
    sku: json["sku"],
    qty: json["qty"],
    price: json["price"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "sku": sku,
    "qty": qty,
    "price": price,
  };
}
