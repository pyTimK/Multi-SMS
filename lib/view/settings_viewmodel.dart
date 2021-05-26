// import 'package:flutter/material.dart';
// import 'package:mass_text_flutter/models/settings.dart';
// import 'package:mass_text_flutter/services/storage_services/storage_service.dart';

// import '../service_locator.dart';

// class SettingsViewModel extends ChangeNotifier {
//   SettingsViewModel() {
//     loadData();
//   }

//   PhoneFormatSettings _phoneFormatSettings = PhoneFormatSettings();
//   PhoneFormatSettings get phoneFormatSettings => _phoneFormatSettings;

//   final StorageService _storageService = locator<StorageService>();

//   Future<void> loadData() async {
//     _phoneFormatSettings = await _storageService.getPhoneFormatSettings();
//     notifyListeners();
//   }

//   //Phone Format Settings
//   Future<void> changePrefix(String newPrefix) async {
//     _phoneFormatSettings.prefix = newPrefix;
//     _storageService.savePrefix(newPrefix);
//   }

//   Future<void> changeTrailingLength(int newLength) async {
//     _phoneFormatSettings.trailingLength = newLength;
//     _storageService.saveTrailingLength(newLength);
//   }
// }
