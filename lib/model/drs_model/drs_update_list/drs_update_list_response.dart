import 'dart:convert';

DrsUpdateListResponse drsUpdateListResponseFromJson(String str) => DrsUpdateListResponse.fromJson(json.decode(str));

String drsUpdateListResponseToJson(DrsUpdateListResponse data) => json.encode(data.toJson());

class DrsUpdateListResponse {
  final int statusCode;
  final int status;
  final List<DrsList> drsList;
  final dynamic errors;
  final dynamic metaData;
  final String message;

  DrsUpdateListResponse({
    required this.statusCode,
    required this.status,
    required this.drsList,
    required this.errors,
    required this.metaData,
    required this.message,
  });

  DrsUpdateListResponse copyWith({
    int? statusCode,
    int? status,
    List<DrsList>? DrsList,
    dynamic errors,
    dynamic metaData,
    String? message,
  }) =>
      DrsUpdateListResponse(
        statusCode: statusCode ?? this.statusCode,
        status: status ?? this.status,
        drsList: DrsList ?? this.drsList,
        errors: errors ?? this.errors,
        metaData: metaData ?? this.metaData,
        message: message ?? this.message,
      );

  factory DrsUpdateListResponse.fromJson(Map<String, dynamic> json) => DrsUpdateListResponse(
    statusCode: json["statusCode"],
    status: json["status"],
    drsList: List<DrsList>.from(json["data"].map((x) => DrsList.fromJson(x))),
    errors: json["errors"],
    metaData: json["metaData"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "status": status,
    "data": List<dynamic>.from(drsList.map((x) => x.toJson())),
    "errors": errors,
    "metaData": metaData,
    "message": message,
  };
}

class DrsList {
  final num autoNo;
  final num rate;
  final num maxLimit;
  final num newRate;
  final String content;
  final String dockno;
  final String docksf;
  final String bookingDate;
  final String orgncd;
  final String destcd;
  final String payBasis;
  final String csgncd;
  final String csgnnm;
  final String csgecd;
  final String csgenm;
  final num pkgsArrived;
  final num pkgsBooked;
  final num pkgsPending;
  final num bookedWt;
  final num wtArrived;
  final String commDelyDt;
  final num freight;
  final double docketTotal;
  final num serviceTax;
  final num pkgQty;
  final num actQty;
  final String delyLocation;
  final String currLoc;
  final String payBasCode;
  final String dockDt;
  final String coDDod;
  final num coddodAmount;
  final String cdeldTDdmmyyyy;
  final String dockDtDdmmyyyy;
  final String dlypdcno;
  final bool coddod;
  final dynamic pkgsdelivered;
  final dynamic remark;
  final dynamic otp;
  final String delydate;
  final String delytime;
  final dynamic delyperson;
  final dynamic cboReason;
  final num coddodcollected;
  final num coddodno;
  final dynamic cboLateReason;
  final dynamic hDcboReason;
  final bool isChecked;
  final dynamic ratetype;
  final bool isEnabled;
  final bool isEnabledBadPodoption;

  DrsList({
    required this.autoNo,
    required this.rate,
    required this.maxLimit,
    required this.newRate,
    required this.content,
    required this.dockno,
    required this.docksf,
    required this.bookingDate,
    required this.orgncd,
    required this.destcd,
    required this.payBasis,
    required this.csgncd,
    required this.csgnnm,
    required this.csgecd,
    required this.csgenm,
    required this.pkgsArrived,
    required this.pkgsBooked,
    required this.pkgsPending,
    required this.bookedWt,
    required this.wtArrived,
    required this.commDelyDt,
    required this.freight,
    required this.docketTotal,
    required this.serviceTax,
    required this.pkgQty,
    required this.actQty,
    required this.delyLocation,
    required this.currLoc,
    required this.payBasCode,
    required this.dockDt,
    required this.coDDod,
    required this.coddodAmount,
    required this.cdeldTDdmmyyyy,
    required this.dockDtDdmmyyyy,
    required this.dlypdcno,
    required this.coddod,
    this.pkgsdelivered,
    this.remark,
    this.otp,
    required this.delydate,
    required this.delytime,
    this.delyperson,
    this.cboReason,
    required this.coddodcollected,
    required this.coddodno,
    this.cboLateReason,
    this.hDcboReason,
    required this.isChecked,
    this.ratetype,
    required this.isEnabled,
    required this.isEnabledBadPodoption,
  });

  factory DrsList.fromJson(Map<String, dynamic> json) => DrsList(
    autoNo: json["autoNo"] ?? 0,
    rate: json["rate"] ?? 0,
    maxLimit: json["maxLimit"] ?? 0,
    newRate: json["newRate"] ?? 0,
    content: json["content"] ?? '',
    dockno: json["dockno"] ?? '',
    docksf: json["docksf"] ?? '',
    bookingDate: json["booking_Date"] ?? '',
    orgncd: json["orgncd"] ?? '',
    destcd: json["destcd"] ?? '',
    payBasis: json["payBasis"] ?? '',
    csgncd: json["csgncd"] ?? '',
    csgnnm: json["csgnnm"] ?? '',
    csgecd: json["csgecd"] ?? '',
    csgenm: json["csgenm"] ?? '',
    pkgsArrived: json["pkgs_Arrived"] ?? 0,
    pkgsBooked: json["pkgs_Booked"] ?? 0,
    pkgsPending: json["pkgs_Pending"] ?? 0,
    bookedWt: json["booked_Wt"] ?? 0,
    wtArrived: json["wt_Arrived"] ?? 0,
    commDelyDt: json["comm_Dely_Dt"] ?? '',
    freight: json["freight"] ?? 0,
    docketTotal: (json["docket_Total"] ?? 0).toDouble(),
    serviceTax: json["service_Tax"] ?? 0,
    pkgQty: json["pkgQty"] ?? 0,
    actQty: json["actQty"] ?? 0,
    delyLocation: json["delyLocation"] ?? '',
    currLoc: json["curr_loc"] ?? '',
    payBasCode: json["payBasCode"] ?? '',
    dockDt: json["dockDt"] ?? '',
    coDDod: json["coD_DOD"] ?? '',
    coddodAmount: json["coddodAmount"] ?? 0,
    cdeldTDdmmyyyy: json["cdeldT_ddmmyyyy"] ?? '',
    dockDtDdmmyyyy: json["dockDt_ddmmyyyy"] ?? '',
    dlypdcno: json["dlypdcno"] ?? '',
    coddod: json["coddod"] ?? false,
    pkgsdelivered: json["pkgsdelivered"],
    remark: json["remark"],
    otp: json["otp"],
    delydate: json["delydate"] ?? '',
    delytime: json["delytime"] ?? '',
    delyperson: json["delyperson"],
    cboReason: json["cboReason"],
    coddodcollected: json["coddodcollected"] ?? 0,
    coddodno: json["coddodno"] ?? 0,
    cboLateReason: json["cboLateReason"],
    hDcboReason: json["hDcboReason"],
    isChecked: json["isChecked"] ?? false,
    ratetype: json["ratetype"],
    isEnabled: json["isEnabled"] ?? false,
    isEnabledBadPodoption: json["isEnabledBadPodoption"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "autoNo": autoNo,
    "rate": rate,
    "maxLimit": maxLimit,
    "newRate": newRate,
    "dockno": dockno,
    "docksf": docksf,
    "booking_Date": bookingDate,
    "orgncd": orgncd,
    "destcd": destcd,
    "payBasis": payBasis,
    "csgncd": csgncd,
    "csgnnm": csgnnm,
    "csgecd": csgecd,
    "csgenm": csgenm,
    "pkgs_Arrived": pkgsArrived,
    "pkgs_Booked": pkgsBooked,
    "pkgs_Pending": pkgsPending,
    "booked_Wt": bookedWt,
    "wt_Arrived": wtArrived,
    "comm_Dely_Dt": commDelyDt,
    "freight": freight,
    "docket_Total": docketTotal,
    "service_Tax": serviceTax,
    "pkgQty": pkgQty,
    "actQty": actQty,
    "delyLocation": delyLocation,
    "curr_loc": currLoc,
    "payBasCode": payBasCode,
    "dockDt": dockDt,
    "coD_DOD": coDDod,
    "coddodAmount": coddodAmount,
    "cdeldT_ddmmyyyy": cdeldTDdmmyyyy,
    "dockDt_ddmmyyyy": dockDtDdmmyyyy,
    "dlypdcno": dlypdcno,
    "coddod": coddod,
    "pkgsdelivered": pkgsdelivered,
    "remark": remark,
    "otp": otp,
    "delydate": delydate,
    "delytime": delytime,
    "delyperson": delyperson,
    "cboReason": cboReason,
    "coddodcollected": coddodcollected,
    "coddodno": coddodno,
    "cboLateReason": cboLateReason,
    "hDcboReason": hDcboReason,
    "isChecked": isChecked,
    "ratetype": ratetype,
    "isEnabled": isEnabled,
    "isEnabledBadPodoption": isEnabledBadPodoption,
  };
}

