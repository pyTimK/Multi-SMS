import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mass_text_flutter/models/numbers_collection.dart';
import 'package:mass_text_flutter/shared/view_numbers.dart';
import 'package:mass_text_flutter/styles.dart';
import 'package:mass_text_flutter/view/contacts_viewmodel.dart';
import 'package:mass_text_flutter/view/home_viewmodel.dart';
import 'package:provider/provider.dart';

class Contacts extends StatefulWidget {
  Contacts(this.setPageTo);

  final Function(int) setPageTo;
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> with AutomaticKeepAliveClientMixin {
  List<NumbersCollection> toMerge = [];
  @override
  Widget build(BuildContext context) {
    final ContactsViewModel _contactsViewModel = Provider.of<ContactsViewModel>(context);
    final HomeViewModel _homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Theme(
        data: ThemeData(canvasColor: Colors.transparent),
        child: ReorderableListView(
          children: _myListBuilder(_contactsViewModel, _homeViewModel),
          onReorder: _contactsViewModel.reorderList,
        ),
      ),
    );
  }

  List<Widget> _myListBuilder(ContactsViewModel contactsViewModel, HomeViewModel homeViewModel) {
    final List<NumbersCollection> numbersCollections = contactsViewModel.numbersCollection;
    List<Widget> widgets = [];
    for (int i = 0; i < numbersCollections.length; i++) {
      NumbersCollection numbersCollection = numbersCollections[i];
      String name = numbersCollection.name;
      String length = NumberFormat.compact().format(numbersCollection.length);
      widgets.add(Dismissible(
        key: ValueKey(numbersCollection.name),
        child: ListTile(
          title: Text(name, style: TextStyles.medium),
          subtitle: Text("$length phone numbers", style: TextStyles.small.weight(FontWeight.w300)),
          trailing: name == homeViewModel.recipient ? Icon(Icons.check, color: Colors.white) : null,
          onTap: () => _showSelectDialog(context, name, homeViewModel, widget.setPageTo),
        ),
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            contactsViewModel.deleteItem(i);
            if (name == homeViewModel.recipient) homeViewModel.deleteRecipient();
          }
        },
        confirmDismiss: (direction) async {
          bool willDismiss = false;
          if (direction == DismissDirection.startToEnd) {
            showDialog(
              context: context,
              child: RenameDialog(
                numbersCollection: numbersCollection,
                i: i,
                contactsViewModel: contactsViewModel,
                homeViewModel: homeViewModel,
              ),
            );
          } else {
            await showDialog(
              context: context,
              child: AlertDialog(
                backgroundColor: MyColors.violet,
                title: Text("Delete '$name' ?", style: TextStyles.medium.size(22)),
                contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                buttonPadding: EdgeInsets.all(0),
                actions: [
                  MyTextButton(text: "No", onPressed: () => Navigator.pop(context)),
                  MyTextButton(
                      text: "Yes",
                      onPressed: () {
                        willDismiss = true;
                        Navigator.pop(context);
                      }),
                ],
              ),
            );
          }
          return Future<bool>.value(willDismiss);
        },
        background: Container(
          padding: EdgeInsets.only(left: 12),
          alignment: Alignment.centerLeft,
          color: Colors.green[200],
          child: Icon(Icons.edit, size: 30),
        ),
        secondaryBackground: Container(
          padding: EdgeInsets.only(right: 12),
          alignment: Alignment.centerRight,
          color: Colors.red[200],
          child: Icon(Icons.delete, size: 30),
        ),
      ));
    }
    return widgets;
  }

  void _showSelectDialog(BuildContext context, String name, HomeViewModel homeViewModel, Function(int) setPageTo) {
    if (name == homeViewModel.recipient) {
      showDialog(
        context: context,
        child: AlertDialog(
          backgroundColor: MyColors.violet,
          title: Text("'$name'", style: TextStyles.medium.size(22)),
          content: ViewNumbers.fromTxtFile(name),
          // SizedBox(height: 12),
          // Text("This will restart the index at zero.", style: TextStyles.medium.size(14)),
          // ]),
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          buttonPadding: EdgeInsets.all(0),
          actions: [
            MyTextButton(text: "Close", onPressed: () => Navigator.pop(context)),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      child: AlertDialog(
        backgroundColor: MyColors.violet,
        title: Text("Select '$name' ?", style: TextStyles.medium.size(22)),
        content: ViewNumbers.fromTxtFile(name),
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        buttonPadding: EdgeInsets.all(0),
        actions: [
          MyTextButton(text: "No", onPressed: () => Navigator.pop(context)),
          MyTextButton(text: "Yes", onPressed: () => _readFile(context, name, homeViewModel, widget.setPageTo)),
        ],
      ),
    );
  }

  Future<void> _readFile(
      BuildContext context, String name, HomeViewModel homeViewModel, Function(int) setPageTo) async {
    bool success = await homeViewModel.selectRecipient(name);
    homeViewModel.reset();
    if (!success) MyToast.show("'$name' Load Failed");
    Navigator.pop(context);
    setState(() {});
    setPageTo(0);
  }

  @override
  bool get wantKeepAlive => true;
}

class RenameDialog extends StatelessWidget {
  const RenameDialog({
    Key key,
    @required this.numbersCollection,
    @required this.i,
    @required this.contactsViewModel,
    @required this.homeViewModel,
  }) : super(key: key);

  final NumbersCollection numbersCollection;
  final int i;
  final ContactsViewModel contactsViewModel;
  final HomeViewModel homeViewModel;

  @override
  Widget build(BuildContext context) {
    String newName = numbersCollection.name;
    return AlertDialog(
      backgroundColor: MyColors.violet,
      title: Text("Set New Name", style: TextStyles.medium.size(22)),
      content: TextFormField(
        style: TextStyles.medium,
        initialValue: numbersCollection.name,
        decoration: Styles.myInputDecoration(),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]"))],
        onChanged: (oldName) => newName = oldName,
      ),
      actions: [
        MyTextButton(text: "Done", onPressed: () => _rename(i, newName, context, contactsViewModel, homeViewModel)),
      ],
    );
  }

  Future<void> _rename(int i, String newName, BuildContext context, ContactsViewModel contactsViewModel,
      HomeViewModel homeViewModel) async {
    bool success = await contactsViewModel.renameItem(i, newName ?? "", context);
    if (success && contactsViewModel.numbersCollection[i].name == homeViewModel.recipient) {
      await homeViewModel.renameRecipient(newName);
    }
    // await Future.delayed(const Duration(milliseconds: 500));
    if (success) Navigator.pop(context);
  }
}
