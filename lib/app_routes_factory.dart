import 'package:ansarlogistics/common_features/feature_login/login_page_route_builder.dart';
import 'package:ansarlogistics/common_features/feature_splash/splash_route_builder.dart';
import 'package:ansarlogistics/navigations/navigation.dart';
import 'package:ansarlogistics/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/navigator.dart';

class AppRoutesFactory extends RoutesFactory {
  final ServiceLocator _serviceLocator;

  AppRoutesFactory(this._serviceLocator);

  @override
  Route createSplashPageRoute() {
    // TODO: implement createSplashPageRoute
    return CustomRoute(builder: SplashRouteBuilder());
  }

  @override
  Route createLoginPageRoute() {
    // TODO: implement createLoginPageRoute
    return CustomRoute(builder: LoginPageRouteBuilder(_serviceLocator));
  }
}

class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({required WidgetBuilder builder}) : super(builder: builder);
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      transformHitTests: false,
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          reverseCurve: Curves.easeOut,
          parent: animation,
          curve: Curves.ease,
        ),
      ),
      child: child,
    );
  }
}
