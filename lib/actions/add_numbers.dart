import 'package:flutter/material.dart';
import 'package:mass_text_flutter/actions/tab_views/contacts_tab_view.dart';
import 'package:mass_text_flutter/actions/tab_views/input_tab_view.dart';
import 'package:mass_text_flutter/actions/tab_views/txt_tab_view.dart';
import 'package:mass_text_flutter/services/purchase_handler.dart';
import 'package:mass_text_flutter/shared/loading.dart';
import 'package:mass_text_flutter/view/contacts_viewmodel.dart';
import 'package:provider/provider.dart';

import '../styles.dart';

class AddNumbersAction extends StatelessWidget {
  const AddNumbersAction(this.premiumViewModel, {Key key}) : super(key: key);
  final PremiumViewModel premiumViewModel;

  @override
  Widget build(BuildContext context) {
    final ContactsViewModel _contactsViewModel = Provider.of<ContactsViewModel>(context, listen: false);
    return IconButton(
      color: Colors.orange[200],
      icon: const Icon(Icons.add),
      onPressed: () {
        showDialog(
          context: context,
          child: MyInputDialog(_contactsViewModel, premiumViewModel.isPremium()),
        );
      },
    );
  }
}

class MyInputDialog extends StatefulWidget {
  MyInputDialog(this.contactsViewModel, this.isPremium);
  final ContactsViewModel contactsViewModel;
  final bool isPremium;
  @override
  _MyInputDialogState createState() => _MyInputDialogState();
}

class _MyInputDialogState extends State<MyInputDialog> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  Future<bool> _onWillPop() async {
    bool willPop = false;
    await showDialog(
      context: context,
      child: AlertDialog(
        backgroundColor: MyColors.violet,
        title: Text("Cancel import?", style: TextStyles.medium.size(22)),
        actions: [
          MyTextButton(text: "No", onPressed: () => Navigator.pop(context)),
          MyTextButton(
              text: "Yes",
              onPressed: () {
                willPop = true;
                Navigator.pop(context);
              }),
        ],
      ),
    );
    return willPop;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: AlertDialog(
        backgroundColor: MyColors.violet,
        insetPadding: EdgeInsets.all(10),
        titlePadding: EdgeInsets.all(0),

        title: Container(
            alignment: Alignment.center,
            width: double.infinity,
            padding: EdgeInsets.only(top: 12, bottom: 0),
            color: MyColors.violetDark,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("+", style: TextStyles.medium.size(22)),
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(
                      text: "Txt File",
                    ),
                    Tab(text: "Input"),
                    Tab(text: "Contacts"),
                  ],
                ),
              ],
            )),
        contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        content: Builder(
          builder: (context) {
            return Container(
              height: 240,
              width: 180,
              child: TabBarView(
                controller: _tabController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  TxtTabView(widget.contactsViewModel, _addNumbers),
                  InputTabView(widget.contactsViewModel),
                  // Text("3"),
                  ContactsTabView(widget.contactsViewModel),
                ],
              ),
            );
          },
        ),
        // content: Text("This will set index to zero.", style: TextStyles.medium.size(14)),
      ),
    );
  }

  Future<void> _addNumbers(ContactsViewModel contactsViewModel, BuildContext context, bool lineSeparated) async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Loading(),
    ));
    await contactsViewModel.addNumbersFromTxtFile(lineSeparated, widget.isPremium);
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }
}
