
import 'dart:convert';

ConsigneeConsignor consigneeConsignorFromJson(String str) => ConsigneeConsignor.fromJson(json.decode(str));

String consigneeConsignorToJson(ConsigneeConsignor data) => json.encode(data.toJson());

class ConsigneeConsignor {
  final int statusCode;
  final int status;
  final List<ConCosDatum> data;
  final dynamic errors;
  final dynamic metaData;
  final String message;

  ConsigneeConsignor({
    required this.statusCode,
    required this.status,
    required this.data,
    required this.errors,
    required this.metaData,
    required this.message,
  });

  factory ConsigneeConsignor.fromJson(Map<String, dynamic> json) => ConsigneeConsignor(
    statusCode: json["statusCode"],
    status: json["status"],
    data: List<ConCosDatum>.from(json["data"].map((x) => ConCosDatum.fromJson(x))),
    errors: json["errors"],
    metaData: json["metaData"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "errors": errors,
    "metaData": metaData,
    "message": message,
  };
}

class ConCosDatum {
  final String custcd;
  final String custnm;
  final dynamic volYn;
  final dynamic transType;

  ConCosDatum({
    required this.custcd,
    required this.custnm,
    required this.volYn,
    required this.transType,
  });

  factory ConCosDatum.fromJson(Map<String, dynamic> json) => ConCosDatum(
    custcd: json["custcd"] ?? '',
    custnm: json["custnm"] ?? '',
    volYn: json["vol_yn"],
    transType: json["trans_type"],
  );

  Map<String, dynamic> toJson() => {
    "custcd": custcd,
    "custnm": custnm,
    "vol_yn": volYn,
    "trans_type": transType,
  };
}
