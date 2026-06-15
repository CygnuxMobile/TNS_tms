import 'dart:convert';

GetEwayBillState getEwayBillStateFromJson(String str) => GetEwayBillState.fromJson(json.decode(str));

class GetEwayBillState {
  final int statusCode;
  final int status;
  final List<GetEwayBillStateDatum> data;
  final dynamic errors;
  final dynamic metaData;
  final String message;

  GetEwayBillState({
    required this.statusCode,
    required this.status,
    required this.data,
    required this.errors,
    required this.metaData,
    required this.message,
  });

  factory GetEwayBillState.fromJson(Map<String, dynamic> json) => GetEwayBillState(
    statusCode: json["statusCode"],
    status: json["status"],
    data: List<GetEwayBillStateDatum>.from(json["data"].map((x) => GetEwayBillStateDatum.fromJson(x))),
    errors: json["errors"],
    metaData: json["metaData"],
    message: json["message"],
  );
}

class GetEwayBillStateDatum {
  final String stcd;
  final String stnm;
  final int frtRate;
  final String rateType;
  final String entryby;
  final String entrydt;
  final String lasteditby;
  final String lasteditdate;
  final String activeflag;
  final String staxExmptYn;
  final int srno;
  final String gstRegNo;
  final bool isUnionTerritory;
  final String gstStateCode;
  final String statePrefix;
  final String zone;
  final dynamic category;
  final dynamic stateCode;
  final bool activeflag2;
  final bool staxExmptYn2;
  final dynamic zonename;

  GetEwayBillStateDatum({
    required this.stcd,
    required this.stnm,
    required this.frtRate,
    required this.rateType,
    required this.entryby,
    required this.entrydt,
    required this.lasteditby,
    required this.lasteditdate,
    required this.activeflag,
    required this.staxExmptYn,
    required this.srno,
    required this.gstRegNo,
    required this.isUnionTerritory,
    required this.gstStateCode,
    required this.statePrefix,
    required this.zone,
    required this.category,
    required this.stateCode,
    required this.activeflag2,
    required this.staxExmptYn2,
    required this.zonename,
  });

  factory GetEwayBillStateDatum.fromJson(Map<String, dynamic> json) {
    return GetEwayBillStateDatum(
      stcd: json["stcd"]?.toString() ?? "",
      stnm: json["stnm"]?.toString() ?? "",
      frtRate: json["frt_rate"] is int
          ? json["frt_rate"]
          : int.tryParse(json["frt_rate"]?.toString() ?? "0") ?? 0,
      rateType: json["rate_type"]?.toString() ?? "",
      entryby: json["entryby"]?.toString() ?? "",
      entrydt: json["entrydt"]?.toString() ?? "",
      lasteditby: json["lasteditby"]?.toString() ?? "",
      lasteditdate: json["lasteditdate"]?.toString() ?? "",
      activeflag: json["activeflag"]?.toString() ?? "",
      staxExmptYn: json["stax_exmpt_yn"]?.toString() ?? "",
      srno: json["srno"] is int
          ? json["srno"]
          : int.tryParse(json["srno"]?.toString() ?? "0") ?? 0,
      gstRegNo: json["gstRegNo"]?.toString() ?? "",
      isUnionTerritory: json["isUnionTerritory"] ?? false,
      gstStateCode: json["gstStateCode"]?.toString() ?? "",
      statePrefix: json["statePrefix"]?.toString() ?? "",
      zone: json["zone"]?.toString() ?? "",
      category: json["category"],
      stateCode: json["stateCode"],
      activeflag2: json["activeflag2"] ?? false,
      staxExmptYn2: json["stax_exmpt_yn2"] ?? false,
      zonename: json["zonename"],
    );
  }
}


