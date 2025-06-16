import 'dart:convert';

UpdateSectionRequest updateSectionRequestFromJson(String str) =>
    UpdateSectionRequest.fromJson(json.decode(str));

String updateSectionRequestToJson(UpdateSectionRequest data) =>
    json.encode(data.toJson());

class UpdateSectionRequest {
  int categoryId;
  String userId;
  String branchCode;
  List<NewStatus> newStatuses;
  String branch;

  UpdateSectionRequest({
    required this.categoryId,
    required this.userId,
    required this.branchCode,
    required this.newStatuses,
    required this.branch,
  });

  factory UpdateSectionRequest.fromJson(Map<String, dynamic> json) =>
      UpdateSectionRequest(
        categoryId: json["category_id"],
        userId: json["user_id"],
        branchCode: json["branch_code"],
        newStatuses: List<NewStatus>.from(
          json["newStatuses"].map((x) => NewStatus.fromJson(x)),
        ),
        branch: json["branch"],
      );

  Map<String, dynamic> toJson() => {
    "category_id": categoryId,
    "user_id": userId,
    "branch_code": branchCode,
    "newStatuses": List<dynamic>.from(newStatuses.map((x) => x.toJson())),
    "branch": branch,
  };
}

class NewStatus {
  String sku;
  String status;
  String productname;

  NewStatus({
    required this.sku,
    required this.status,
    required this.productname,
  });

  factory NewStatus.fromJson(Map<String, dynamic> json) => NewStatus(
    sku: json["sku"],
    status: json["status"],
    productname: json["productname"],
  );

  Map<String, dynamic> toJson() => {
    "sku": sku,
    "status": status,
    "productname": productname,
  };
}
