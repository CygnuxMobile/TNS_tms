import 'dart:convert';

String quickDocketSubmitToJson(QuickDocketSubmit data) =>
    json.encode(data.toJson());

class QuickDocketSubmit {
  final String dockdt;
  final String partYCode;
  final String partyName;
  final String orgncd;
  final String paybas;
  final String currFinYear;
  final String baseCompanyCode;
  final String destcd;
  final String dockno;
  final String baseUserName;
  final String transPortModel;
  final String pincode;
  final String toCity;
  final String fromCity;
  final String imageUpload;
  final String imageUpload1;
  final String imageUpload2;
  final String volYn;
  final String csgncd;
  final String csgnm;
  final String csgnAdd;
  final String csgecd;
  final String csgenm;
  final String csgeAdd;
  final String toPincode;
  final String vehicleType;
  final String vehicleno;
  final List<DocketInvoiceList> docketInvoiceList;

  QuickDocketSubmit({
    required this.dockdt,
    required this.partYCode,
    required this.partyName,
    required this.orgncd,
    required this.paybas,
    required this.currFinYear,
    required this.baseCompanyCode,
    required this.destcd,
    required this.dockno,
    required this.baseUserName,
    required this.transPortModel,
    required this.pincode,
    required this.toCity,
    required this.fromCity,
    required this.imageUpload,
    required this.imageUpload1,
    required this.imageUpload2,
    required this.volYn,
    required this.csgncd,
    required this.csgnm,
    required this.csgnAdd,
    required this.csgecd,
    required this.csgenm,
    required this.csgeAdd,
    required this.toPincode,
    required this.vehicleno,
    required this.vehicleType,
    required this.docketInvoiceList,
  });

  Map<String, dynamic> toJson() => {
        "dockdt": dockdt,
        "partY_CODE": partYCode,
        "party_name": partyName,
        "orgncd": orgncd,
        "paybas": paybas,
        "currFinYear": currFinYear,
        "baseCompanyCode": baseCompanyCode,
        "destcd": destcd,
        "dockno": dockno,
        "baseUserName": baseUserName,
        "transPortModel": transPortModel,
        "pincode": pincode,
        "toCity": toCity,
        // "imageUpload": imageUpload,
        // "imageUpload1": imageUpload1,
        // "imageUpload2": imageUpload2,
        "vol_yn": volYn,
        "csgncd": csgncd,
        "csgnm": csgnm,
        "csgnAdd": csgnAdd,
        "csgecd": csgecd,
        "csgenm": csgenm,
        "csgeAdd": csgeAdd,
        "fromCity": fromCity,
        "toPincode": toPincode,
        "vehicleno": vehicleno,
        "vehicleType": vehicleType,
        "docketInvoiceList":
            List<dynamic>.from(docketInvoiceList.map((x) => x.toJson())),
      };
}

class DocketInvoiceList {
  final String invno;
  final String prodcd;
  final String pkgsty;
  final int pkgs;
  final double decval;
  final double actuwt;
  final String ewbno;
  final double voLL;
  final double voLB;
  final double voLH;
  final String eWayBillExpiredDate;
  final String eWayBillInvoiceDate;

  DocketInvoiceList({
    required this.invno,
    required this.prodcd,
    required this.pkgsty,
    required this.pkgs,
    required this.decval,
    required this.actuwt,
    required this.ewbno,
    required this.voLL,
    required this.voLB,
    required this.voLH,
    required this.eWayBillExpiredDate,
    required this.eWayBillInvoiceDate,

  });

  Map<String, dynamic> toJson() => {
        "invno": invno,
        "prodcd": prodcd,
        "pkgsty": pkgsty,
        "pkgs": pkgs,
        "decval": decval,
        "actuwt": actuwt,
        "ewbno": ewbno,
        "voL_L": voLL,
        "voL_B": voLB,
        "voL_H": voLH,
        "eWayBillExpiredDate": eWayBillExpiredDate,
        "eWayBillInvoiceDate": eWayBillInvoiceDate,
      };
}
