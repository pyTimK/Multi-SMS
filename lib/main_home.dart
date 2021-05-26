import 'dart:async';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mass_text_flutter/actions/add_numbers.dart';
import 'package:mass_text_flutter/actions/merge.dart';
import 'package:mass_text_flutter/models/my_page.dart';
import 'package:mass_text_flutter/pages/main_home/contacts.dart';
import 'package:mass_text_flutter/pages/main_home/home.dart';
import 'package:mass_text_flutter/pages/main_home/settings_page.dart';
import 'package:mass_text_flutter/services/purchase_handler.dart';
import 'package:mass_text_flutter/styles.dart';
import 'package:provider/provider.dart';

import 'actions/reset_index.dart';

class MainHome extends StatefulWidget {
  @override
  _MainHomeState createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  final PageController _pageController = PageController();
  StreamSubscription<List<PurchaseDetails>> _subscription;

  final List<MyPage> _myPages = [];

  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    final _premiumViewModel = Provider.of<PremiumViewModel>(context, listen: false);
    _myPages.add(MyPage(Home(changePage), "Mass Text", [ResetIndexAction()]));
    _myPages.add(MyPage(Contacts(changePage), "Contacts", [MergeAction(), AddNumbersAction(_premiumViewModel)]));
    _myPages.add(MyPage(Settings(), "Settings", []));

    final Stream purchaseUpdates = InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdates.listen((purchases) {
      _premiumViewModel.purchases = PurchaseHandler.verifyPurchases(purchases);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      MyToast.show("Error loading past purchases.");
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _premiumViewModel = Provider.of<PremiumViewModel>(context);
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: [MyColors.blue, MyColors.violet],
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            leadingWidth: 52,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Image.asset("assets/icon/icon_splash${_premiumViewModel.isPremium() ? "_pro" : ""}.png",
                  fit: BoxFit.fitWidth),
            ),
            title: Text(_myPages[_pageIndex].title),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            actions: [..._myPages[_pageIndex].actions, SizedBox(width: 0)],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(6.0),
              child: Divider(
                color: Color(0x888D71B6),
                // indent: 12,
                // endIndent: 12,
                thickness: 2,
                height: 2,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          body: PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            children: _myPages.map((page) => page.screen).toList(),
          ),
          bottomNavigationBar: CurvedNavigationBar(
            index: _pageIndex,
            items: [
              Icon(Icons.message, color: Colors.white, size: 20),
              Icon(Icons.group, color: Colors.white, size: 20),
              Icon(Icons.settings, color: Colors.white, size: 20),
            ],
            color: MyColors.violetDarker,
            backgroundColor: Colors.transparent,
            height: 50,
            animationCurve: Curves.decelerate,
            animationDuration: const Duration(milliseconds: 300),
            onTap: changePage,
          ),
        ),
      ),
    );
  }

  void changePage(int index) {
    _pageController.animateToPage(index, duration: Duration(milliseconds: 200), curve: Curves.linear);
    FocusScope.of(context).unfocus();
    setState(() {
      _pageIndex = index;
    });
  }
}
