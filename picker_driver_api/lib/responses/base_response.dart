import 'dart:convert';

class BaseResponse {
  BaseResponse({
    required this.errorMsg,
    required this.errorCode,
    required this.transId,
  });

  final String errorMsg;
  final int errorCode;
  final int transId;

  BaseResponse copyWith({
    String? errorMsg,
    int? errorCode,
    int? transId,
  }) =>
      BaseResponse(
        errorMsg: errorMsg ?? this.errorMsg,
        errorCode: errorCode ?? this.errorCode,
        transId: transId ?? this.transId,
      );

  factory BaseResponse.fromJson(String str) =>
      BaseResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BaseResponse.fromMap(Map<String, dynamic> json) => BaseResponse(
        errorMsg: json["errorMsg"] ?? "",
        errorCode: int.tryParse(json["errorCode"].toString()) ?? 0,
        transId: json["transID"] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        "errorMsg": errorMsg,
        "errorCode": errorCode,
        "transID": transId,
      };
}
