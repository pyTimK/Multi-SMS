import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mass_text_flutter/models/user.dart';
import 'package:mass_text_flutter/services/auth.dart';
import 'package:mass_text_flutter/shared/constants.dart';
import 'package:mass_text_flutter/styles.dart';
import 'package:mass_text_flutter/service_locator.dart';
import 'package:mass_text_flutter/services/push_notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  // PushNotification.instance.initialize().then((_) => runApp(MyApp()));
  await PushNotification.instance.initialize();
  await Firebase.initializeApp();
  MyUser myUser = await AuthService.currentUser;
  InAppPurchaseConnection.enablePendingPurchases();
  runApp(MyApp(myUser: myUser));
  // runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({this.myUser});
  final MyUser myUser;
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        cursorColor: MyColors.violetLighter,
        primarySwatch: Colors.purple,
        textSelectionHandleColor: MyColors.violetLight,
        fontFamily: 'SourceSansPro',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: generateRoute,
      initialRoute: widget.myUser == null ? Constants.IntroRoute : Constants.HomeRoute,
    );
  }
}
