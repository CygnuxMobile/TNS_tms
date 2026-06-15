import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

InWardListResponse inWardListResponseFromJson(String str) => InWardListResponse.fromJson(json.decode(str));

class InWardListResponse {
  final String statusCode;
  final int status;
  final List<InWardListObject> inWardList;
  final dynamic errors;
  final dynamic metaData;
  final String message;

  InWardListResponse({
    required this.statusCode,
    required this.status,
    required this.inWardList,
    required this.errors,
    required this.metaData,
    required this.message,
  });

  factory InWardListResponse.fromJson(Map<String, dynamic> json) => InWardListResponse(
        statusCode: json["statusCode"].toString(),
        status: json["status"],
        inWardList: List<InWardListObject>.from(json["data"].map((x) => InWardListObject.fromJson(x))),
        errors: json["errors"].toString(),
        metaData: json["metaData"].toString(),
        message: json["message"].toString(),
      );
}

class InWardListObject {
  final String thcno;
  final String thcbr;
  final String thCDate;
  final String vehicleNo;
  final String arrivalDate;
  final String manifestKount;
  final String docketKount;
  final String tctobHCode;
  final String thcdt;
  final String actarrvDt;
  final String routecd;
  final String routename;
  final String bkgPkgsno;
  final String bkgActuwt;
  final String desTCD;
  final List<Docket> docket;

  InWardListObject({
    required this.thcno,
    required this.thcbr,
    required this.thCDate,
    required this.vehicleNo,
    required this.arrivalDate,
    required this.manifestKount,
    required this.docketKount,
    required this.tctobHCode,
    required this.thcdt,
    required this.actarrvDt,
    required this.routecd,
    required this.routename,
    required this.bkgPkgsno,
    required this.bkgActuwt,
    required this.docket,
    required this.desTCD,
  });

  factory InWardListObject.fromJson(Map<String, dynamic> json) => InWardListObject(
        thcno: json["thcno"].toString(),
        thcbr: json["thcbr"].toString(),
        thCDate: json["thC_Date"].toString(),
        vehicleNo: json["vehicle_No"].toString(),
        arrivalDate: json["arrival_Date"].toString(),
        manifestKount: json["manifestKount"].toString(),
        docketKount: json["docketKount"].toString(),
        tctobHCode: json["tctobH_Code"].toString(),
        thcdt: json["thcdt"].toString().toString(),
        actarrvDt: json["actarrv_dt"].toString(),
        routecd: json["routecd"].toString(),
        routename: json["routename"].toString(),
        bkgPkgsno: json['bkG_PKGSNO'].toString(),
        bkgActuwt: json['bkG_ACTUWT'].toString(),
        desTCD: json["desT_CD"] ?? '',
        docket: List<Docket>.from(json["docket"].map((x) => Docket.fromJson(x))),
      );
}

class DocketBcSerialList {
  final String dockno;
  final num bkGPkgsNO;
  final num bkGActuwt;
  final String docksf;
  final String bcSerialNo;
  final String mf;
  final String thc;
  final RxString severity;
  String damageCodeId;
  RxString damageCodeType;
  RxBool isScan;
  RxBool isDamage;
  RxBool isAddDamage;
  RxBool isEdit;
  RxBool isAccess;
  RxBool isPillFill;
  RxBool isShortage;
  RxBool isExpand;
  int? pillFillAgeCount;
  int? damageAgeCount;
  RxList<String> damageImages;

  // GlobalKey<FormState> damageTypeFromKey;
  List<String>? shortageImagesImages = [];

  DocketBcSerialList({
    required this.dockno,
    required this.bkGPkgsNO,
    required this.bkGActuwt,
    required this.docksf,
    required this.bcSerialNo,
    required this.mf,
    required this.thc,
    required this.damageCodeId,
    required this.damageCodeType,
    required this.severity,
    required this.isScan,
    required this.isAccess,
    required this.isDamage,
    required this.isAddDamage,
    required this.isPillFill,
    required this.isShortage,
    required this.isExpand,
    required this.isEdit,
    this.pillFillAgeCount = 0,
    this.damageAgeCount = 0,
    required this.damageImages,
    this.shortageImagesImages,
    // required this.damageTypeFromKey,
  });

  factory DocketBcSerialList.fromJson(Map<String, dynamic> json) => DocketBcSerialList(
        dockno: json["dockno"].toString(),
        docksf: json["docksf"].toString(),
        bcSerialNo: json["bcSerialNo"].toString(),
        mf: json["mf"].toString(),
        thc: json["thc"].toString(),
        bkGActuwt: json["bkG_ACTUWT"] ?? 0,
        bkGPkgsNO: json["bkG_PKGSNO"] ?? 0,
        damageCodeId: json["damageCodeId"] ?? '',
        damageCodeType: RxString(json["damageCodeType"] ?? ''),
        damageImages: RxList(json["damageImages"] ?? []),
        severity: RxString(json["severity"] ?? ''),
        isScan: RxBool(json["isScan"] ?? false),
        isAddDamage: RxBool(json["isAddDamage"] ?? false),
        isEdit: RxBool(json["isEdit"] ?? false),
        isAccess: RxBool(json["isAccess"] ?? false),
        isDamage: RxBool(json["isDamage"] ?? false),
        isPillFill: RxBool(json["isPillFill"] ?? false),
        isShortage: RxBool(json["isShortage"] ?? false),
        isExpand: RxBool(json["isExpand"] ?? false),
      );
}

class Docket {
  final String dockNo;
  final String manifestNo;
  final num bkGPKGSNO;
  final num bkGACTUWT;
  final RxString lastScan;
  final RxBool isFullScan;
  final RxBool isMisroute;
  final RxBool isOpen;
  final List<DocketBcSerialList> docketBcSerials;

  Docket(
      {required this.dockNo,
      required this.bkGACTUWT,
      required this.bkGPKGSNO,
      required this.manifestNo,
      required this.isFullScan,
      required this.docketBcSerials,
      required this.isMisroute,
      required this.isOpen,
      required this.lastScan});

  factory Docket.fromJson(Map<String, dynamic> json) => Docket(
        dockNo: json["dockNo"],
        manifestNo: json["manifestNo"] = json["docket_BCSerials"][0]["mf"],
        bkGACTUWT: json["bkG_ACTUWT"] ?? 0,
        bkGPKGSNO: json["bkG_PKGSNO"] ?? 0,
        isFullScan: RxBool(json["isFullScan"] ?? false),
        lastScan: RxString(json["lastScan"] ?? ''),
        isOpen: RxBool(json["isOpen"] ?? false),
        isMisroute: RxBool(json["misroute"] ?? false),
        docketBcSerials: List<DocketBcSerialList>.from(json["docket_BCSerials"].map((x) => DocketBcSerialList.fromJson(x))),
      );
}
