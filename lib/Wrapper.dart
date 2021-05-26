import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mass_text_flutter/services/auth.dart';
import 'package:mass_text_flutter/services/purchase_handler.dart';
import 'package:mass_text_flutter/view/contacts_viewmodel.dart';
import 'package:mass_text_flutter/view/home_viewmodel.dart';
import 'package:provider/provider.dart';
import 'main_home.dart';
import 'models/user.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider<HomeViewModel>(create: (_) => HomeViewModel()),
      ChangeNotifierProvider<ContactsViewModel>(create: (_) => ContactsViewModel()),
      StreamProvider<MyUser>.value(value: AuthService().userWithNotifier),
      ChangeNotifierProvider<PremiumViewModel>(create: (_) => PremiumViewModel()),
      // ChangeNotifierProvider<SettingsViewModel>(create: (_) => SettingsViewModel()),
    ], child: MainHome());
  }
}
