import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mass_text_flutter/models/numbers_collection.dart';
import 'package:mass_text_flutter/services/purchase_handler.dart';
import 'package:mass_text_flutter/view/contacts_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:smart_select/smart_select.dart';

import '../styles.dart';

class MergeAction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _premiumViewModel = Provider.of<PremiumViewModel>(context, listen: false);
    return IconButton(
      color: Colors.orange[200],
      icon: const Icon(Icons.merge_type),
      onPressed: () {
        if (!_premiumViewModel.isPremium()) {
          MyToast.show("This feature is only available for Gold Users", isLong: true);
          return;
        }

        final ContactsViewModel _contactsViewModel = Provider.of<ContactsViewModel>(context, listen: false);
        print("S2 MODALZER Reloaded");
        List<NumbersCollection> value = [];
        List<S2Choice<NumbersCollection>> frameworks = _contactsViewModel.numbersCollection
            .map((numbers) => S2Choice<NumbersCollection>(value: numbers, title: numbers.name))
            .toList();
        bool isValid = false;
        showDialog(
          context: context,
          child: AlertDialog(
            // content:
            //     Text("Automatically removes duplicates", style: TextStyles.medium.size(14).weight(FontWeight.w300)),
            backgroundColor: MyColors.violet,
            title: Text("Merge Contacts", style: TextStyles.medium.size(22)),
            // actions: [
            //   MyTextButton(text: "Cancel", onPressed: () => Navigator.pop(context)),
            // ],
            contentPadding: EdgeInsets.fromLTRB(0, 24, 0, 0),
            content: SmartSelect<NumbersCollection>.multiple(
              key: UniqueKey(),
              title: 'Frameworks',
              value: value,
              choiceItems: frameworks,
              tileBuilder: (context, value) => SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 230,
                      height: 150,
                      decoration: BoxDecoration(border: Border.all(color: MyColors.violetLight)),
                      child: Wrap(
                          children: value.value
                              .map((numbersCollection) => Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                    child: Chip(
                                      visualDensity: VisualDensity(vertical: -4),
                                      padding: const EdgeInsets.all(3.0),
                                      label:
                                          Text(numbersCollection.name, style: TextStyles.small.weight(FontWeight.w300)),
                                      backgroundColor: MyColors.violetDark,
                                    ),
                                  ))
                              .toList()
                          // ..add(Chip(
                          //   label: Text("+"),
                          // )),
                          ),
                    ),
                    SizedBox(height: 12),
                    Divider(color: MyColors.divider, height: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MyTextButton(
                            text: "Cancel",
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                        MyTextButton(
                            text: "Select",
                            onPressed: () {
                              value.showModal();
                            }),
                        MyTextButton(
                            text: "Merge",
                            onPressed: () async {
                              String name = "new";
                              bool willAdd = false;
                              await showDialog(
                                context: context,
                                barrierDismissible: false,
                                child: AlertDialog(
                                  backgroundColor: MyColors.violet,
                                  title: Text("Set Name", style: TextStyles.medium.size(22)),
                                  content: TextFormField(
                                    autofocus: true,
                                    style: TextStyles.medium,
                                    decoration: Styles.myInputDecoration(),
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]"))],
                                    onChanged: (newName) => name = newName,
                                  ),
                                  actions: [
                                    MyTextButton(text: "Cancel", onPressed: () => Navigator.pop(context)),
                                    MyTextButton(
                                        text: "Done",
                                        onPressed: () {
                                          if (name == "") name = "new";
                                          willAdd = true;
                                          Navigator.pop(context);
                                        }),
                                  ],
                                ),
                              );
                              if (willAdd) {
                                await _contactsViewModel.addNumbersFromMerge(name, value.value);
                                Navigator.pop(context);
                              }
                              // Navigator.pop(context);
                            },
                            enabled: isValid),
                        SizedBox(width: 12),
                      ],
                    ),
                  ],
                ),
              ),

              onChange: (state) {},
              modalType: S2ModalType.popupDialog,
              modalTitle: "Merge Contacts",
              modalHeaderStyle: S2ModalHeaderStyle(
                backgroundColor: MyColors.violetDark,
                textStyle: TextStyles.medium.size(18),
                actionsIconTheme: IconThemeData(color: Colors.orange[200]),
                iconTheme: IconThemeData(color: Colors.white),
              ),
              modalStyle: S2ModalStyle(backgroundColor: MyColors.violet),
              choiceStyle: S2ChoiceStyle(color: MyColors.violetLight, titleStyle: TextStyles.medium),
              choiceTitleBuilder: (context, choice, searchText) => ListTile(
                contentPadding: EdgeInsets.all(0),
                title: Text(choice.value.name, style: TextStyles.medium),
                subtitle: Text("${NumberFormat.compact().format(choice.value.length)}",
                    style: TextStyles.small.weight(FontWeight.w300)),
              ),
              // modalConfirm: true,
              // modalConfig: S2ModalConfig(confirmIcon: Icon(Icons.check)),
              modalFooterBuilder: (context, _) {
                return Column(
                  children: [
                    Divider(color: MyColors.divider, height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // MyTextButton(
                        //     text: "Back",
                        //     onPressed: () {
                        //       Navigator.pop(context);
                        //       // Navigator.pop(context);
                        //     }),
                        MyTextButton(
                            text: "Select",
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            enabled: isValid),
                        SizedBox(width: 12),
                      ],
                    )
                  ],
                );
              },
              modalValidation: (currentValue) {
                // value = currentValue;
                if (currentValue.length < 2) {
                  isValid = false;
                  return "Select At Least 2";
                }
                isValid = true;

                return "";
              },
            ),
          ),
        );
      },
    );
  }
}
