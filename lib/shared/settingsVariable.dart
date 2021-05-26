class SettingsVariable {
  SettingsVariable._internal();
  static final SettingsVariable _instance = SettingsVariable._internal();
  static SettingsVariable get instance => _instance;

  bool messageIndex = true;
  void toggleMessageIndex() => messageIndex = !messageIndex;

  bool autoReloadIndex = true;
  void toggleAutoReloadIndex() => autoReloadIndex = !autoReloadIndex;
}
