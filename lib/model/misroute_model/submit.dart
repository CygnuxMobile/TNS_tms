// To parse this JSON data, do
//
//     final misrouteSubmitRequest = misrouteSubmitRequestFromJson(jsonString);

import 'dart:convert';

MisrouteSubmitRequest misrouteSubmitRequestFromJson(String str) => MisrouteSubmitRequest.fromJson(json.decode(str));

String misrouteSubmitRequestToJson(MisrouteSubmitRequest data) => json.encode(data.toJson());

class MisrouteSubmitRequest {
  final List<Lsmsrt> lsmsrt;
  final String baseLocationCode;
  final String baseUserName;

  MisrouteSubmitRequest({
    required this.lsmsrt,
    required this.baseLocationCode,
    required this.baseUserName,
  });

  MisrouteSubmitRequest copyWith({
    List<Lsmsrt>? lsmsrt,
    String? baseLocationCode,
    String? baseUserName,
  }) =>
      MisrouteSubmitRequest(
        lsmsrt: lsmsrt ?? this.lsmsrt,
        baseLocationCode: baseLocationCode ?? this.baseLocationCode,
        baseUserName: baseUserName ?? this.baseUserName,
      );

  factory MisrouteSubmitRequest.fromJson(Map<String, dynamic> json) => MisrouteSubmitRequest(
    lsmsrt: List<Lsmsrt>.from(json["lsmsrt"].map((x) => Lsmsrt.fromJson(x))),
    baseLocationCode: json["baseLocationCode"],
    baseUserName: json["baseUserName"],
  );

  Map<String, dynamic> toJson() => {
    "lsmsrt": List<dynamic>.from(lsmsrt.map((x) => x.toJson())),
    "baseLocationCode": baseLocationCode,
    "baseUserName": baseUserName,
  };
}

class Lsmsrt {
  final String misrtDockno;
  final int pkgs;
  final String orgncd;
  final String desTCd;
  final int misrtpkg;
  final List<String> boxIds;

  Lsmsrt({
    required this.misrtDockno,
    required this.pkgs,
    required this.orgncd,
    required this.desTCd,
    required this.misrtpkg,
    required this.boxIds,
  });

  Lsmsrt copyWith({
    String? misrtDockno,
    int? pkgs,
    String? orgncd,
    String? desTCd,
    int? misrtpkg,
    List<String>? boxIds,
  }) =>
      Lsmsrt(
        misrtDockno: misrtDockno ?? this.misrtDockno,
        pkgs: pkgs ?? this.pkgs,
        orgncd: orgncd ?? this.orgncd,
        desTCd: desTCd ?? this.desTCd,
        misrtpkg: misrtpkg ?? this.misrtpkg,
        boxIds: boxIds ?? this.boxIds,
      );

  factory Lsmsrt.fromJson(Map<String, dynamic> json) => Lsmsrt(
    misrtDockno: json["misrtDockno"],
    pkgs: json["pkgs"],
    orgncd: json["orgncd"],
    desTCd: json["desT_CD"],
    misrtpkg: json["misrtpkg"],
    boxIds: List<String>.from(json["boxIds"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "misrtDockno": misrtDockno,
    "pkgs": pkgs,
    "orgncd": orgncd,
    "desT_CD": desTCd,
    "misrtpkg": misrtpkg,
    "boxIds": List<dynamic>.from(boxIds.map((x) => x)),
  };
}
