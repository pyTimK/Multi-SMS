import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mass_text_flutter/styles.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black54,
        body: Center(
          child: SpinKitDoubleBounce(
            color: Colors.purple,
            size: 50,
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    MyToast.show("Loading Data");
    return Future<bool>.value(false);
  }
}
