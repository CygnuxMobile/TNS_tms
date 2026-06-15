import 'package:get/get.dart';

class Docket {
  final String misrtDockno;
  final int pkgs;
  final String orgncd;
  final String destcd;
  final int misrtpkg;
  final RxBool isFull;
  final RxBool isCheckBox;
  final List<BoxId> boxIds;

  Docket({
    required this.misrtDockno,
    required this.pkgs,
    required this.orgncd,
    required this.destcd,
    required this.misrtpkg,
    required this.isFull,
    required this.isCheckBox,
    required this.boxIds,
  });
}

class BoxId {
  final String boxNo;
  RxBool isScan = false.obs;

  BoxId({
    required this.boxNo,
    required this.isScan,
  });
}
