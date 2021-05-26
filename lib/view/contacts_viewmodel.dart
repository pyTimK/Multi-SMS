import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mass_text_flutter/models/numbers_collection.dart';
import 'package:mass_text_flutter/models/settings.dart';
import 'package:mass_text_flutter/services/contacts_storage.dart';
import 'package:mass_text_flutter/services/my_permission_handler.dart';
import 'package:mass_text_flutter/services/phone_numbers.dart';
import 'package:mass_text_flutter/services/storage_services/storage_service.dart';
import 'package:mass_text_flutter/shared/constants.dart';
import 'package:permission_handler/permission_handler.dart';

import '../service_locator.dart';
import '../styles.dart';

class ContactsViewModel extends ChangeNotifier {
  ContactsViewModel() {
    loadData();
  }

  PhoneFormatSettings _phoneFormatSettings = PhoneFormatSettings();
  List<NumbersCollection> _numbersCollections = [];
  PhoneFormatSettings get phoneFormatSettings => _phoneFormatSettings;
  List<NumbersCollection> get numbersCollection => _numbersCollections;

  final StorageService _storageService = locator<StorageService>();

  Future<void> loadData() async {
    _numbersCollections = await ContactsStorage.readMain();
    _phoneFormatSettings = await _storageService.getPhoneFormatSettings();
    notifyListeners();
  }

  //Phone Format Settings
  Future<void> changePrefix(String newPrefix) async {
    _phoneFormatSettings.prefix = newPrefix;
    notifyListeners();
    _storageService.saveData(MyStrings.prefix, newPrefix);
  }

  Future<void> changeTrailingLength(int newLength) async {
    _phoneFormatSettings.trailingLength = newLength;
    notifyListeners();
    _storageService.saveData(MyStrings.trailingLength, newLength);
  }

  //Numbers Collection

  Future<bool> addNumbersFromTxtFile(bool lineSeparated, bool isPremium) async {
    if (!await MyPermissionHandler.hasPermission([Permission.storage])) return false;

    final bool success = await ContactsManager.addNewNumbers(_phoneFormatSettings, lineSeparated, isPremium);

    if (success) loadData();

    return success;
  }

  Future<bool> addNumbersFromContacts(String name, List<String> numbers) async {
    final filterInput = FilterInput(numbers, phoneFormatSettings);
    numbers = await PhoneNumbers.filter(filterInput);
    final bool success = await ContactsStorage.addFile("$name.txt", numbers);

    MyToast.show(success ? "Phone Numbers Added :)" : "Problem Adding Phone Numbers :(");
    if (success) loadData();
    return success;
  }

  Future<bool> addNumbersFromList(String name, List<String> numbers) async {
    final bool success = await ContactsStorage.addFile("$name.txt", numbers);

    MyToast.show(success ? "Phone Numbers Added :)" : "Problem Adding Phone Numbers :(");
    if (success) loadData();
    return success;
  }

  Future<bool> addNumbersFromMerge(String name, List<NumbersCollection> numbers) async {
    final bool success = await ContactsStorage.mergeFiles(name, numbers);

    MyToast.show(success ? "Phone Numbers Merged" : "Problem Merging Phone Numbers :(");
    if (success) loadData();
    return success;
  }

  void reorderList(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    print("old: $oldIndex, new: $newIndex");
    _numbersCollections.insert(newIndex, _numbersCollections.removeAt(oldIndex));
    notifyListeners();
    ContactsStorage.rewriteMain(_numbersCollections);
  }

  void refresh() {
    notifyListeners();
  }

  void deleteItem(int index) {
    print("to be deleted: $index");
    NumbersCollection removed = _numbersCollections.removeAt(index);
    notifyListeners();
    ContactsStorage.deleteFile(removed.name);
    ContactsStorage.rewriteMain(_numbersCollections);
  }

  Future<bool> renameItem(int index, String newName, BuildContext context) async {
    bool _existingName = false;

    for (final nc in _numbersCollections) {
      if (nc.name == newName) {
        _existingName = true;
        break;
      }
    }

    if (_existingName) {
      MyToast.show("Name already exists");
      return false;
    }

    final String oldName = _numbersCollections[index].name;
    print("to be renamed: $index from $oldName to $newName");
    _numbersCollections[index].name = newName;
    notifyListeners();
    bool success = await ContactsStorage.renameFile(oldName, newName);
    if (success)
      ContactsStorage.rewriteMain(_numbersCollections);
    else {
      MyToast.show("Renaming Error");
    }
    return success;
  }
}
