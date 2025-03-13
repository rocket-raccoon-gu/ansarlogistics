import 'dart:convert';

BranchSectionDataResponse branchSectionDataResponseFromJson(String str) =>
    BranchSectionDataResponse.fromJson(json.decode(str));

String branchSectionDataResponseToJson(BranchSectionDataResponse data) =>
    json.encode(data.toJson());

class BranchSectionDataResponse {
  List<Branchdatum> branchdata;

  BranchSectionDataResponse({
    required this.branchdata,
  });

  factory BranchSectionDataResponse.fromJson(Map<String, dynamic> json) =>
      BranchSectionDataResponse(
        branchdata: List<Branchdatum>.from(
            json["data"].map((x) => Branchdatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(branchdata.map((x) => x.toJson())),
      };
}

class Branchdatum {
  String id;
  String categoryId;
  String productName;
  String sku;
  String status;
  String userId;
  DateTime updatedAt;
  String branchCode;

  Branchdatum({
    required this.id,
    required this.categoryId,
    required this.productName,
    required this.sku,
    required this.status,
    required this.userId,
    required this.updatedAt,
    required this.branchCode,
  });

  factory Branchdatum.fromJson(Map<String, dynamic> json) => Branchdatum(
        id: json["id"].toString(),
        categoryId: json["category_id"].toString(),
        productName: json["product_name"],
        sku: json["sku"],
        status: json["status"].toString(),
        userId: json["user_id"],
        updatedAt: DateTime.parse(json["updated_at"]),
        branchCode: json["branch_code"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "category_id": categoryId,
        "product_name": productName,
        "sku": sku,
        "status": status,
        "user_id": userId,
        "updated_at": updatedAt.toIso8601String(),
        "branch_code": branchCode,
      };
}
