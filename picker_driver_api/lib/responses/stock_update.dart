class StockUpdate {
  final String sku;
  final String name;
  final String imageUrl;
  final bool isEnabled;
  final DateTime updatedAt;

  StockUpdate({
    required this.sku,
    required this.name,
    required this.imageUrl,
    required this.isEnabled,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'sku': sku,
      'name': name,
      'imageUrl': imageUrl,
      'isEnabled': isEnabled,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory StockUpdate.fromMap(Map<String, dynamic> map) {
    return StockUpdate(
      sku: map['sku'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      isEnabled: map['isEnabled'],
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
