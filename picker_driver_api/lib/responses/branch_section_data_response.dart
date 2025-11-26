// To parse this JSON data, do
//
//     final branchSectionDataResponse = branchSectionDataResponseFromJson(jsonString);

import 'dart:convert';

BranchSectionDataResponse branchSectionDataResponseFromJson(String str) =>
    BranchSectionDataResponse.fromJson(json.decode(str));

String branchSectionDataResponseToJson(BranchSectionDataResponse data) =>
    json.encode(data.toJson());

class BranchSectionDataResponse {
  List<Branchdatum> data;

  BranchSectionDataResponse({required this.data});

  factory BranchSectionDataResponse.fromJson(Map<String, dynamic> json) =>
      BranchSectionDataResponse(
        data: List<Branchdatum>.from(
          json["data"].map((x) => Branchdatum.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Branchdatum {
  int id;
  int categoryId;
  String productName;
  String sku;
  int status;
  UserId userId;
  BranchCode branchCode;
  DateTime updatedAt;
  DateTime latestUpdate;
  String imageUrl;

  Branchdatum({
    required this.id,
    required this.categoryId,
    required this.productName,
    required this.sku,
    required this.status,
    required this.userId,
    required this.branchCode,
    required this.updatedAt,
    required this.latestUpdate,
    required this.imageUrl,
  });

  factory Branchdatum.fromJson(Map<String, dynamic> json) => Branchdatum(
    id: json["id"],
    categoryId: json["category_id"],
    productName: json["product_name"],
    sku: json["sku"],
    status: json["status"],
    userId: userIdValues.map[json["user_id"]]!,
    branchCode: branchCodeValues.map[json["branch_code"]]!,
    updatedAt: DateTime.parse(json["updated_at"]),
    latestUpdate: DateTime.parse(json["latest_update"]),
    imageUrl: json["image_url"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "category_id": categoryId,
    "product_name": productName,
    "sku": sku,
    "status": status,
    "user_id": userIdValues.reverse[userId],
    "branch_code": branchCodeValues.reverse[branchCode],
    "updated_at": updatedAt.toIso8601String(),
    "latest_update": latestUpdate.toIso8601String(),
    "image_url": imageUrl,
  };
}

enum BranchCode { Q015 }

final branchCodeValues = EnumValues({"Q015": BranchCode.Q015});

enum UserId { EMPTY, FISH_RAWDAH, RAWDAH_BUTCH, VEG_RAWDAH }

final userIdValues = EnumValues({
  "": UserId.EMPTY,
  "fish_rawdah": UserId.FISH_RAWDAH,
  "rawdah_butch": UserId.RAWDAH_BUTCH,
  "veg_rawdah": UserId.VEG_RAWDAH,
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
