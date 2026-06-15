import 'dart:convert';

CityResponse cityResponseFromJson(String str) => CityResponse.fromJson(json.decode(str));

String cityResponseToJson(CityResponse data) => json.encode(data.toJson());

class CityResponse {
  final int statusCode;
  final int status;
  final List<City> cityList;
  final dynamic errors;
  final dynamic metaData;
  final String message;

  CityResponse({
    required this.statusCode,
    required this.status,
    required this.cityList,
    required this.errors,
    required this.metaData,
    required this.message,
  });

  factory CityResponse.fromJson(Map<String, dynamic> json) => CityResponse(
    statusCode: json["statusCode"],
    status: json["status"],
    cityList: List<City>.from(json["data"].map((x) => City.fromJson(x))),
    errors: json["errors"],
    metaData: json["metaData"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "status": status,
    "data": List<dynamic>.from(cityList.map((x) => x.toJson())),
    "errors": errors,
    "metaData": metaData,
    "message": message,
  };
}

class City {
  final String location;
  final String cityCode;

  City({
    required this.location,
    required this.cityCode,
  });

  factory City.fromJson(Map<String, dynamic> json) => City(
    location: json["location"],
    cityCode: json["cityCode"]
  );

  Map<String, dynamic> toJson() => {
    "location": location,
  };
}
