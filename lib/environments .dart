enum Environments { tns }

abstract class AppEnvironments {
  static late String baseurl;
  static late String title;
  static late String version;
  static late Environments environments;

  static Environments get _environments => environments;

  ///this method is change flavor
  static setupEvm(Environments evm) {
    environments = evm;
    switch (evm) {
      case Environments.tns:
        title = "Tns";
        baseurl = "https://tnsapi.cygnux.in/";///Live
        // baseurl = "https://tnsuatapi.cygnux.in/";
        version = '1.0.1';
        break;
    }
  }
}
