import 'dart:ui';
import 'package:fluttertoast/fluttertoast.dart';


class TmsToast {


  static void msg(String msg) {

    Fluttertoast.showToast(msg: msg,backgroundColor: Color(0xff232F34));
  }
}

