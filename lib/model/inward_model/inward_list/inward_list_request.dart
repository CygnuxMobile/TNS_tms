import 'dart:convert';

InWardRequest inWardRequestFromJson(String str) => InWardRequest.fromJson(json.decode(str));

String inWardRequestToJson(InWardRequest data) => json.encode(data.toJson());

class InWardRequest {
  final String thcNo;
  final String fromDate;
  final String toDate;
  final String transportMode;
  final String baseComapnyCode;
  final String baseLocationCode;

  InWardRequest({
    required this.thcNo,
    required this.fromDate,
    required this.toDate,
    required this.transportMode,
    required this.baseComapnyCode,
    required this.baseLocationCode,
  });

  InWardRequest copyWith({
    String? thcNo,
    String? fromDate,
    String? toDate,
    String? transportMode,
    String? baseComapnyCode,
    String? baseLocationCode,
  }) =>
      InWardRequest(
        thcNo: thcNo ?? this.thcNo,
        fromDate: fromDate ?? this.fromDate,
        toDate: toDate ?? this.toDate,
        transportMode: transportMode ?? this.transportMode,
        baseComapnyCode: baseComapnyCode ?? this.baseComapnyCode,
        baseLocationCode: baseLocationCode ?? this.baseLocationCode,
      );

  factory InWardRequest.fromJson(Map<String, dynamic> json) => InWardRequest(
    thcNo: json["thcNo"],
    fromDate: json["fromDate"],
    toDate: json["toDate"],
    transportMode: json["transportMode"],
    baseComapnyCode: json["baseComapnyCode"],
    baseLocationCode: json["baseLocationCode"],
  );

  Map<String, dynamic> toJson() => {
    "thcNo": thcNo,
    "fromDate": fromDate,
    "toDate": toDate,
    "transportMode": transportMode,
    "baseComapnyCode": baseComapnyCode,
    "baseLocationCode": baseLocationCode,
  };
}
