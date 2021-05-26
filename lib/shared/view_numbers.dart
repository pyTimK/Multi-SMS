import 'package:flutter/material.dart';
import 'package:mass_text_flutter/models/settings.dart';
import 'package:mass_text_flutter/services/contacts_storage.dart';

import '../styles.dart';

enum ViewNumbersInputType { list, map, txtFile }

class ViewNumbers extends StatefulWidget {
  ViewNumbers(this.list, this.phoneFormatSettings, this.textEditingController)
      : this.inputType = ViewNumbersInputType.list,
        this.filter = null,
        this.name = null;
  ViewNumbers.withFilter(this.list, this.filter, this.phoneFormatSettings, this.textEditingController)
      : this.inputType = ViewNumbersInputType.map,
        this.name = null;
  ViewNumbers.fromTxtFile(this.name)
      : this.inputType = ViewNumbersInputType.txtFile,
        this.list = null,
        this.phoneFormatSettings = null,
        this.textEditingController = null,
        this.filter = null;

  final String name;
  final List<String> list;
  final String filter;
  final ViewNumbersInputType inputType;
  final PhoneFormatSettings phoneFormatSettings;
  final TextEditingController textEditingController;
  @override
  _ViewNumbersState createState() => _ViewNumbersState();
}

class _ViewNumbersState extends State<ViewNumbers> {
  List<String> viewNumbers = [];
  final ScrollController _controller = ScrollController();
  Map<int, String> filteredNumbers = {};

  @override
  void initState() {
    super.initState();
    if (widget.inputType == ViewNumbersInputType.txtFile) {
      _viewNumbersFromTxtFile(widget.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<int> _keys;
    int itemCount;
    int _startSubstring;
    int _endSubstring;
    if (widget.inputType == ViewNumbersInputType.txtFile) {
      itemCount = viewNumbers.length;
    } else if (widget.inputType == ViewNumbersInputType.map) {
      viewNumbers = widget.list;
      _startSubstring = widget.phoneFormatSettings.prefix.length + 1;
      _endSubstring = _startSubstring + widget.filter.length;
      if (widget.filter.length > 0) {
        filteredNumbers.clear();
        for (int i = 0, n = viewNumbers.length; i < n; i++) {
          if (viewNumbers[i].substring(_startSubstring, _endSubstring) == widget.filter) {
            filteredNumbers[i + 1] = viewNumbers[i];
          }
        }
      }
      _keys = filteredNumbers.keys.toList();
      itemCount = _keys.length;
    } else {
      _startSubstring = widget.phoneFormatSettings.prefix.length + 1;
      viewNumbers = widget.list;
      itemCount = viewNumbers.length;
    }

    final length = viewNumbers.length;
    final indexTxtWidth = (length.toString().length) * 8.5 + 6.0;
    return Container(
      height: 100,
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(border: Border.all(color: MyColors.violetLight)),
      width: 230,
      child: Stack(
        children: [
          Container(
            child: ListView.builder(
              controller: _controller,
              itemCount: itemCount,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                int _index = widget.inputType != ViewNumbersInputType.map ? index + 1 : _keys[index];
                String _number =
                    widget.inputType != ViewNumbersInputType.map ? viewNumbers[index] : filteredNumbers[_index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          padding: EdgeInsets.only(right: 6),
                          width: indexTxtWidth,
                          child: Text(
                            "${_index}",
                            style: TextStyles.small.weight(FontWeight.w300).colour(Colors.grey),
                            textAlign: TextAlign.right,
                          )),
                      Text("${_number}", style: TextStyles.medium.size(16)),
                      if (widget.inputType != ViewNumbersInputType.txtFile) ...[
                        SizedBox(width: 6),
                        GestureDetector(
                            onTap: () {
                              widget.textEditingController.text =
                                  viewNumbers.removeAt(_index - 1).substring(_startSubstring);
                              print("edit: ${widget.textEditingController.text}");
                              setState(() {});
                            },
                            child: Icon(Icons.edit, color: Colors.orange[200], size: 14)),
                        SizedBox(width: 12),
                        GestureDetector(
                            onTap: () {
                              print("removed: ${viewNumbers.removeAt(_index - 1)}");
                              setState(() {});
                            },
                            child: Icon(Icons.delete_outline, color: Colors.orange[200], size: 14)),
                      ]
                    ],
                  ),
                );
              },
              // separatorBuilder: (context, index) => Divider(color: Color(0xFFB29ECF), height: 6, endIndent: 60),
            ),
          ),
          Positioned(right: 0, child: ScrollLocation(_controller)),
        ],
      ),
    );
  }

  Future<void> _viewNumbersFromTxtFile(String name) async {
    List<String> readFile = await ContactsStorage.readFile(name) ?? [];
    setState(() {
      viewNumbers = readFile;
    });
  }
}

class ScrollLocation extends StatefulWidget {
  ScrollLocation(this.controller);
  final ScrollController controller;
  @override
  _ScrollLocationState createState() => _ScrollLocationState();
}

class _ScrollLocationState extends State<ScrollLocation> {
  final outerHeight = 100.0;
  final innerHeight = 25.0;
  double heightDiff;
  double topOffset = 0;

  @override
  void initState() {
    super.initState();
    heightDiff = outerHeight - innerHeight;
    widget.controller.addListener(() {
      double max = widget.controller.position.maxScrollExtent;
      double offset = widget.controller.offset;
      if (max == 0) return;
      setState(() {
        topOffset = (offset / max) * heightDiff;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // print("max:${widget.controller.position.maxScrollExtent}");
    if (widget.controller.position.maxScrollExtent == 0 || widget.controller.position.maxScrollExtent == null)
      return Container();
    return Container(
      padding: EdgeInsets.only(top: topOffset),
      height: outerHeight,
      width: 4,
      alignment: Alignment.topCenter,
      // color: Colors.green,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(0), color: Colors.white24),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(0), color: Colors.white),
        width: 4,
        height: innerHeight,
      ),
    );
  }
}
