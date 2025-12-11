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
  Map<String, dynamic>? suborderStatuses;

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
    this.suborderStatuses,
  });

  factory OrderNew.fromJson(Map<String, dynamic> json) => OrderNew(
    id: json['id']?.toString(),
    status: json['status']?.toString(),
    statusText: json['statusText']?.toString(),
    deliveryNote: json['deliveryNote']?.toString(),
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
                  if (deliveryType is List && deliveryType.isNotEmpty) {
                    final String typeCode = '${deliveryType[0] ?? ''}';
                    if (deliveryType.length > 1 && deliveryType[1] is List) {
                      return (deliveryType[1] as List) // categories
                          .whereType<Map>()
                          .expand((category) {
                            final String? catName =
                                category['category']?.toString();
                            if (category['items'] is List) {
                              return (category['items'] as List)
                                  .whereType<Map>()
                                  .map<OrderItemNew>((e) {
                                    final map = Map<String, dynamic>.from(e);
                                    // Inject parent category and delivery type so UI can group correctly
                                    map['category'] =
                                        map['category'] ??
                                        map['categoryName'] ??
                                        catName;
                                    map['delivery_type'] =
                                        map['delivery_type'] ??
                                        map['deliveryType'] ??
                                        typeCode;
                                    return OrderItemNew.fromJson(map);
                                  });
                            }
                            return <OrderItemNew>[];
                          });
                    }
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
    suborderStatuses:
        (json['suborderStatuses'] is Map)
            ? Map<String, dynamic>.from(json['suborderStatuses'] as Map)
            : null,
  );
}

class OrderItemNew {
  final String? id;
  final String? name;
  final String? sku;
  final String? price;
  final String? qtyOrdered;
  final String? qtyShipped;
  final String? categoryId;
  final String? categoryName;
  final String? imageUrl;
  final String? deliveryType;
  final String? itemStatus;
  final num? rowTotal;
  final num? rowTotalInclTax;
  final String? productImage;
  final bool? isProduce;
  final String? subgroupIdentifier;
  final String? productOptions;
  final String? finalPrice;

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
    this.productImage,
    this.isProduce,
    this.subgroupIdentifier,
    this.productOptions,
    this.finalPrice,
  });

  factory OrderItemNew.fromJson(Map<String, dynamic> json) => OrderItemNew(
    id: json['item_id']?.toString(),
    name: json['name']?.toString(),
    sku: json['sku']?.toString(),
    price: json['price']?.toString(),
    qtyOrdered:
        json['qty_ordered'] is String
            ? json['qty_ordered']
            : int.tryParse('${json['qty_ordered'] ?? ''}'),
    qtyShipped: '${json['qty_shipped'] ?? ''}',
    categoryId: (json['categoryId'] ?? json['category_id'])?.toString(),
    categoryName: (json['categoryName'] ?? json['category'])?.toString(),
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
    productImage: json['product_images']?.toString(),
    isProduce: json['is_produce']?.toString() == '1',
    subgroupIdentifier: json['subgroup_identifier']?.toString(),
    productOptions:
        json['product_options'] == null
            ? ""
            : json['product_options']?.toString(),
    finalPrice: json['final_price']?.toString(),
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
  final List<int> itemIds;
  final List<ProductOrders> orders;
  final List<String> orderReferences; // order numbers/refs for "View Orders"
  final String? imageUrl;
  final String? productImages;
  final String? itemStatus;

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
    this.itemStatus,
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
            .map((e) => e as int)
            .toList(),
    orders:
        (json['orders'] as List<dynamic>? ?? const [])
            .map((e) => ProductOrders.fromJson(e))
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
    itemStatus: json['item_status']?.toString(),
  );
}

class ProductOrders {
  String orderId;
  String orderStatus;
  String suborderType;
  String suborderStatus;
  DateTime deliveryDate;
  dynamic timeRange;
  int quantity;
  int itemId;
  String subgroupIdentifier;

  ProductOrders({
    required this.orderId,
    required this.orderStatus,
    required this.suborderType,
    required this.suborderStatus,
    required this.deliveryDate,
    required this.timeRange,
    required this.quantity,
    required this.itemId,
    required this.subgroupIdentifier,
  });

  factory ProductOrders.fromJson(Map<String, dynamic> json) => ProductOrders(
    orderId: json["orderId"]?.toString() ?? '',
    orderStatus: json["orderStatus"]?.toString() ?? '',
    suborderType: json["suborderType"]?.toString() ?? '',
    suborderStatus: json["suborderStatus"]?.toString() ?? '',
    deliveryDate: DateTime.parse(json["deliveryDate"]?.toString() ?? ''),
    timeRange: json["timeRange"]?.toString() ?? '',
    quantity: json["quantity"] ?? 0,
    itemId: json["itemId"] ?? 0,
    subgroupIdentifier: json["subgroupIdentifier"]?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    "orderId": orderId,
    "orderStatus": orderStatus,
    "suborderType": suborderType,
    "suborderStatus": suborderStatus,
    "deliveryDate": deliveryDate.toIso8601String(),
    "timeRange": timeRange,
    "quantity": quantity,
    "itemId": itemId,
    "subgroupIdentifier": subgroupIdentifier,
  };
}
