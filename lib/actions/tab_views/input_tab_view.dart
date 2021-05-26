import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mass_text_flutter/models/settings.dart';
import 'package:mass_text_flutter/shared/view_numbers.dart';
import 'package:mass_text_flutter/view/contacts_viewmodel.dart';

import '../../styles.dart';

class InputTabView extends StatefulWidget {
  InputTabView(this.contactsViewModel);
  final ContactsViewModel contactsViewModel;
  @override
  _InputTabViewState createState() => _InputTabViewState();
}

class _InputTabViewState extends State<InputTabView> with AutomaticKeepAliveClientMixin {
  TextEditingController _controller = TextEditingController();
  List<String> numbers = [];
  String filter = "";

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final phoneFormatSettings = widget.contactsViewModel.phoneFormatSettings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ADD TEXT FIELD ------------------------------------------------------------------
        Flexible(flex: 4, child: AddTxtField(_controller, numbers, phoneFormatSettings, _addNumbers)),
        // SEARCH TEXT FIELD ------------------------------------------------------------------
        Flexible(
          flex: 2,
          child: SearchTxtField(phoneFormatSettings, _filterNumbers),
        ),
        // VIEW NUMBERS ------------------------------------------------------------------
        Flexible(
          flex: 6,
          fit: FlexFit.loose,
          child: Container(
            child: filter.length > 0
                ? ViewNumbers.withFilter(numbers, filter, phoneFormatSettings, _controller)
                : ViewNumbers(numbers, phoneFormatSettings, _controller),
          ),
        ),
        // IMPORT TEXT BUTTON ------------------------------------------------------------------
        Flexible(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // MyTextButton(text: "Cancel", onPressed: () => Navigator.pop(context)),
              if (numbers.length > 0)
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
                        await widget.contactsViewModel.addNumbersFromList(name, numbers);
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

  void _addNumbers(PhoneFormatSettings phoneFormatSettings) {
    setState(() {
      numbers.insert(0, "+${phoneFormatSettings.prefix}${_controller.text}");
      _controller.clear();
    });
  }

  void _filterNumbers(String newFilter) {
    setState(() {
      filter = newFilter;
    });
  }
}

class SearchTxtField extends StatefulWidget {
  SearchTxtField(this.phoneFormatSettings, this.filterNumbers);
  final PhoneFormatSettings phoneFormatSettings;
  final Function(String) filterNumbers;
  @override
  _SearchTxtFieldState createState() => _SearchTxtFieldState();
}

class _SearchTxtFieldState extends State<SearchTxtField> {
  TextEditingController _searchController = TextEditingController();
  IconData _searchIcon = Icons.search;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          isDense: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(0)), borderSide: BorderSide(color: MyColors.violetLight)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(0)),
            borderSide: BorderSide(color: MyColors.violetLight),
          ),
          contentPadding: EdgeInsets.all(8),
          fillColor: MyColors.violetLight,
          filled: true,
          hintText: "Search",
          suffixIcon: GestureDetector(
              onTap: () {
                if (_searchIcon == Icons.search) {
                } else {
                  _searchController.clear();
                  widget.filterNumbers("");
                  setState(() {
                    _searchIcon = Icons.search;
                  });
                }
              },
              child: Icon(_searchIcon, color: Colors.black, size: 22)),
          isCollapsed: true,
          prefixText: "+" + widget.phoneFormatSettings.prefix + " ",
          prefixStyle: TextStyles.medium.colour(Colors.black87).size(14),
        ),
        keyboardType: TextInputType.number,
        style: TextStyles.medium.size(14).colour(Colors.black),
        inputFormatters: [
          LengthLimitingTextInputFormatter(widget.phoneFormatSettings.trailingLength),
          FilteringTextInputFormatter.allow(RegExp("[0-9]"))
        ],
        onChanged: (value) {
          widget.filterNumbers(value);
          setState(() {
            _searchIcon = value.length == 0 ? Icons.search : Icons.clear;
          });
        },
        // validator: (value) {
        //   if (value.length == phoneFormatSettings.trailingLength) return null;
        //   return "Input must be of length ${phoneFormatSettings.trailingLength}";
        // },
      ),
    );
  }
}

class AddTxtField extends StatefulWidget {
  AddTxtField(this.controller, this.numbers, this.phoneFormatSettings, this.addNumbers);
  final TextEditingController controller;
  final List<String> numbers;
  final PhoneFormatSettings phoneFormatSettings;
  final Function(PhoneFormatSettings) addNumbers;
  @override
  _AddTxtFieldState createState() => _AddTxtFieldState();
}

class _AddTxtFieldState extends State<AddTxtField> {
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  bool showClear = false;
  IconData _icon = Icons.clear;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // print("reloaded AddtxtField State");
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
              prefixText: "+" + widget.phoneFormatSettings.prefix + " ",
              prefixStyle: TextStyles.medium.colour(Colors.white),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: MyColors.darkRed, width: 2)),
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: MyColors.darkRed, width: 2)),
              hintText: "Add Phone Number",
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
