import 'package:flutter/services.dart';
import 'package:flutter_android/android.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_android/android_content.dart' show Intent;

import '../styles.dart';

abstract class MyPermissionHandler {
  static bool _isHandler = false;

  static Future<bool> checkIfHandler() async {
    const platform = const MethodChannel('mySmsHandlerChannel');

    try {
      bool isDefaultHandler = (await platform.invokeMethod('check_if_default_handler')) ?? false;
      if (isDefaultHandler) return true;

      platform.invokeMethod('make_default_handler');
      return false;
    } catch (e) {
      print('ERROR::::');
      print(e.toString());
      MyToast.show("error occured");
    }
  }

  static Future<bool> hasPermission(List<Permission> permissions) async {
    print("HASpERMISSION CALLED");

    bool withPermission = true;
    int noPermissionIndex = 0;

    for (final permission in permissions) {
      bool currentHasPermission = await permission.request().isGranted;
      if (!currentHasPermission) {
        withPermission = false;
        break;
      }
      noPermissionIndex++;
    }
    if (withPermission) {
      return true;
    } else {
      final Permission noPermission = permissions[noPermissionIndex];
      final PermissionStatus permissionStatus = await noPermission.status;
      if (permissionStatus == PermissionStatus.permanentlyDenied) openAppSettings();
      String name = noPermission.toString();
      MyToast.show("${name.substring(11, name.length).toUpperCase()} Permission Needed", isLong: true);
      return false;
    }
  }
}
