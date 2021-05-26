import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

abstract class Fonts {
  static String get sourceSansPro => 'SourceSansPro';
}

abstract class TextStyles {
  static TextStyle get small => TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white);
  static TextStyle get medium => TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white);
  static TextStyle get large => TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white);
}

extension TextStyleHelper on TextStyle {
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);
  TextStyle get underlined => copyWith(decoration: TextDecoration.underline);
  TextStyle colour(Color value) => copyWith(color: value);
  TextStyle weight(FontWeight value) => copyWith(fontWeight: value);
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);
  TextStyle size(double value) => copyWith(fontSize: value);
}

abstract class MyColors {
  static Color get orange => const Color(0xfffe0000);
  static Color get green => const Color(0xff0a5e2a);
  static Color get lightGreen => const Color(0xff6dac4f);
  static Color get darkRed => const Color(0xffBB000E);
  static Color get alphaDarkRed => const Color(0xcc000000);
  static Color get link => const Color(0xff0000CD);
  static Color get grey => const Color(0xff000000);
  static Color get aboutContainer => const Color(0xFFFFBBBB);
  static Color get blue => const Color(0xFF2D3762);
  static Color get blueDark => const Color(0xFF1B2038);
  static Color get violet => const Color(0xFF524069);
  static Color get violetLight => const Color(0xFF8E8BC9);
  static Color get violetLighter => const Color(0xFFB1AEDD);
  static Color get violetDark => const Color(0xFF402C5E);
  static Color get violetDarker => const Color(0xFF1D102E);
  static Color get divider => const Color(0xFFB29ECF);
}

abstract class Styles {
  static InputDecoration myInputDecoration(
      {bool isDense = false, EdgeInsetsGeometry padding = const EdgeInsets.all(12), double radius = 10}) {
    return InputDecoration(
      isDense: isDense,
      contentPadding: padding,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          borderSide: BorderSide(color: MyColors.violetLight, width: 2)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
          borderSide: BorderSide(color: MyColors.violetLighter, width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius)), borderSide: BorderSide(color: Colors.red, width: 2)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius)), borderSide: BorderSide(color: Colors.red, width: 2)),
    );
  }
}

class MyNumberJumpToTextField extends StatelessWidget {
  const MyNumberJumpToTextField({Key key, @required this.input}) : super(key: key);
  final List<int> input;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 64,
        child: TextFormField(
          textAlign: TextAlign.center,
          style: TextStyles.medium.weight(FontWeight.w500),
          decoration: Styles.myInputDecoration(padding: EdgeInsets.symmetric(horizontal: 2, vertical: 8)),
          cursorColor: MyColors.darkRed,
          enableInteractiveSelection: false,
          inputFormatters: [LengthLimitingTextInputFormatter(6), FilteringTextInputFormatter.allow(RegExp("[0-9]"))],
          keyboardType: TextInputType.number,
          onChanged: (val) {
            input[0] = int.parse(val) ?? 0;
          },
        ));
  }
}

abstract class MyToast {
  static void show(String msg, {bool isLong = false}) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: isLong ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[700],
        textColor: Colors.white,
        fontSize: 14.0);
  }
}

class MyTextButton extends StatelessWidget {
  MyTextButton({@required this.text, @required this.onPressed, this.enabled = true});
  final String text;
  final Function onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text(text,
          textAlign: TextAlign.end, style: TextStyles.medium.colour(enabled ? Colors.teal[200] : Colors.grey[700])),
      onPressed: () {
        if (enabled) onPressed();
      },
    );
  }
}

Widget myContainer(Widget child, {double width, double height}) {
  return Container(
    width: width,
    height: height,
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(10.0),
      boxShadow: [
        BoxShadow(
          color: Color(0x80000000),
          blurRadius: 6.0,
          offset: Offset(0.0, 3.0),
        ),
      ],
      color: MyColors.violetDark,
    ),
    child: child,
  );
}
