import 'dart:convert';

Vehicle vehicleFromJson(String str) => Vehicle.fromJson(json.decode(str));

String vehicleToJson(Vehicle data) => json.encode(data.toJson());

class Vehicle {
  final int statusCode;
  final int status;
  final List<VehicleDatum> data;
  final dynamic errors;
  final dynamic metaData;
  final String message;

  Vehicle({
    required this.statusCode,
    required this.status,
    required this.data,
    required this.errors,
    required this.metaData,
    required this.message,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    statusCode: json["statusCode"],
    status: json["status"],
    data: List<VehicleDatum>.from(json["data"].map((x) => VehicleDatum.fromJson(x))),
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

class VehicleDatum {
  final String vehno;
  final String vendorcode;
  final String vendortype;
  final String vehregno;
  final String vehchasisno;
  final String conrtlBranch;
  final String tyreSize;

  VehicleDatum({
    required this.vehno,
    required this.vendorcode,
    required this.vendortype,
    required this.vehregno,
    required this.vehchasisno,
    required this.conrtlBranch,
    required this.tyreSize,
  });

  factory VehicleDatum.fromJson(Map<String, dynamic> json) => VehicleDatum(
    vehno: json["vehno"] ?? '',
    vendorcode: json["vendorcode"] ?? '',
    vendortype: json["vendortype"] ?? '',
    vehregno: json["vehregno"] ?? '',
    vehchasisno: json["vehchasisno"] ?? '',
    conrtlBranch: json["conrtl_branch"] ?? '',
    tyreSize: json["tyreSize"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "vehno": vehno,
    "vendorcode": vendorcode,
    "vendortype": vendortype,
    "vehregno": vehregno,
    "vehchasisno": vehchasisno,
    "conrtl_branch": conrtlBranch,
    "tyreSize": tyreSize,
  };
}
