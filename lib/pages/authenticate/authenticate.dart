import 'package:flutter/material.dart';
import 'package:mass_text_flutter/models/user.dart';
import 'package:mass_text_flutter/services/auth.dart';
import 'package:mass_text_flutter/shared/bouncing_button.dart';
import 'package:mass_text_flutter/shared/constants.dart';
import 'package:mass_text_flutter/styles.dart';

class Authenticate extends StatefulWidget {
  Authenticate({this.toggleView, this.withCircle = false});

  final bool withCircle;
  final Function toggleView;

  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> with TickerProviderStateMixin {
  final AuthService _auth = AuthService();
  final GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
  AnimationController _controller;
  AnimationController scaleController;
  Animation<double> scaleAnimation;
  Animation<double> _fade;
  String email;
  String password;
  // bool loading = false;
  bool isNewUser = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 184));
    _fade = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(curve: Curves.ease, parent: _controller));
    scaleController = AnimationController(vsync: this, duration: Duration(milliseconds: 1900));
    scaleAnimation = Tween<double>(begin: 50.0, end: 0.0)
        .animate(CurvedAnimation(curve: Curves.easeInOutCubic, parent: scaleController));
    if (widget.withCircle) scaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
              colors: [MyColors.blueDark, MyColors.violetDark],
            ),
          ),
          padding: EdgeInsets.only(top: 50),
          child: SingleChildScrollView(
            child: AnimatedBuilder(
              animation: _fade,
              builder: (context, child) => Opacity(
                opacity: _fade.value,
                child: child,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  children: [
                    SizedBox(width: 120, height: 120, child: Image.asset("assets/icon/icon_splash.png")),
                    Text("Welcome${isNewUser ? "" : " back"}", style: TextStyles.large.size(38)),
                    SizedBox(height: 36),
                    Form(
                      key: _keyForm,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            initialValue: email,
                            decoration: Styles.myInputDecoration().copyWith(
                              hintText: "What's your email?",
                              hintStyle: TextStyles.medium.colour(Colors.grey),
                              counterText: " ",
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context).nextFocus(),
                            style: TextStyles.medium,
                            validator: (val) {
                              if (val.length == 0) return 'Email is Required.';
                              bool isEmailValid = RegExp(
                                      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                                  .hasMatch(val);
                              if (!isEmailValid) return "Please Enter a Valid Email";
                              return null;
                            },
                            onSaved: (val) => email = val,
                          ),
                          SizedBox(height: 6),
                          TextFormField(
                            initialValue: password,
                            decoration: Styles.myInputDecoration().copyWith(
                              hintText: isNewUser ? "Create a Password" : "Enter your password",
                              hintStyle: TextStyles.medium.colour(Colors.grey),
                              counterText: " ",
                            ),
                            style: TextStyles.medium,
                            obscureText: true,
                            validator: (val) {
                              if (val.length == 0) return 'Password is required';
                              if (val.length < 6) return 'Password must be at least 6 characters long';
                              return null;
                            },
                            onSaved: (val) => password = val,
                          ),
                          SizedBox(height: 6),
                          BouncingButton(isNewUser ? "CREATE ACCOUNT" : "LOG IN", () async {
                            if (_keyForm.currentState.validate()) {
                              _keyForm.currentState.save();
                              // setState(() => loading = true);
                              Navigator.pushNamed(context, Constants.LoadingRoute);
                              dynamic result;
                              if (isNewUser) {
                                result = await _auth.registerWithEmailAndPassword(email, password);
                              } else {
                                result = await _auth.signInWithEmailAndPassword(email, password);
                              }
                              Navigator.pop(context);
                              if (result == null) {
                                // setState(() => loading = false);
                              } else {
                                print('SIGNED IN!');
                                Navigator.pushReplacementNamed(context, Constants.HomeRoute);
                              }
                            }
                          }, color: Colors.black, width: double.infinity, labelColor: Colors.white),
                          SizedBox(height: 12),
                          Text("OR", style: TextStyle(color: Color(0xffBFBFBF), fontWeight: FontWeight.bold)),
                          SizedBox(height: 12),
                          BouncingButton("COUNTINUE WITH GOOGLE", () async {
                            // setState(() => loading = true);
                            Navigator.pushNamed(context, Constants.LoadingRoute);
                            MyUser result = await _auth.googleSignIn();
                            Navigator.pop(context);
                            if (result == null) {
                              // setState(() => loading = false);
                              MyToast.show("Problem occured while signing in");
                            } else {
                              print('SIGNED IN!');
                              Navigator.pushReplacementNamed(context, Constants.HomeRoute);
                            }
                          },
                              color: Colors.white,
                              width: double.infinity,
                              labelColor: Colors.black,
                              logo: "assets/google64.png"),
                          SizedBox(height: 36),
                          Text(isNewUser ? "Already have an account?" : "New user?",
                              style: TextStyles.medium.size(14).weight(FontWeight.w600).colour(Color(0xFFD8D8D8))),
                          SizedBox(height: 6),
                          BouncingButton(
                            isNewUser ? "LOG IN" : "SIGN UP",
                            () {
                              _controller.forward().then((_) {
                                setState(() => isNewUser = !isNewUser);
                                _controller.reverse();
                              });
                            },
                            color: MyColors.violetDark,
                            labelColor: Colors.white,
                            height: 30,
                            width: 100,
                          )
                          // GestureDetector(
                          //   onTap: () => setState(() => isNewUser = !isNewUser),
                          //   child: Text(isNewUser ? "LOG IN" : "SIGN UP",
                          //       style: TextStyles.medium
                          //           .size(14)
                          //           .weight(FontWeight.w600)
                          //           .colour(Color(0xFFFFFFFF))
                          //           .copyWith(decoration: TextDecoration.underline)),
                          // ),
                          // RichText(
                          //     textAlign: TextAlign.center,
                          //     text: TextSpan(
                          //         style: TextStyles.medium.size(14).weight(FontWeight.w600).colour(Color(0xFFD8D8D8)),
                          //         children: [
                          //           TextSpan(text: "Already have an account?\n"),
                          //           TextSpan(
                          //               text: "LOG IN",
                          //               style: TextStyles.medium
                          //                   .size(14)
                          //                   .weight(FontWeight.w600)
                          //                   .colour(Color(0xFFFFFFFF))
                          //                   .copyWith(decoration: TextDecoration.underline)),
                          //         ])),
                          // RichText(
                          //     textAlign: TextAlign.center,
                          //     text: TextSpan(
                          //         style: TextStyles.medium.size(12).weight(FontWeight.w600).colour(Color(0xFFD8D8D8)),
                          //         children: [
                          //           TextSpan(text: "By creating an account, you agree\nto our "),
                          //           TextSpan(
                          //               text: "Privacy Policy",
                          //               style: TextStyles.medium
                          //                   .size(12)
                          //                   .weight(FontWeight.w600)
                          //                   .colour(Color(0xFFFFFFFF))
                          //                   .copyWith(decoration: TextDecoration.underline)),
                          //         ])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      if (widget.withCircle)
        Positioned(
          left: -40,
          top: -40,
          child: AnimatedBuilder(
            animation: scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: scaleAnimation.value,
                child: child,
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: MyColors.violetLight,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
    ]);
  }

  @override
  void dispose() {
    scaleController.dispose();
    _controller.dispose();
    super.dispose();
  }
}
