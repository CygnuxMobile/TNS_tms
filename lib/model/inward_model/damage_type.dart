import 'dart:convert';

DamageTypeResponse damageTypeResponseFromJson(String str) => DamageTypeResponse.fromJson(json.decode(str));

String damageTypeResponseToJson(DamageTypeResponse data) => json.encode(data.toJson());

class DamageTypeResponse {
  final int statusCode;
  final int status;
  final List<DamageTypeList> damageTypeList;
  final dynamic errors;
  final dynamic metaData;
  final String message;

  DamageTypeResponse({
    required this.statusCode,
    required this.status,
    required this.damageTypeList,
    required this.errors,
    required this.metaData,
    required this.message,
  });

  DamageTypeResponse copyWith({
    int? statusCode,
    int? status,
    List<DamageTypeList>? data,
    dynamic errors,
    dynamic metaData,
    String? message,
  }) =>
      DamageTypeResponse(
        statusCode: statusCode ?? this.statusCode,
        status: status ?? this.status,
        damageTypeList: data ?? this.damageTypeList,
        errors: errors ?? this.errors,
        metaData: metaData ?? this.metaData,
        message: message ?? this.message,
      );

  factory DamageTypeResponse.fromJson(Map<String, dynamic> json) => DamageTypeResponse(
    statusCode: json["statusCode"],
    status: json["status"],
    damageTypeList: List<DamageTypeList>.from(json["data"].map((x) => DamageTypeList.fromJson(x))),
    errors: json["errors"],
    metaData: json["metaData"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "status": status,
    "data": List<dynamic>.from(damageTypeList.map((x) => x.toJson())),
    "errors": errors,
    "metaData": metaData,
    "message": message,
  };
}

class DamageTypeList {
  final String codeType;
  final String codeId;
  final String codeDesc;
  final String codeAccess;
  final String codefor;

  DamageTypeList({
    required this.codeType,
    required this.codeId,
    required this.codeDesc,
    required this.codeAccess,
    required this.codefor,
  });

  DamageTypeList copyWith({
    String? codeType,
    String? codeId,
    String? codeDesc,
    String? codeAccess,
    String? codefor,
  }) =>
      DamageTypeList(
        codeType: codeType ?? this.codeType,
        codeId: codeId ?? this.codeId,
        codeDesc: codeDesc ?? this.codeDesc,
        codeAccess: codeAccess ?? this.codeAccess,
        codefor: codefor ?? this.codefor,
      );

  factory DamageTypeList.fromJson(Map<String, dynamic> json) => DamageTypeList(
    codeType: json["codeType"],
    codeId: json["codeId"],
    codeDesc: json["codeDesc"],
    codeAccess: json["codeAccess"],
    codefor: json["codefor"],
  );

  Map<String, dynamic> toJson() => {
    "codeType": codeType,
    "codeId": codeId,
    "codeDesc": codeDesc,
    "codeAccess": codeAccess,
    "codefor": codefor,
  };
}
