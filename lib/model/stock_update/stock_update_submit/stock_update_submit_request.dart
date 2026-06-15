import 'dart:convert';

String stockUpdateDetailsToJson(StockUpdateDetails data) => json.encode(data.toJson());

String stockUpdateDetailToJson(StockUpdateDetail data) => json.encode(data.toJson());

class StockUpdateDetails {
  static StockUpdateDetails? _instance;

  final String updateDate;
  final String baseUserName;
  final String baseLocationCode;
  final List<StockUpdateDetail> stockUpdateDetails;
  final List<BsSerial> bsSerials;

  StockUpdateDetails({
    required this.updateDate,
    required this.baseUserName,
    required this.baseLocationCode,
    required this.stockUpdateDetails,
    required this.bsSerials,
  });

  Map<String, dynamic> toJson() => {
        "updateDate": updateDate,
        "baseUserName": baseUserName,
        "baseLocationCode": baseLocationCode,
        "stockUpdateDetails": List<dynamic>.from(stockUpdateDetails.map((detail) => detail.toJson())),
        "bsSerials": List<dynamic>.from(bsSerials.map((x) => x.toJson())),
      };
}

class BsSerial {
  final String dockno;
  final String docksf;
  final String bcSerialNo;
  final String mf;
  final String thc;

  BsSerial({
    required this.dockno,
    required this.docksf,
    required this.bcSerialNo,
    required this.mf,
    required this.thc,
  });

  factory BsSerial.fromJson(Map<String, dynamic> json) => BsSerial(
        dockno: json["dockno"],
        docksf: json["docksf"],
        bcSerialNo: json["bcSerialNo"],
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

class StockUpdateDetail {
  final String tcno;
  final String dockNo;
  final String dockSf;
  final int bkGPkgsno;
  final int pkgsno;
  final int bkGActuwt;
  final int actuwt;
  final String ac;
  final String wi;
  final String cdelydt;
  final String delyreason;
  final String dp;
  final int coddodAmount;
  final int coddodcollected;
  final String coddod;
  final bool isCounterDelivery;
  final String isMisroute;
  final String misrtDockno;
  final String orgncd;
  final String destCD;
  final int pkgs;
  final int misrtpkg;
  final List<String> boxIds;
  final int shortageQty;
  final int shortageWeight;
  final String shortageReason;
  final String shortageRemarks;
  final int pilferageQty;
  final int pilferageWeight;
  final String pilferageReason;
  final String severity;
  final String damageType;
  final String isCODDODChar;
  final String delyperson;
  final String pilferageRemarks;
  final int damageQry;
  final int damageWeight;
  final String damageReason;
  final String damageRemarks;
  final String isCoddodChar;
  final List<AgeFileName> pilferageFileName;
  final List<AgeFileName> damageFileName;

  StockUpdateDetail({
    required this.tcno,
    required this.dockNo,
    required this.dockSf,
    required this.bkGPkgsno,
    required this.pkgsno,
    required this.bkGActuwt,
    required this.actuwt,
    required this.ac,
    required this.wi,
    required this.cdelydt,
    required this.delyreason,
    required this.dp,
    required this.coddodAmount,
    required this.coddodcollected,
    required this.coddod,
    required this.isCounterDelivery,
    required this.shortageQty,
    required this.shortageWeight,
    required this.shortageReason,
    required this.shortageRemarks,
    required this.pilferageQty,
    required this.pilferageWeight,
    required this.pilferageReason,
    required this.pilferageRemarks,
    required this.damageQry,
    required this.damageWeight,
    required this.damageReason,
    required this.damageRemarks,
    required this.isCoddodChar,
    required this.delyperson,
    required this.pilferageFileName,
    required this.damageFileName,
    required this.misrtDockno,
    required this.severity,
    required this.damageType,
    required this.isCODDODChar,
    required this.boxIds,
    required this.pkgs,
    required this.orgncd,
    required this.isMisroute,
    required this.destCD,
    required this.misrtpkg,
  });

  Map<String, dynamic> toJson() => {
        "tcno": tcno,
        "dockNo": dockNo,
        "dockSF": dockSf,
        "bkG_PKGSNO": bkGPkgsno,
        "pkgsno": pkgsno,
        "bkG_ACTUWT": bkGActuwt,
        "actuwt": actuwt,
        "ac": ac,
        "wi": wi,
        "cdelydt": cdelydt,
        "delyreason": delyreason,
        "dp": dp,
        "coddodAmount": coddodAmount,
        "coddodcollected": coddodcollected,
        "coddod": coddod,
        "isCounterDelivery": isCounterDelivery,
        "shortageQty": shortageQty,
        "shortageWeight": shortageWeight,
        "shortageReason": shortageReason,
        "shortageRemarks": shortageRemarks,
        "pilferageQty": pilferageQty,
        "pilferageWeight": pilferageWeight,
        "pilferageReason": pilferageReason,
        "pilferageRemarks": pilferageRemarks,
        "damageQry": damageQry,
        "damageWeight": damageWeight,
        "damageReason": damageReason,
        "damageRemarks": damageRemarks,
        "isCODDODChar": isCoddodChar,
        "delyperson": delyperson,
        "pilferageFileName": List<dynamic>.from(pilferageFileName.map((x) => x.toJson())),
        "damageFileName": List<dynamic>.from(damageFileName.map((x) => x.toJson())),
        "isMisroute": isMisroute,
        "misrtDockno": misrtDockno,
        "orgncd": orgncd,
        "destCD": destCD,
        "pkgs": pkgs,
        "misrtpkg": misrtpkg,
        "boxIds": boxIds,
        "severity": severity,
        "damageType": damageType,
      };
}

class AgeFileName {
  final String image;
  final String mf;

  AgeFileName({
    required this.image,
    required this.mf,
  });

  factory AgeFileName.fromJson(Map<String, dynamic> json) => AgeFileName(
        image: json["image"],
        mf: json["mf"],
      );

  Map<String, dynamic> toJson() => {
        "image": image,
        "mf": mf,
      };
}
