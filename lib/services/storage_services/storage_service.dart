import 'package:mass_text_flutter/models/settings.dart';

abstract class StorageService {
  Future<String> getRecipient();
  //SETTINGS
  Future<void> saveHomeSettings(HomeSettings settings);
  Future<void> saveMessageSettings(MessageSettings settings);
  Future<void> saveAutoReloadSettings(AutoReloadSettings settings);
  Future<void> savePhoneFormatSettings(PhoneFormatSettings settings);
  Future<HomeSettings> getHomeSettings();
  Future<MessageSettings> getMessageSettings();
  Future<AutoReloadSettings> getAutoReloadSettings();
  Future<PhoneFormatSettings> getPhoneFormatSettings();

  // Future<void> saveReloadCountdown(int reloadCountdown);
  // Future<void> saveRecipient(String recipient);
  // Future<void> saveMessage(String message);
  // Future<void> saveIndex(int index);
  // Future<void> saveHasCharLimit(bool hasCharLimit);
  // Future<void> saveCharLimit(int limit);
  // Future<void> saveMaxConsecutiveErrors(int maxConsecutiveErrors);
  // Future<void> saveWillAutoReload(bool willAutoReload);
  // Future<void> saveTotalReloadCountdown(int total);
  // Future<void> saveAutoReloadMessage(String newMessage);
  // Future<void> saveSendTo(String newSendTo);

  // Future<void> savePrefix(String prefix);
  // Future<void> saveTrailingLength(int length);

  Future<void> saveData(String name, dynamic data);
}
