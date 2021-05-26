class HomeSettings {
  HomeSettings({this.index = 0, this.message = ""}) {
    this.isSending = false;
    this.error = 'No Error';
    this.consecutiveErrors = 0;
  }

  int index;
  String message;
  bool isSending;
  String error;
  int consecutiveErrors;
}

class MessageSettings {
  MessageSettings({this.charLimit = 150, this.hasCharLimit = true, this.maxConsecutiveErrors = 5});
  bool hasCharLimit;
  int charLimit;
  int maxConsecutiveErrors;
}

class PhoneFormatSettings {
  PhoneFormatSettings({this.prefix = "63", this.trailingLength = 10});
  String prefix;
  int trailingLength;
}

class AutoReloadSettings {
  AutoReloadSettings(
      {this.willAutoReload = true,
      this.totalReloadCountdown = 850,
      this.reloadCountdown = 850,
      this.message = "GOCOMBOAHBFA14",
      this.sendTo = "8080"});
  bool willAutoReload;
  int reloadCountdown;
  int totalReloadCountdown;
  String message;
  String sendTo;
}
