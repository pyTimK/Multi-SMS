import 'package:mass_text_flutter/services/contacts_storage.dart';

abstract class PhoneNumbers {
  static List<String> digits = ["+", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
  static List<String> _separators = ["/", "or", "and", ","];

  static List<String> filter(FilterInput filterInput) {
    final numberList = filterInput.numberList;
    final prefix = filterInput.phoneFormatSettings.prefix;
    final trailingLength = filterInput.phoneFormatSettings.trailingLength;
    List<String> newList = [];

    for (int i = 0, n = numberList.length; i < n; i++) {
      String number = numberList[i];
      for (final separator in _separators) {
        if (number.contains(separator)) {
          newList.addAll(_split(number, separator));
          numberList[i] = "deleted";
        }
      }
    }
    numberList.addAll(newList);

    for (int i = 0, n = numberList.length; i < n; i++) {
      String number = numberList[i];
      String newNum = "";

      //remove non-digit characters
      number.split('').forEach((char) {
        if (digits.contains(char)) newNum += char;
      });
      number = newNum;

      if (number.length < trailingLength - 1) {
        numberList[i] = "0";
        continue;
      }

      //converts countryCode to 0: ex. +63 to 0
      // if (number.substring(0, 3) == "+63") {
      //   number = "0" + number.substring(3, number.length);
      // }

      //converts 0 to +63
      if (number.substring(0, 1) == "0") {
        number = "+$prefix${number.substring(1, number.length)}";
      }

      //converts 63 to 0
      // if (number.substring(0, 2) == "63") {
      //   number = "0" + number.substring(2, number.length);
      // }

      //converts 63 to +63
      if (number.substring(0, prefix.length) == prefix) {
        number = "+" + number;
      }

      //length is 10 but no 0 in beginning
      // if (number.length == 10 && number.substring(0, 1) == "9") {
      //   number = "0" + number;
      // }

      // numberList[i] = number;

      //length is equal to trailingLength but no country code in beginning
      if (number.length == trailingLength && !number.contains("+")) {
        number = "+" + prefix + number;
      }

      numberList[i] = number;
    }

    newList = [];
    final length = prefix.length + trailingLength + 1;
    //remove invalid length
    //remove duplicates
    //remove numbers not starting in prefix
    for (int i = 0, n = numberList.length; i < n; i++) {
      String number = numberList[i];
      if (number.length == length) {
        if (!newList.contains(number)) {
          if (number.substring(0, prefix.length + 1) == "+$prefix") {
            newList.add(number);
          }
        }
      }
    }

    return newList;
  }

  static List<String> _split(String number, String separator) {
    int index = number.indexOf(separator);
    if (index == -1) return [number];
    List<String> former = index == 0 ? [] : _split(number.substring(0, index), separator);
    List<String> latter = index + separator.length >= number.length - 1
        ? []
        : _split(number.substring(index + separator.length, number.length), separator);
    return [...former, ...latter];
  }
}
