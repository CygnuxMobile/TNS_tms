import 'dart:convert';

GetBcSerialDetailsResponse getBcSerialDetailsResponseFromJson(String str) => GetBcSerialDetailsResponse.fromJson(json.decode(str));

String getBcSerialDetailsResponseToJson(GetBcSerialDetailsResponse data) => json.encode(data.toJson());

class GetBcSerialDetailsResponse {
  final int statusCode;
  final int status;
  final List<BcSerialDatum> bcSerialData;
  final String errors;
  final String metaData;
  final String message;

  GetBcSerialDetailsResponse({
    required this.statusCode,
    required this.status,
    required this.bcSerialData,
    required this.errors,
    required this.metaData,
    required this.message,
  });

  factory GetBcSerialDetailsResponse.fromJson(Map<String, dynamic> json) => GetBcSerialDetailsResponse(
    statusCode: json["statusCode"]??0,
    status: json["status"]??0,
    bcSerialData: List<BcSerialDatum>.from(json["data"].map((x) => BcSerialDatum.fromJson(x))),
    errors: json["errors"]??"",
    metaData: json["metaData"]??"",
    message: json["message"]??"",
  );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "status": status,
    "BcSerialData": List<dynamic>.from(bcSerialData.map((x) => x.toJson())),
    "errors": errors,
    "metaData": metaData,
    "message": message,
  };
}

class BcSerialDatum {
  final String dockNo;
  final String bcSerialNo;

  BcSerialDatum({
    required this.dockNo,
    required this.bcSerialNo,
  });

  factory BcSerialDatum.fromJson(Map<String, dynamic> json) => BcSerialDatum(
    dockNo: json["dockNo"]??"",
    bcSerialNo: json["bcSerialNo"]??"",
  );

  Map<String, dynamic> toJson() => {
    "dockNo": dockNo,
    "bcSerialNo": bcSerialNo,
  };
}
