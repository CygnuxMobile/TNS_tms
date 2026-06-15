import 'dart:convert';
import "package:get/get.dart";

BcNumberList bcNumberListFromJson(String str) => BcNumberList.fromJson(json.decode(str));

String bcNumberListToJson(BcNumberList data) => json.encode(data.toJson());

class BcNumberList {
  final int statusCode;
  final int status;
  final List<DocketNumberObject> docketNumberList;
  final dynamic errors;
  final dynamic metaData;
  final String message;

  BcNumberList({
    required this.statusCode,
    required this.status,
    required this.docketNumberList,
    this.errors,
    this.metaData,
    required this.message,
  });

  factory BcNumberList.fromJson(Map<String, dynamic> json) => BcNumberList(
    statusCode: json["statusCode"] ?? 0,
    status: json["status"] ?? 0,
    docketNumberList: json["data"] == null
        ? []
        : List<DocketNumberObject>.from(json["data"].map((x) => DocketNumberObject.fromJson(x))),
    errors: json["errors"],
    metaData: json["metaData"],
    message: json["message"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "status": status,
    "data": List<dynamic>.from(docketNumberList.map((x) => x.toJson())),
    "errors": errors,
    "metaData": metaData,
    "message": message,
  };
}

class DocketNumberObject {
  final int id;
  final String docketNo;
  final String manualDockno;
  final String docketDate;
  final String transMode;
  final String orgCode;
  final String reDestCode;
  final String lsNumber;
  final String fromTo;
  final String commitedDelyDate;
  final double pkgsno;
  final double actuwt;
  final int packagesLb;
  final int weightLb;
  final String dockno;
  final String docksf;
  final String lastScanNumber;
  RxBool isChecked = false.obs;
  final List<DocketBcSerial> docketBcSerials;

  DocketNumberObject({
    required this.id,
    required this.docketNo,
    required this.manualDockno,
    required this.docketDate,
    required this.transMode,
    required this.orgCode,
    required this.reDestCode,
    required this.fromTo,
    required this.commitedDelyDate,
    required this.pkgsno,
    required this.actuwt,
    required this.packagesLb,
    required this.weightLb,
    required this.dockno,
    required this.docksf,
    required this.docketBcSerials,
    required this.isChecked,
    required this.lastScanNumber,
    required this.lsNumber
  });

  factory DocketNumberObject.fromJson(Map<String, dynamic> json) => DocketNumberObject(
    id: json["id"] ?? 0,
    docketNo: json["docketNo"] ?? '',
    manualDockno: json["manual_dockno"] ?? '',
    docketDate: json["docketDate"] ?? '',
    transMode: json["transMode"] ?? '',
    orgCode: json["orgCode"] ?? '',
    reDestCode: json["reDestCode"] ?? '',
    fromTo: json["fromTo"] ?? '',
    commitedDelyDate: json["commited_DelyDate"] ?? '',
    pkgsno: json["pkgsno"] ?? 0.0,
    actuwt: json["actuwt"] ?? 0.0,
    packagesLb: json["packagesLB"] ?? 0,
    weightLb: json["weightLB"] ?? 0,
    dockno: json["dockno"] ?? '',
    docksf: json["docksf"] ?? '',
    lastScanNumber: json["lastScanNumber"] ?? '',
    isChecked: RxBool(json["isChecked"] ?? false),
    lsNumber: json['lsNumber'] ?? '',
    docketBcSerials: json["docket_BCSerials"] == null
        ? []
        : List<DocketBcSerial>.from(json["docket_BCSerials"].map((x) => DocketBcSerial.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "docketNo": docketNo,
    "manual_dockno": manualDockno,
    "docketDate": docketDate,
    "transMode": transMode,
    "orgCode": orgCode,
    "reDestCode": reDestCode,
    "fromTo": fromTo,
    "commited_DelyDate": commitedDelyDate,
    "pkgsno": pkgsno,
    "actuwt": actuwt,
    "packagesLB": packagesLb,
    "weightLB": weightLb,
    "dockno": dockno,
    "docksf": docksf,
    "docket_BCSerials": List<dynamic>.from(docketBcSerials.map((x) => x.toJson())),
  };
}

class DocketBcSerial {
  final String dockno;
  final String docksf;
  final String bcSerialNo;
  final RxString lastScan;
  final dynamic mf;
  final dynamic thc;
  final RxBool isBcNumberScan;

  DocketBcSerial( {
    required this.dockno,
    required this.docksf,
    required this.bcSerialNo,
    required this.isBcNumberScan,
    required this.lastScan,
    this.mf,
    this.thc,
  });

  factory DocketBcSerial.fromJson(Map<String, dynamic> json) => DocketBcSerial(
    dockno: json["dockno"] ?? '',
    docksf: json["docksf"] ?? '',
    bcSerialNo: json["bcSerialNo"] ?? '',
    isBcNumberScan: RxBool(json["isBcNumberScan"] ?? false),
    lastScan: RxString(json["lastScan"] ?? ""),
    mf: json["mf"],
    thc: json["thc"],
  );

  Map<String, dynamic> toJson() => {
    "dockno": dockno,
    "docksf": docksf,
    "bcSerialNo": bcSerialNo,
    "mf": mf,
    "thc": thc,
  };
}
