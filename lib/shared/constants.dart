abstract class Constants {
  static final allowedPhoneNumbersLength = {
    6: "XXX XXX",
    7: "XXX XXXX",
    8: "XXXX XXXX",
    9: "XX XXX XXXX",
    10: "XXX XXX XXXX"
  };

  static const String IntroRoute = "intro";
  static const String HomeRoute = "/";
  static const String LoginRoute = "login";
  static const String LoadingRoute = "loading";
}

abstract class MyStrings {
  static const String prefix = 'prefix';
  static const String trailingLength = 'trailingLength';
  static const String index = 'index';
  static const String message = 'message';
  static const String recipient = 'recipient';
  static const String hasCharLimit = 'hasCharLimit';
  static const String charLimit = 'charLimit';
  static const String willAutoReload = 'willAutoReload';
  static const String reloadCountdown = 'reloadCountdown';
  static const String totalReloadCountdown = 'totalReloadCountdown';
  static const String autoReloadmessage = 'autoReloadmessage';
  static const String sendTo = 'sendTo';
  static const String maxConsecutiveErrors = 'maxConsecutiveErrors';
}
