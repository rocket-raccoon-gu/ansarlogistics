part of 'navigation.dart';

Route<dynamic>? Function(RouteSettings settings) onGenerateAppRoute(
    RoutesFactory routesFactory) {
  return (RouteSettings settings) {
    switch (settings.name) {
      case _splash:
        return routesFactory.createSplashPageRoute();
      case _loginPageRouteName:
        return routesFactory.createLoginPageRoute();
      default:
        return null;
    }
  };
}
