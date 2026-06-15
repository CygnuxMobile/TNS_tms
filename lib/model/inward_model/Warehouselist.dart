import 'dart:convert';

WareHouseListResponse wareHouseListResponseFromJson(String str) => WareHouseListResponse.fromJson(json.decode(str));

String wareHouseListResponseToJson(WareHouseListResponse data) => json.encode(data.toJson());

class WareHouseListResponse {
  final int statusCode;
  final int status;
  final List<WareHouseListObject> data;
  final dynamic errors;
  final dynamic metaData;
  final String message;

  WareHouseListResponse({
    required this.statusCode,
    required this.status,
    required this.data,
    required this.errors,
    required this.metaData,
    required this.message,
  });

  WareHouseListResponse copyWith({
    int? statusCode,
    int? status,
    List<WareHouseListObject>? wareHouseList,
    dynamic errors,
    dynamic metaData,
    String? message,
  }) =>
      WareHouseListResponse(
        statusCode: statusCode ?? this.statusCode,
        status: status ?? this.status,
        data: wareHouseList ?? this.data,
        errors: errors ?? this.errors,
        metaData: metaData ?? this.metaData,
        message: message ?? this.message,
      );

  factory WareHouseListResponse.fromJson(Map<String, dynamic> json) => WareHouseListResponse(
    statusCode: json["statusCode"],
    status: json["status"],
    data: List<WareHouseListObject>.from(json["data"].map((x) => WareHouseListObject.fromJson(x))),
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

class WareHouseListObject {
  final int godownSrno;
  final String godownName;
  final String spdbrcd;
  final String activeFlag;

  WareHouseListObject({
    required this.godownSrno,
    required this.godownName,
    required this.spdbrcd,
    required this.activeFlag,
  });

  WareHouseListObject copyWith({
    int? godownSrno,
    String? godownName,
    String? spdbrcd,
    String? activeFlag,
  }) =>
      WareHouseListObject(
        godownSrno: godownSrno ?? this.godownSrno,
        godownName: godownName ?? this.godownName,
        spdbrcd: spdbrcd ?? this.spdbrcd,
        activeFlag: activeFlag ?? this.activeFlag,
      );

  factory WareHouseListObject.fromJson(Map<String, dynamic> json) => WareHouseListObject(
    godownSrno: json["godown_srno"],
    godownName: json["godown_name"],
    spdbrcd: json["spdbrcd"],
    activeFlag: json["activeFlag"],
  );

  Map<String, dynamic> toJson() => {
    "godown_srno": godownSrno,
    "godown_name": godownName,
    "spdbrcd": spdbrcd,
    "activeFlag": activeFlag,
  };
}
