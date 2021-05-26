import 'package:mass_text_flutter/models/settings.dart';
import 'package:mass_text_flutter/shared/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'storage_service.dart';

class StorageServiceSharedPref extends StorageService {
  // @override
  // Future<void> saveIndex(int index) => _save(_index, index);

  // @override
  // Future<void> saveMessage(String message) => _save(_message, message);

  // @override
  // Future<void> saveReloadCountdown(int reloadCountdown) => _save(_reloadCountdown, reloadCountdown);

  // @override
  // Future<void> saveHasCharLimit(bool hasCharLimit) => _save(_hasCharLimit, hasCharLimit);

  // @override
  // Future<void> saveCharLimit(int limit) => _save(_charLimit, limit);

  // @override
  // Future<void> saveWillAutoReload(bool willAutoReload) => _save(_willAutoReload, willAutoReload);

  // @override
  // Future<void> saveAutoReloadMessage(String newMessage) => _save(_autoReladmessage, newMessage);

  // @override
  // Future<void> saveSendTo(String newSendTo) => _save(_sendTo, newSendTo);

  // @override
  // Future<void> saveTotalReloadCountdown(int total) => _save(_totalReloadCountdown, total);

  // @override
  // Future<void> saveRecipient(String recipient) => _save(_recipient, recipient);

  // @override
  // Future<void> saveMaxConsecutiveErrors(int maxConsecutiveErrors) => _save(_maxConsecutiveErrors, maxConsecutiveErrors);

  @override
  Future<String> getRecipient() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String recipient = prefs.getString(MyStrings.recipient);
    return recipient;
  }

  @override
  Future<void> saveHomeSettings(HomeSettings settings) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(MyStrings.message, settings.message);
    await prefs.setInt(MyStrings.index, settings.index);
  }

  @override
  Future<void> saveMessageSettings(MessageSettings settings) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(MyStrings.hasCharLimit, settings.hasCharLimit);
    await prefs.setInt(MyStrings.charLimit, settings.charLimit);
    await prefs.setInt(MyStrings.maxConsecutiveErrors, settings.maxConsecutiveErrors);
  }

  @override
  Future<void> savePhoneFormatSettings(PhoneFormatSettings settings) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(MyStrings.prefix, settings.prefix);
    await prefs.setInt(MyStrings.trailingLength, settings.trailingLength);
  }

  @override
  Future<void> saveAutoReloadSettings(AutoReloadSettings settings) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(MyStrings.willAutoReload, settings.willAutoReload);
    await prefs.setInt(MyStrings.reloadCountdown, settings.reloadCountdown);
    await prefs.setInt(MyStrings.totalReloadCountdown, settings.totalReloadCountdown);
    await prefs.setString(MyStrings.autoReloadmessage, settings.message);
    await prefs.setString(MyStrings.sendTo, settings.sendTo);
  }

  @override
  Future<HomeSettings> getHomeSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return HomeSettings(
      index: prefs.getInt(MyStrings.index) ?? 0,
      message: prefs.getString(MyStrings.message) ?? "",
    );
  }

  @override
  Future<MessageSettings> getMessageSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return MessageSettings(
      hasCharLimit: prefs.getBool(MyStrings.hasCharLimit) ?? true,
      charLimit: prefs.getInt(MyStrings.charLimit) ?? 150,
      maxConsecutiveErrors: prefs.getInt(MyStrings.maxConsecutiveErrors) ?? 5,
    );
  }

  @override
  Future<PhoneFormatSettings> getPhoneFormatSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return PhoneFormatSettings(
      prefix: prefs.getString(MyStrings.prefix) ?? "63",
      trailingLength: prefs.getInt(MyStrings.trailingLength) ?? 10,
    );
  }

  @override
  Future<AutoReloadSettings> getAutoReloadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return AutoReloadSettings(
      willAutoReload: prefs.getBool(MyStrings.willAutoReload) ?? true,
      reloadCountdown: prefs.getInt(MyStrings.reloadCountdown) ?? 850,
      totalReloadCountdown: prefs.getInt(MyStrings.totalReloadCountdown) ?? 850,
      message: prefs.getString(MyStrings.autoReloadmessage) ?? "GOCOMBOAHBFA14",
      sendTo: prefs.getString(MyStrings.sendTo) ?? "8080",
    );
  }

  @override
  Future<void> saveData(String name, dynamic data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (data is bool)
      await prefs.setBool(name, data);
    else if (data is double)
      await prefs.setDouble(name, data);
    else if (data is int)
      await prefs.setInt(name, data);
    else if (data is String)
      await prefs.setString(name, data);
    else if (data is List<String>) await prefs.setStringList(name, data);
  }
}
