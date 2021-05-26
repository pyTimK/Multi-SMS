import 'package:flutter/material.dart';
import 'package:mass_text_flutter/pages/authenticate/authenticate.dart';
import 'package:mass_text_flutter/pages/authenticate/intro_wrapper.dart';
import 'package:mass_text_flutter/shared/constants.dart';
import 'package:mass_text_flutter/shared/loading.dart';

import 'Wrapper.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Constants.IntroRoute:
      return MaterialPageRoute(builder: (context) => IntroWrapper());
      break;

    case Constants.LoginRoute:
      return MaterialPageRoute(builder: (context) => Authenticate(withCircle: settings.arguments ?? false));
      break;
    case Constants.HomeRoute:
      return MaterialPageRoute(builder: (context) => Wrapper());
      break;
    case Constants.LoadingRoute:
      return TransparentRoute(builder: (context) => Loading());
      break;
    default:
      return MaterialPageRoute(builder: (context) => Authenticate());
  }
}

class TransparentRoute extends PageRoute<void> {
  TransparentRoute({
    @required this.builder,
    RouteSettings settings,
  })  : assert(builder != null),
        super(settings: settings, fullscreenDialog: false);

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  Color get barrierColor => null;

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 350);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final result = builder(context);
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(animation),
      child: Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: result,
      ),
    );
  }
}
