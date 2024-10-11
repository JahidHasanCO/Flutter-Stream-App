part of 'router.dart';

final class AppRouter {
  /// Routing configuration and handler implementation using GoRouter.
  /// * Prevents instance duplication based on initialLocation.
  factory AppRouter({String? initialLocation}) =>
      initialLocation == _instance?.initialLocation
          ? _instance ??= AppRouter._(initialLocation: initialLocation)
          : _instance = AppRouter._(initialLocation: initialLocation);

  AppRouter._({this.initialLocation})
      : config = GoRouter(
          //-- Register routes
          routes: _routes ??= <RouteBase>[
            MediaPlayerPage.route,
          ],
          initialLocation: initialLocation,
          navigatorKey: _rootNavigatorKey ??= GlobalKey<NavigatorState>(),
        );

  static AppRouter? _instance;
  final String? initialLocation;
  static List<RouteBase>? _routes;
  final GoRouter config;
  static GlobalKey<NavigatorState>? _rootNavigatorKey;
}

extension GoRouteExt on GoRoute {
  String get pathUnderRoot => '/$path';
}
