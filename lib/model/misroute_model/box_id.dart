import 'dart:convert';

BoxIdResponse boxIdResponseFromJson(String str) => BoxIdResponse.fromJson(json.decode(str));

String boxIdResponseToJson(BoxIdResponse data) => json.encode(data.toJson());

class BoxIdResponse {
  final int statusCode;
  final int status;
  final Data data;
  final dynamic errors;
  final dynamic metaData;
  final String message;

  BoxIdResponse({
    required this.statusCode,
    required this.status,
    required this.data,
    required this.errors,
    required this.metaData,
    required this.message,
  });

  BoxIdResponse copyWith({
    int? statusCode,
    int? status,
    Data? data,
    dynamic errors,
    dynamic metaData,
    String? message,
  }) =>
      BoxIdResponse(
        statusCode: statusCode ?? this.statusCode,
        status: status ?? this.status,
        data: data ?? this.data,
        errors: errors ?? this.errors,
        metaData: metaData ?? this.metaData,
        message: message ?? this.message,
      );

  factory BoxIdResponse.fromJson(Map<String, dynamic> json) => BoxIdResponse(
        statusCode: json["statusCode"],
        status: json["status"],
        data: Data.fromJson(json["data"]),
        errors: json["errors"],
        metaData: json["metaData"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "statusCode": statusCode,
        "status": status,
        "data": data.toJson(),
        "errors": errors,
        "metaData": metaData,
        "message": message,
      };
}

class Data {
  final int isExists;
  final String dockno;
  final String orgncd;
  final String destcd;
  final String boxId;
  final String currLoc;
  final int isFull;
  final int pkgsno;
  final dynamic msg;

  Data({
    required this.isExists,
    required this.dockno,
    required this.isFull,
    required this.orgncd,
    required this.destcd,
    required this.currLoc,
    required this.boxId,
    required this.pkgsno,
    required this.msg,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        isExists: json["isExists"] ?? '',
        dockno: json["dockno"] ?? '',
        orgncd: json["orgncd"] ?? '',
        destcd: json["destcd"] ?? '',
        isFull: json["isFull"] ?? 0,
        boxId: json["boxId"] ?? '',
        currLoc: json["curr_Loc"] ?? '',
        pkgsno: json["pkgsno"] is double ? (json["pkgsno"] as double).toInt() : int.tryParse(json["pkgsno"].toString()) ?? 0,
        msg: json["msg"],
      );

  Map<String, dynamic> toJson() => {
        "isExists": isExists,
        "dockno": dockno,
        "orgncd": orgncd,
        "destcd": destcd,
        "boxId": boxId,
        "pkgsno": pkgsno,
        "msg": msg,
      };
}
