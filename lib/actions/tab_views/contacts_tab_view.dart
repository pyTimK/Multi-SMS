import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mass_text_flutter/models/settings.dart';
import 'package:mass_text_flutter/services/my_permission_handler.dart';
import 'package:mass_text_flutter/view/contacts_viewmodel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_select/smart_select.dart';

import '../../styles.dart';

class MyContact {
  MyContact(this.name, this.number, this.avatar);
  String name;
  String number;
  Uint8List avatar;
}

class ContactsTabView extends StatefulWidget {
  ContactsTabView(this.contactsViewModel);
  final ContactsViewModel contactsViewModel;
  @override
  _ContactsTabViewState createState() => _ContactsTabViewState();
}

class _ContactsTabViewState extends State<ContactsTabView> with AutomaticKeepAliveClientMixin {
  List<MyContact> contacts = [];
  String filter = "";
  List<S2Choice<MyContact>> frameworks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getContacts();
  }

  Future<void> getContacts() async {
    setState(() => isLoading = true);
    refresh();
    MyPermissionHandler.hasPermission([Permission.contacts]).then((hasPermission) async {
      if (hasPermission) {
        (await ContactsService.getContacts(withThumbnails: true)).forEach((contact) {
          if (contact.phones.isNotEmpty) {
            contact.phones.forEach((phone) => frameworks.add(S2Choice<MyContact>(
                value: MyContact(contact.displayName, phone.value, contact.avatar),
                title: "${contact.displayName}\n${phone.value}")));
          }
        });
      }
      setState(() => isLoading = false);
    });
  }

  Future<void> refresh() async {
    await Future.delayed(Duration(seconds: 11));
    if (isLoading) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return isLoading
        ? Center(
            child: SpinKitDoubleBounce(
            color: Colors.purple,
            size: 50,
          ))
        : frameworks.length == 0
            ? GestureDetector(
                onTap: getContacts,
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.clear, size: 72, color: MyColors.violetLight),
                    Text("Cannot load contacts", style: TextStyles.medium.colour(MyColors.violetLighter)),
                    SizedBox(height: 6),
                    Text("Tap To Relad", style: TextStyles.medium.colour(MyColors.violetLighter)),
                  ],
                )))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 6,
                    fit: FlexFit.loose,
                    child: Container(
                      alignment: Alignment.center,
                      // decoration: BoxDecoration(border: Border.all(color: MyColors.violetLighter)),

                      child: SmartSelect<MyContact>.multiple(
                        tileBuilder: (context, value) => SingleChildScrollView(
                          child: Column(
                            children: [
                              RaisedButton.icon(
                                icon: Icon(Icons.group_add),
                                label: Text("Add From Contacts"),
                                // color: Colors.orange[200],
                                onPressed: () {
                                  if (frameworks == null) {
                                    getContacts().then((_) => value.showModal());
                                  } else {
                                    value.showModal();
                                  }
                                },
                              ),
                              SizedBox(height: 12),
                              Container(
                                height: 130,
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(border: Border.all(color: MyColors.violetLight)),
                                width: 230,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: value.value.length,
                                  itemBuilder: (context, index) => ListTile(
                                    visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                                    dense: true,
                                    contentPadding: EdgeInsets.all(0),
                                    leading: value.value[index].avatar != null && value.value[index].avatar.length > 0
                                        ? CircleAvatar(
                                            backgroundImage: MemoryImage(value.value[index].avatar), radius: 15)
                                        : CircleAvatar(
                                            child: Text(value.value[index].name.substring(0, 1).toUpperCase() ?? "Z"),
                                            radius: 15),
                                    title: Text(value.value[index].name, style: TextStyles.medium.size(14)),
                                    subtitle: Text(value.value[index].number,
                                        style: TextStyles.small.weight(FontWeight.w300).size(10)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        modalTitle: "Phone Numbers",
                        modalFilterHint: "Search numbers",
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
                          leading: choice.value.avatar != null && choice.value.avatar.length > 0
                              ? CircleAvatar(backgroundImage: MemoryImage(choice.value.avatar))
                              : CircleAvatar(
                                  child: Text(choice.value.name.substring(0, 1).toUpperCase() ?? "Z"),
                                ),
                          title: Text(choice.value.name, style: TextStyles.medium),
                          subtitle: Text(choice.value.number, style: TextStyles.small.weight(FontWeight.w300)),
                        ),
                        modalConfirm: true,
                        modalConfig: S2ModalConfig(confirmIcon: Icon(Icons.check)),
                        modalFilter: true,
                        modalFilterAuto: true,
                        title: 'Frameworks',
                        value: contacts,
                        choiceItems: frameworks ?? [],
                        onChange: (state) => setState(() {
                          contacts = state.value;
                        }),
                      ),
                      // child: IconButton(
                      //   iconSize: 96,
                      //   splashColor: MyColors.violet,
                      //   icon: Icon(Icons.group_add, color: MyColors.violetLighter),
                      //   onPressed: () {
                      //     MyPermissionHandler.hasPermission([Permission.contacts]).then((hasPermission) async {
                      //       if (hasPermission) {
                      //         List<Contact> _contacts =
                      //             (await ContactsService.getContacts()).where((contact) => contact.phones.isNotEmpty).toList();

                      //         // await showSearch(
                      //         //   context: context,
                      //         //   delegate: DataSearch(_contacts),
                      //         // );

                      //       }
                      //     });
                      //   },
                      // ),
                      // color: Colors.black38,
                    ),
                  ),
                  // IMPORT TEXT BUTTON ------------------------------------------------------------------
                  Flexible(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // MyTextButton(text: "Cancel", onPressed: () => Navigator.pop(context)),
                        if (contacts.length > 0)
                          MyTextButton(
                              text: "Import",
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
                                  List<String> numbers = contacts.map((contact) => contact.number).toList();
                                  await widget.contactsViewModel.addNumbersFromContacts(name, numbers);
                                  Navigator.pop(context);
                                }
                              }),
                      ],
                    ),
                  ),
                ],
              );
  }

  @override
  bool get wantKeepAlive => true;
}

// class DataSearch extends SearchDelegate<String> {
//   DataSearch(this.contacts);
//   final List<Contact> contacts;
//   List<Contact> selectedContacts = [];

//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: Icon(Icons.clear),
//         onPressed: () {},
//       ),
//     ];
//   }

//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: AnimatedIcon(
//         icon: AnimatedIcons.menu_arrow,
//         progress: transitionAnimation,
//       ),
//       onPressed: () {
//         // close()
//       },
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     // TODO: implement buildResults
//     throw UnimplementedError();
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     print("Selected Contacts : ${selectedContacts.toString()}");
//     print("Contacts Length: ${contacts.length}");
//     return ListView.builder(
//       itemCount: contacts.length,
//       itemBuilder: (context, index) {
//         Contact contact = contacts[index];
//         return ListTile(
// leading: contact.avatar != null && contact.avatar.length > 0
//     ? CircleAvatar(backgroundImage: MemoryImage(contact.avatar))
//     : CircleAvatar(
//         child: Text(contact.initials()),
//       ),
//           title: Text(contact.displayName),
//           subtitle: Text(contact.phones.elementAt(0).value),
//         );
//       },
//     );
//   }
// }

class SearchContacts extends StatefulWidget {
  SearchContacts(this.controller, this.numbers, this.phoneFormatSettings, this.addNumbers);
  final TextEditingController controller;
  final List<String> numbers;
  final PhoneFormatSettings phoneFormatSettings;
  final Function(PhoneFormatSettings) addNumbers;
  @override
  _SearchContactsState createState() => _SearchContactsState();
}

class _SearchContactsState extends State<SearchContacts> {
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  bool showClear = false;
  IconData _icon = Icons.clear;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      print('listened');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    showClear = widget.controller.text.length != 0;
    final validLength = widget.phoneFormatSettings.trailingLength;
    return Form(
      key: _key,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 12),
          width: 230,
          child: TextFormField(
            controller: widget.controller,
            decoration:
                Styles.myInputDecoration(padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0), radius: 10)
                    .copyWith(
              counterText: " ",
              // suffixIcon: Icon(Icons.add_box, color: MyColors.violetLight),
              // prefixText: "+" + widget.phoneFormatSettings.prefix + " ",
              prefixIcon: Icon(Icons.search, size: 20, color: MyColors.violetLighter),
              prefixIconConstraints: BoxConstraints.expand(width: 36),
              // prefixStyle: TextStyles.medium.colour(Colors.white),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: MyColors.darkRed, width: 2)),
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: MyColors.darkRed, width: 2)),
              hintText: "Search Contacts",
              hintStyle: TextStyles.medium.size(14).colour(Colors.grey),
              suffixIcon: showClear
                  ? GestureDetector(
                      onTap: _icon == Icons.clear ? _clearInput : () => _addNumbers(widget.phoneFormatSettings),
                      child: Icon(_icon,
                          color: _icon == Icons.clear ? MyColors.violetLight : Colors.orange[200], size: 24))
                  : SizedBox(width: 24, height: 24),
            ),
            keyboardType: TextInputType.number,
            onEditingComplete: () => _addNumbers(widget.phoneFormatSettings),
            onChanged: (newNum) {
              setState(() {
                showClear = newNum.length != 0;
                _icon = newNum.length == validLength ? Icons.add : Icons.clear;
              });
            },
            textAlignVertical: TextAlignVertical(y: .4),
            // style: TextStyles.medium,
            style: TextStyles.medium,
            inputFormatters: [
              LengthLimitingTextInputFormatter(validLength),
              FilteringTextInputFormatter.allow(RegExp("[0-9]"))
            ],
            validator: (value) {
              if (value.length == validLength) return null;
              return "Input must be of length ${validLength}";
            },
          ),
        ),
        // SizedBox(width: 6),
        // Container(
        //   padding: const EdgeInsets.only(bottom: 12),
        //   child: GestureDetector(
        //     onTap: () => _addNumbers(phoneFormatSettings),
        //     child: Icon(Icons.add_circle, color: Colors.orange[200], size: 32),
        //   ),
        // ),
      ]),
    );
  }

  void _clearInput() {
    setState(() {
      widget.controller.clear();
      showClear = false;
    });
  }

  void _addNumbers(PhoneFormatSettings phoneFormatSettings) {
    if (!_key.currentState.validate()) return;
    widget.addNumbers(phoneFormatSettings);
  }
}
