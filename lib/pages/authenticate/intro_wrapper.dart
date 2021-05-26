import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:mass_text_flutter/shared/bouncing_button.dart';
import 'package:mass_text_flutter/shared/constants.dart';

import '../../styles.dart';

class IntroWrapper extends StatefulWidget {
  @override
  _IntroWrapperState createState() => _IntroWrapperState();
}

class _IntroWrapperState extends State<IntroWrapper> with TickerProviderStateMixin {
  AnimationController scaleController;
  // AnimationController rippleController;
  AnimationController scaleInController;
  Animation<double> scaleAnimation;
  Animation<double> scaleInAnimation;
  // Animation<double> rippleAnimation;
  bool showCheck = true;
  final listPagesViewModel = [
    _pageViewModel(title: "Multi-SMS", body: "Send thousands of messages in one go.", imageUrl: "assets/multi_sms.png"),
    _pageViewModel(
        title: "Filter Contacts",
        body: "Uses an AI-powered smart filter to correct sloppy typed phone numbers",
        imageUrl: "assets/filter.png"),
    _pageViewModel(
        title: "Auto Re-Loading Feature",
        body: "Sends a customizable SMS after every X successful messages.",
        imageUrl: "assets/auto_reload.png"),
    _pageViewModel(title: "IT'S FREE", body: "No Advertisement.\nBuilt-in Premium Features.\nAll Free."),
  ];

  @override
  void initState() {
    super.initState();
    scaleInController = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    // rippleController = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    scaleController = AnimationController(vsync: this, duration: Duration(milliseconds: 1000))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Navigator.pushReplacementNamed(context, Constants.LoginRoute, arguments: true);

          // Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: Dashboard()));
        }
      });
    scaleAnimation = Tween<double>(begin: 1.0, end: 50.0)
        .animate(CurvedAnimation(curve: Curves.fastOutSlowIn, parent: scaleController));
    scaleInAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(curve: Curves.bounceOut, parent: scaleInController));

    // rippleAnimation = Tween<double>(begin: 80.0, end: 90.0).animate(rippleController)
    //   ..addStatusListener((status) {
    //     if (status == AnimationStatus.completed) {
    //       rippleController.reverse();
    //     } else if (status == AnimationStatus.dismissed) {
    //       rippleController.forward();
    //     }
    //   });
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: listPagesViewModel,
      showNextButton: false,
      onDone: () {
        // Navigator.pushReplacementNamed(context, Constants.LoginRoute);
      },
      onChange: (page) {
        if (page == listPagesViewModel.length - 1) {
          scaleInController.forward();
          // rippleController.forward();
        } else if (scaleInController.value != 0) scaleInController.reset();
      },
      onSkip: () {
        // You can also override onSkip callback
      },
      globalBackgroundColor: MyColors.violetDarker,
      showSkipButton: false,

      skip: CircleAvatar(
        child: Text("SKIP", style: TextStyles.medium),
        backgroundColor: MyColors.violetDarker,
        minRadius: 30,
      ),
      next: BouncingButton.circle(
        Icon(Icons.arrow_forward, size: 36, color: Colors.white),
        () {
          // if (scaleController.isAnimating) return;
          // scaleController.forward();
        },
        color: Color(0xFF0F0818),
      ),

      done: AnimatedBuilder(
        animation: scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedBuilder(
          animation: scaleInAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: scaleInAnimation.value,
              child: BouncingButton.circle(
                Icon(Icons.check,
                    key: UniqueKey(), size: 36, color: showCheck ? MyColors.violetDark : MyColors.violetLight),
                () {
                  if (scaleController.isAnimating) return;
                  scaleController.forward();
                  setState(() => showCheck = false);
                },
                color: MyColors.violetLight,
              ),
            );
          },
        ),
      ),

      // done: InkWell(
      //   customBorder: CircleBorder(),
      //   onTap: () {
      //     if (scaleController.isAnimating) return;
      //     scaleController.forward();
      //   },
      //   child: AnimatedBuilder(
      //     animation: scaleAnimation,
      //     builder: (context, child) {
      //       return Transform.scale(
      //         scale: scaleAnimation.value,
      //         child: Container(
      //           height: 60,
      //           width: 60,
      //           margin: EdgeInsets.all(10),
      //           decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xFF0F0818)),
      //           child: scaleAnimation.value == 1.0 ? Icon(Icons.arrow_forward, size: 36, color: Colors.white) : null,
      //         ),
      //       );
      //     },
      //   ),
      // ),
      // done: InkWell(
      //   splashColor: Colors.white,
      //   child: CircleAvatar(
      //     child: Icon(Icons.arrow_forward, size: 36, color: Colors.white),
      //     backgroundColor: Color(0xFF0F0818),
      //     minRadius: 30,
      //   ),
      // ),
      dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(20.0, 10.0),
          // activeColor: theme.accentColor,
          color: Colors.grey[400],
          activeColor: Colors.white,
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))),
    );
  }

  @override
  void dispose() {
    scaleInController.dispose();
    scaleController.dispose();
    super.dispose();
  }
}

PageViewModel _pageViewModel({String title = "", String body = "", String imageUrl = "assets/icon/icon_splash.png"}) {
  return PageViewModel(
    title: title,
    body: body,
    decoration: PageDecoration(
      titleTextStyle: TextStyles.large.size(30),
      bodyTextStyle: TextStyles.medium.size(24).colour(Colors.grey[400]).weight(FontWeight.w300),
      imagePadding: EdgeInsets.only(bottom: 0),
    ),
    image: Center(
      child: Image.asset(imageUrl, height: 175.0),
    ),
  );
}
