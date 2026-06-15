import 'dart:convert';

OutWardList outWardListFromJson(String str) =>
    OutWardList.fromJson(json.decode(str));

String outWardListToJson(OutWardList data) => json.encode(data.toJson());

class OutWardList {
  final int statusCode;
  final int status;
  final List<OutWardListObject> outWardList;
  final dynamic errors;
  final dynamic metaData;
  final String message;

  OutWardList({
    required this.statusCode,
    required this.status,
    required this.outWardList,
    required this.errors,
    required this.metaData,
    required this.message,
  });

  OutWardList copyWith({
    int? statusCode,
    int? status,
    List<OutWardListObject>? data,
    dynamic errors,
    dynamic metaData,
    String? message,
  }) =>
      OutWardList(
        statusCode: statusCode ?? this.statusCode,
        status: status ?? this.status,
        outWardList: data ?? this.outWardList,
        errors: errors ?? this.errors,
        metaData: metaData ?? this.metaData,
        message: message ?? this.message,
      );

  factory OutWardList.fromJson(Map<String, dynamic> json) => OutWardList(
        statusCode: json["statusCode"],
        status: json["status"],
        outWardList: List<OutWardListObject>.from(json["data"].map((x) => OutWardListObject.fromJson(x))),
        errors: json["errors"],
        metaData: json["metaData"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "statusCode": statusCode,
        "status": status,
        "data": List<dynamic>.from(outWardList.map((x) => x.toJson())),
        "errors": errors,
        "metaData": metaData,
        "message": message,
      };
}

class OutWardListObject {
  final String tcno;
  final String tcdt;
  final String tcbr;
  final String loc;
  final String tobhCode;
  final num toTDkt;
  final num totPkgs;
  final num totActuwt;
  final String manualLSno;

  OutWardListObject({
    required this.tcno,
    required this.tcdt,
    required this.tcbr,
    required this.loc,
    required this.tobhCode,
    required this.toTDkt,
    required this.totPkgs,
    required this.totActuwt,
    required this.manualLSno,
  });

  factory OutWardListObject.fromJson(Map<String, dynamic> json) => OutWardListObject(
        tcno: json["tcno"] ?? "",
        tcdt: json["tcdt"] ?? "",
        tcbr: json["tcbr"] ?? "",
        loc: json["loc"] ?? "",
        tobhCode: json["tobh_code"] ?? '',
        toTDkt: json["toT_DKT"] ?? 0,
        totPkgs: json["tot_pkgs"] ?? 0,
        totActuwt: json["tot_actuwt"] ?? 0,
        manualLSno: json["manualLSno"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "tcno": tcno,
        "tcdt": tcdt,
        "tcbr": tcbr,
        "loc": loc,
        "tobh_code": tobhCode,
        "toT_DKT": toTDkt,
        "tot_pkgs": totPkgs,
        "tot_actuwt": totActuwt,
        "manualLSno": manualLSno,
      };
}
