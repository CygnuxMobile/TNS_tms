import 'dart:convert';

String drsUpdateListRequestToJson(DrsUpdateListRequest data) =>
    json.encode(data.toJson());

class DrsUpdateListRequest {
  final String baseLocationCode;
  // final String DRSNoList;
  final String dateFrom;
  final String dateTo;
  final String baseCompanyCode;
  final String userID;

  DrsUpdateListRequest( {
    required this.baseLocationCode,
    // required this.DRSNoList,
    required this.dateFrom,
    required this.dateTo,
    required this.baseCompanyCode,
    required this.userID,
  });


  Map<String, dynamic> toJson() => {
        "baseLocationCode": baseLocationCode,
        // "DRSNoList":DRSNoList,
        "dateFrom": dateFrom,
        "dateTo": dateTo,
        "baseCompanyCode": baseCompanyCode,
        "userID": userID,
      };
}
