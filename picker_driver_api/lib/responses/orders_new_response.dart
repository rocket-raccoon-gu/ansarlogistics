import 'dart:convert';

class OrdersNewResponse {
  final bool? success;
  final int? count;
  final OrdersNewData? data;
  final String? message;

  OrdersNewResponse({this.success, this.count, this.data, this.message});

  factory OrdersNewResponse.fromJson(
    Map<String, dynamic> json,
  ) => OrdersNewResponse(
    success: json['success'] is bool ? json['success'] : (json['success'] == 1),
    count:
        json['count'] is int
            ? json['count']
            : int.tryParse('${json['count'] ?? ''}'),
    data: json['data'] != null ? OrdersNewData.fromJson(json['data']) : null,
    message: json['message']?.toString(),
  );

  static OrdersNewResponse decode(String source) =>
      OrdersNewResponse.fromJson(json.decode(source));
}

class OrdersNewData {
  final List<OrderNew> orders;
  final List<CategoryGroup> categories;

  OrdersNewData({required this.orders, required this.categories});

  factory OrdersNewData.fromJson(Map<String, dynamic> json) => OrdersNewData(
    orders:
        ((json['orders'] is List) ? (json['orders'] as List) : const [])
            .whereType<Map>()
            .map((e) => OrderNew.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
    categories:
        ((json['categories'] is List) ? (json['categories'] as List) : const [])
            .whereType<Map>()
            .map((e) => CategoryGroup.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
  );
}

class OrderNew {
  String? id;
  String? status;
  String? statusText;
  String? deliveryNote;
  String? deliveryDate;
  String? timeRange;
  List<OrderItemNew> items;
  Map<String, dynamic>? categorySummary;
  Map<String, dynamic>? categoryCounts;
  String? paymentMethod;
  CustomerNew? customer;
  String? subgroupIdentifier;
  String? orderAmount;

  OrderNew({
    this.id,
    this.status,
    this.statusText,
    this.deliveryNote,
    this.deliveryDate,
    this.timeRange,
    this.items = const [],
    this.categorySummary,
    this.categoryCounts,
    this.paymentMethod,
    this.customer,
    this.subgroupIdentifier,
    required this.orderAmount,
  });

  factory OrderNew.fromJson(Map<String, dynamic> json) => OrderNew(
    id: json['id']?.toString(),
    status: json['status']?.toString(),
    statusText: json['statusText']?.toString(),
    deliveryNote: json['delivery_note']?.toString(),
    deliveryDate: json['deliveryDate']?.toString(),
    timeRange: json['timeRange']?.toString(),
    items:
        (() {
          final rawItems = json['items'];
          if (rawItems is List) {
            // Flatten all items from all categories in all delivery types
            return rawItems
                .whereType<
                  List
                >() // Each delivery type: ["nol", [ ...categories ]]
                .expand((deliveryType) {
                  if (deliveryType is List &&
                      deliveryType.length > 1 &&
                      deliveryType[1] is List) {
                    return (deliveryType[1] as List) // categories
                        .whereType<Map>()
                        .expand((category) {
                          if (category['items'] is List) {
                            return (category['items'] as List)
                                .whereType<Map>()
                                .map<OrderItemNew>(
                                  (e) => OrderItemNew.fromJson(
                                    Map<String, dynamic>.from(e),
                                  ),
                                );
                          }
                          return <OrderItemNew>[];
                        });
                  }
                  return <OrderItemNew>[];
                })
                .toList();
          }
          return <OrderItemNew>[];
        })(),
    categorySummary:
        (json['categorySummary'] is Map)
            ? Map<String, dynamic>.from(json['categorySummary'] as Map)
            : null,
    categoryCounts:
        (json['categoryCounts'] is Map)
            ? Map<String, dynamic>.from(json['categoryCounts'] as Map)
            : null,
    paymentMethod: json['paymentMethod']?.toString(),
    customer:
        (json['customer'] is Map)
            ? CustomerNew.fromJson(
              Map<String, dynamic>.from(json['customer'] as Map),
            )
            : null,
    subgroupIdentifier: json['subgroupIdentifier']?.toString(),
    orderAmount: json['orderAmount']?.toString(),
  );
}

class OrderItemNew {
  final String? id;
  final String? name;
  final String? sku;
  final num? price;
  final int? qtyOrdered;
  final int? qtyShipped;
  final String? categoryId;
  final String? categoryName;
  final String? imageUrl;
  final String? deliveryType;
  final String? itemStatus;
  final num? rowTotal;
  final num? rowTotalInclTax;

  OrderItemNew({
    this.id,
    this.name,
    this.sku,
    this.price,
    this.qtyOrdered,
    this.qtyShipped,
    this.categoryId,
    this.categoryName,
    this.imageUrl,
    this.deliveryType,
    this.itemStatus,
    this.rowTotal,
    this.rowTotalInclTax,
  });

  factory OrderItemNew.fromJson(Map<String, dynamic> json) => OrderItemNew(
    id: json['id']?.toString(),
    name: json['name']?.toString(),
    sku: json['sku']?.toString(),
    price:
        json['price'] is num
            ? json['price']
            : num.tryParse('${json['price'] ?? ''}'),
    qtyOrdered:
        json['qtyOrdered'] is int
            ? json['qtyOrdered']
            : int.tryParse('${json['qtyOrdered'] ?? ''}'),
    qtyShipped:
        json['qtyShipped'] is int
            ? json['qtyShipped']
            : int.tryParse('${json['qtyShipped'] ?? ''}'),
    categoryId: json['categoryId']?.toString(),
    categoryName: json['categoryName']?.toString(),
    imageUrl: json['imageUrl']?.toString(),
    deliveryType:
        json['delivery_type']?.toString() ?? json['deliveryType']?.toString(),
    itemStatus:
        json['item_status']?.toString() ?? json['itemStatus']?.toString(),
    rowTotal:
        (() {
          final v = json['row_total'] ?? json['rowTotal'];
          if (v is num) return v;
          return num.tryParse('${v ?? ''}');
        })(),
    rowTotalInclTax:
        (() {
          final v = json['row_total_incl_tax'] ?? json['rowTotalInclTax'];
          if (v is num) return v;
          return num.tryParse('${v ?? ''}');
        })(),
  );
}

class CustomerNew {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? address;

  CustomerNew({this.firstName, this.lastName, this.phone, this.address});

  factory CustomerNew.fromJson(Map<String, dynamic> json) => CustomerNew(
    firstName: json['firstName']?.toString(),
    lastName: json['lastName']?.toString(),
    phone: json['phone']?.toString(),
    address: json['address']?.toString(),
  );
}

class CategoryGroup {
  final String? category;
  final int? itemCount;
  final String? displayText;
  final List<GroupedProduct> items;

  CategoryGroup({
    this.category,
    this.itemCount,
    this.displayText,
    this.items = const [],
  });

  factory CategoryGroup.fromJson(Map<String, dynamic> json) => CategoryGroup(
    category: json['category']?.toString(),
    itemCount:
        json['itemCount'] is int
            ? json['itemCount']
            : int.tryParse('${json['itemCount'] ?? ''}'),
    displayText: json['displayText']?.toString(),
    items:
        ((json['items'] is List) ? (json['items'] as List) : const [])
            .whereType<Map>()
            .map((e) => GroupedProduct.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
  );
}

class GroupedProduct {
  final String? name;
  final String? sku;
  final num? price;
  final int? totalQuantity;
  final List<String> itemIds;
  final List<String> orders;
  final List<String> orderReferences; // order numbers/refs for "View Orders"
  final String? imageUrl;
  final String? productImages;

  GroupedProduct({
    this.name,
    this.sku,
    this.price,
    this.totalQuantity,
    this.itemIds = const [],
    this.orders = const [],
    this.orderReferences = const [],
    this.imageUrl,
    this.productImages,
  });

  factory GroupedProduct.fromJson(Map<String, dynamic> json) => GroupedProduct(
    name: json['name']?.toString(),
    sku: json['sku']?.toString(),
    price:
        json['price'] is num
            ? json['price']
            : num.tryParse('${json['price'] ?? ''}'),
    totalQuantity: json['totalQuantity'] ?? 0,
    itemIds:
        (json['itemIds'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
    orders:
        (json['orders'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
    orderReferences:
        (json['orderReferences'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
    imageUrl: json['imageUrl']?.toString(),
    productImages:
        (() {
          final dynamic imgs =
              json['product_images'] ??
              json['productImages'] ??
              json['images'] ??
              json['imageUrls'];
          if (imgs == null) return null;
          if (imgs is List) {
            // Join list into a single comma-separated string so caller can parse first URL
            return imgs
                .map((e) => e?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .join(',');
          }
          return imgs.toString();
        })(),
  );
}
