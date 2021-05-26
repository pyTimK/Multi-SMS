import 'package:flutter/material.dart';
import 'package:mass_text_flutter/services/purchase_handler.dart';
import 'package:mass_text_flutter/view/contacts_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../styles.dart';

class TxtTabView extends StatefulWidget {
  TxtTabView(this._contactsViewModel, this.addNumbers);
  final ContactsViewModel _contactsViewModel;
  final Future<void> Function(ContactsViewModel, BuildContext, bool) addNumbers;

  @override
  _TxtTabViewState createState() => _TxtTabViewState();
}

class _TxtTabViewState extends State<TxtTabView> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(mainAxisSize: MainAxisSize.min, children: [
          Card(
            elevation: 0,
            child: Container(
              alignment: Alignment.bottomCenter,
              width: 110,
              height: 100,
              decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage("assets/PhoneNumbersLineSeparated.png"), fit: BoxFit.fill),
                  borderRadius: BorderRadius.circular(4)),
              child: Container(
                alignment: Alignment.bottomCenter,
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [MyColors.violet, Colors.transparent])),
                child: Text("Line Separated", style: TextStyles.small, textAlign: TextAlign.center),
              ),
            ),
          ),
          MyTextButton(
              text: "Import",
              onPressed: () {
                widget.addNumbers(widget._contactsViewModel, context, true);
              }),
        ]),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              elevation: 0,
              child: Container(
                alignment: Alignment.bottomCenter,
                width: 110,
                height: 100,
                decoration: BoxDecoration(
                    image:
                        DecorationImage(image: AssetImage("assets/PhoneNumbersCommaSeparated.png"), fit: BoxFit.fill),
                    borderRadius: BorderRadius.circular(4)),
                child: Container(
                  alignment: Alignment.bottomCenter,
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [MyColors.violet, Colors.transparent])),
                  child: Text("Comma Separated", style: TextStyles.small, textAlign: TextAlign.center),
                ),
              ),
            ),
            MyTextButton(
                text: "Import",
                onPressed: () {
                  widget.addNumbers(widget._contactsViewModel, context, false);
                }),
          ],
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
