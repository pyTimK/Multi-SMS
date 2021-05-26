import 'package:flutter/material.dart';
import 'package:mass_text_flutter/models/settings.dart';
import 'package:mass_text_flutter/services/contacts_storage.dart';
import 'package:mass_text_flutter/services/storage_services/storage_service.dart';
import 'package:mass_text_flutter/shared/constants.dart';
import 'package:mass_text_flutter/shared/settingsVariable.dart';

import '../service_locator.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel() {
    loadData();
  }

  HomeSettings _homeSettings = HomeSettings();
  MessageSettings _messageSettings = MessageSettings();
  AutoReloadSettings _autoReloadSettings = AutoReloadSettings();
  String _recipient = "";
  List<String> _recipientList = [];
  int _recipientLength = 0;

  HomeSettings get homeSettings => _homeSettings;
  MessageSettings get messageSettings => _messageSettings;
  AutoReloadSettings get autoReloadSettings => _autoReloadSettings;
  String get recipient => _recipient;
  List<String> get recipientList => _recipientList;
  int get recipientLength => _recipientLength;

  final StorageService _storageService = locator<StorageService>();

  Future<void> loadData() async {
    _homeSettings = await _storageService.getHomeSettings();
    _messageSettings = await _storageService.getMessageSettings();
    _autoReloadSettings = await _storageService.getAutoReloadSettings();
    _recipient = await _storageService.getRecipient();
    _recipientList = await ContactsStorage.readFile(_recipient) ?? [];
    _recipientLength = _recipientList.length;
    notifyListeners();
  }

  // HOME SETTINGS                     //

  Future<void> stopSending() async {
    homeSettings.isSending = false;
    notifyListeners();
  }

  Future<void> saveMessage(String data) async {
    _homeSettings.message = data;
    await _storageService.saveData(MyStrings.message, data);
  }

  Future<void> changeIndex(int data) async {
    if (data < 0) data = 0;
    if (data > _recipientLength) data = _recipientLength;
    _homeSettings.index = data;
    print("ChangeIndex: $data");
    if (data == _recipientLength) _homeSettings.isSending = false;
    notifyListeners();
    _storageService.saveData(MyStrings.index, data);
  }

  Future<void> reset() async {
    _homeSettings.isSending = false;
    SettingsVariable.instance.toggleMessageIndex();
    await changeIndex(0);
  }

  Future<void> incrementIndex() async {
    SettingsVariable.instance.toggleMessageIndex();
    await changeIndex(_homeSettings.index + 1);
  }

  Future<void> decrementIndex() async {
    SettingsVariable.instance.toggleMessageIndex();
    await changeIndex(_homeSettings.index - 1);
  }

  // MESSAGE SETTINGS                     //
  Future<void> toggleHasCharLimit() async {
    _messageSettings.hasCharLimit = !_messageSettings.hasCharLimit;
    notifyListeners();
    _storageService.saveData(MyStrings.hasCharLimit, _messageSettings.hasCharLimit);
  }

  Future<void> changeCharLimit(int data) async {
    _messageSettings.charLimit = data;
    notifyListeners();
    _storageService.saveData(MyStrings.charLimit, data);
  }

  Future<void> changeMaxConsecutiveErrors(int data) async {
    _messageSettings.maxConsecutiveErrors = data;
    notifyListeners();
    _storageService.saveData(MyStrings.maxConsecutiveErrors, data);
  }

  // AUTO RELOAD SETTINGS                     //
  Future<void> toggleWillAutoReload() async {
    _autoReloadSettings.willAutoReload = !_autoReloadSettings.willAutoReload;
    notifyListeners();
    _storageService.saveData(MyStrings.willAutoReload, _autoReloadSettings.willAutoReload);
  }

  Future<void> changeAutoReloadIndex(int data) async {
    _autoReloadSettings.reloadCountdown = data;
    notifyListeners();
    _storageService.saveData(MyStrings.reloadCountdown, data);
  }

  Future<void> decrementReloadCountdown() async {
    if (!_autoReloadSettings.willAutoReload) return;
    _autoReloadSettings.reloadCountdown--;
    SettingsVariable.instance.toggleAutoReloadIndex();
    await _storageService.saveData(MyStrings.reloadCountdown, _autoReloadSettings.reloadCountdown);
  }

  Future<void> resetReloadCountdown() async {
    _autoReloadSettings.reloadCountdown = _autoReloadSettings.totalReloadCountdown + 1;
    SettingsVariable.instance.toggleAutoReloadIndex();
    await _storageService.saveData(MyStrings.reloadCountdown, _autoReloadSettings.reloadCountdown);
  }

  Future<void> changeTotalReloadCountdown(int data) async {
    _autoReloadSettings.totalReloadCountdown = data;
    notifyListeners();
    _storageService.saveData(MyStrings.totalReloadCountdown, data);
  }

  Future<void> changeAutoReloadMessage(String newMessage) async {
    _autoReloadSettings.message = newMessage;
    notifyListeners();
    _storageService.saveData(MyStrings.autoReloadmessage, newMessage);
  }

  Future<void> changeSendTo(String newSendTo) async {
    _autoReloadSettings.sendTo = newSendTo;
    notifyListeners();
    _storageService.saveData(MyStrings.sendTo, newSendTo);
  }

  //              ERRORS

  Future<void> setError(String data) async {
    _homeSettings.error = data;
    notifyListeners();
  }

  //              RECIPIENTS

  Future<bool> selectRecipient(String name) async {
    _recipient = name;
    await _storageService.saveData(MyStrings.recipient, name);
    _recipientList = await ContactsStorage.readFile(_recipient) ?? [];
    _recipientLength = _recipientList.length;
    notifyListeners();
    if (_recipientList == null || _recipientLength == 0) return false;
    return true;
  }

  Future<void> renameRecipient(String name) async {
    _recipient = name;
    await _storageService.saveData(MyStrings.recipient, _recipient);
  }

  Future<void> deleteRecipient() async {
    _recipient = "";
    await _storageService.saveData(MyStrings.recipient, _recipient);
    _recipientList = [];
    _recipientLength = 0;
    notifyListeners();
  }
}
