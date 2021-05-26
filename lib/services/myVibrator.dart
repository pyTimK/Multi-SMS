import 'package:flutter_vibrate/flutter_vibrate.dart';

class MyVibrator {
  static Future<void> vibrate() async {
    try {
      if (await Vibrate.canVibrate) await Vibrate.vibrate();
    } catch (e) {
      print(e.toString());
    }
  }
}
