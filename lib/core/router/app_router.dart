import 'package:flutter/material.dart';
import 'route_names.dart';

/// Top-level application router configuration.
/// Directs authenticated users to KG or Grade experiences based on user metadata.
class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return _buildRoute(
          settings,
          const Scaffold(body: Center(child: Text('Splash Screen'))),
        );
      case RouteNames.login:
        return _buildRoute(
          settings,
          const Scaffold(body: Center(child: Text('Login Screen'))),
        );
      case RouteNames.kgHome:
        return _buildRoute(
          settings,
          const Scaffold(body: Center(child: Text('KG Home Screen'))),
        );
      case RouteNames.gradeDashboard:
        return _buildRoute(
          settings,
          const Scaffold(body: Center(child: Text('Grade Dashboard Screen'))),
        );
      case RouteNames.profile:
        return _buildRoute(
          settings,
          const Scaffold(body: Center(child: Text('Profile Screen'))),
        );
      default:
        return _buildRoute(
          settings,
          Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
    RouteSettings settings,
    Widget child,
  ) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => child,
    );
  }

  AppRouter._();
}
