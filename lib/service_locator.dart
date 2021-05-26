import 'package:get_it/get_it.dart';
import 'package:mass_text_flutter/services/storage_services/storage_service.dart';
import 'services/storage_services/shared_pref.dart';

GetIt locator = GetIt.instance;
dynamic setupServiceLocator() {
  locator.registerLazySingleton<StorageService>(() => StorageServiceSharedPref());
  // locator.registerLazySingleton(() => PushNotification.instance);
}
//* Important
//! BEWARE
//? UNDECIDED
//TODO:
