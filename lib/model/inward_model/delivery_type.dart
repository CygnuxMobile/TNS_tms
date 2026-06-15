import 'dart:convert';

DeliveryTypeResponse deliveryTypeResponseFromJson(String str) => DeliveryTypeResponse.fromJson(json.decode(str));

String deliveryTypeResponseToJson(DeliveryTypeResponse data) => json.encode(data.toJson());

class DeliveryTypeResponse {
  final int statusCode;
  final int status;
  final List<DeliveryTypeObject> deliveryTypeList;
  final dynamic errors;
  final dynamic metaData;
  final String message;

  DeliveryTypeResponse({
    required this.statusCode,
    required this.status,
    required this.deliveryTypeList,
    required this.errors,
    required this.metaData,
    required this.message,
  });

  DeliveryTypeResponse copyWith({
    int? statusCode,
    int? status,
    List<DeliveryTypeObject>? deliveryTypeList,
    dynamic errors,
    dynamic metaData,
    String? message,
  }) =>
      DeliveryTypeResponse(
        statusCode: statusCode ?? this.statusCode,
        status: status ?? this.status,
        deliveryTypeList: deliveryTypeList ?? this.deliveryTypeList,
        errors: errors ?? this.errors,
        metaData: metaData ?? this.metaData,
        message: message ?? this.message,
      );

  factory DeliveryTypeResponse.fromJson(Map<String, dynamic> json) => DeliveryTypeResponse(
    statusCode: json["statusCode"],
    status: json["status"],
    deliveryTypeList: List<DeliveryTypeObject>.from(json["data"].map((x) => DeliveryTypeObject.fromJson(x))),
    errors: json["errors"],
    metaData: json["metaData"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "status": status,
    "data": List<dynamic>.from(deliveryTypeList.map((x) => x.toJson())),
    "errors": errors,
    "metaData": metaData,
    "message": message,
  };
}

class DeliveryTypeObject {
  final String codeType;
  final String codeId;
  final String codeDesc;
  final String codeAccess;

  DeliveryTypeObject({
    required this.codeType,
    required this.codeId,
    required this.codeDesc,
    required this.codeAccess,
  });

  DeliveryTypeObject copyWith({
    String? codeType,
    String? codeId,
    String? codeDesc,
    String? codeAccess,
  }) =>
      DeliveryTypeObject(
        codeType: codeType ?? this.codeType,
        codeId: codeId ?? this.codeId,
        codeDesc: codeDesc ?? this.codeDesc,
        codeAccess: codeAccess ?? this.codeAccess,
      );

  factory DeliveryTypeObject.fromJson(Map<String, dynamic> json) => DeliveryTypeObject(
    codeType: json["codeType"],
    codeId: json["codeId"],
    codeDesc: json["codeDesc"],
    codeAccess: json["codeAccess"],
  );

  Map<String, dynamic> toJson() => {
    "codeType": codeType,
    "codeId": codeId,
    "codeDesc": codeDesc,
    "codeAccess": codeAccess,
  };
}
