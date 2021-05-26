import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:mass_text_flutter/models/numbers_collection.dart';
import 'package:mass_text_flutter/models/settings.dart';
import 'package:mass_text_flutter/services/phone_numbers.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../styles.dart';

abstract class ContactsManager {
  static Future<File> get _getNumberFile async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );
    if (result == null) return null;
    return File(result.files.single.path);
  }

  static Future<bool> addNewNumbers(PhoneFormatSettings phoneFormatSettings, bool lineSeparated, bool isPremium) async {
    final File file = await _getNumberFile;
    if (file == null || !file.existsSync()) return false;
    final String fileName = basename(file.path);
    List<String> numberList;
    if (lineSeparated) {
      numberList = await file.readAsLines();
    } else {
      String fileString = await file.readAsString();
      numberList = fileString.split(",");
    }

    final filterInput = FilterInput(numberList, phoneFormatSettings);
    numberList = await compute(PhoneNumbers.filter, filterInput);
    if (!isPremium && numberList.length > 300) numberList = numberList.sublist(0, 300);
    bool success = await ContactsStorage.addFile(fileName, numberList);
    if (success) {
      if (!isPremium && numberList.length == 300) {
        MyToast.show("Only Gold users can import more than 300 contacts", isLong: true);
      } else {
        MyToast.show("Contact Numbers Added :)");
      }
    } else {
      MyToast.show("Problem Loading Text File :(");
    }
    return success;
  }
}

class FilterInput {
  FilterInput(this.numberList, this.phoneFormatSettings);
  List<String> numberList;
  PhoneFormatSettings phoneFormatSettings;
}

abstract class ContactsStorage {
  static Future<String> get _localPath async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  static String _truncateTxt(String input) => input.substring(0, input.length - 4);

  static Future<bool> addFile(String name, List<String> numberList) async {
    //'name' = example.txt

    try {
      final String path = await _localPath;
      String filePath = "$path/${_truncateTxt(name)}";
      File file = File("$filePath.txt");
      int runner = 0;
      while (file.existsSync()) {
        //Checks if filePath exists
        runner++;
        filePath = "$path/${_truncateTxt(name)}$runner";
        file = File("$filePath.txt");
      }
      file.writeAsString(numberList.join("\n"));
      await appendMain(basename(filePath), numberList.length);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  static Future<bool> mergeFiles(String name, List<NumbersCollection> numberCollectionList) async {
    //'name' = example

    try {
      final String path = await _localPath;
      String filePath = "$path/$name";
      File file = File("$filePath.txt");
      int runner = 0;
      while (file.existsSync()) {
        //Checks if filePath exists
        runner++;
        filePath = "$path/${name}$runner";
        file = File("$filePath.txt");
      }

      List<String> numberCollections = [];

      for (var numberCollection in numberCollectionList) {
        numberCollections.addAll(await readFile(numberCollection.name) ?? []);
      }

      file.writeAsString(numberCollections.join("\n"));

      await appendMain(
          basename(filePath), numberCollectionList.map((number) => number.length).fold(0, (p, c) => p + c));
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  static Future<bool> deleteFile(String name) async {
    try {
      final String path = await _localPath;
      String filePath = "$path/$name.txt";
      final File file = File(filePath);
      if (!file.existsSync()) return false;
      file.deleteSync(recursive: true);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  static Future<bool> renameFile(String oldName, String newName) async {
    try {
      final String path = await _localPath;
      String filePath = "$path/$oldName.txt";
      final File file = File(filePath);
      if (!file.existsSync()) return false;
      file.renameSync("$path/$newName.txt");
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  static Future<List<String>> readFile(String name) async {
    //Reads the file in the storage with  name'name'
    final String path = await _localPath;
    final File file = File("$path/$name.txt");
    if (file == null || !file.existsSync()) return null;
    List<String> numberList = await file.readAsLines();
    return numberList;
  }

  static Future<File> get mainFile async {
    final String path = await _localPath;
    File file = File('$path/maindb.json');
    if (!file.existsSync()) {
      file.createSync();
      file.writeAsStringSync(jsonEncode({}));
    }
    return file;
  }

  static Future<List<NumbersCollection>> readMain() async {
    try {
      final File file = await mainFile;
      final String numberList = await file.readAsString();
      final Map<String, dynamic> json = await jsonDecode(numberList);
      return json.keys.map((name) => NumbersCollection(name: name, length: json[name])).toList();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static Future<bool> rewriteMain(List<NumbersCollection> numbersCollections) async {
    try {
      final File file = await mainFile;
      Map<String, dynamic> json = NumbersCollection.toJSON(numbersCollections);
      file.writeAsStringSync(jsonEncode(json));
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  static Future<void> appendMain(String name, int length) async {
    final File file = await mainFile;
    final Map<String, dynamic> json = jsonDecode(file.readAsStringSync());
    json[name] = length;
    await file.writeAsString(jsonEncode(json));
  }
}
