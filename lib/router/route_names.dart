part of 'router.dart';

sealed class RouteNames {
  static String get mediaPlayer => 'media_player';
}

extension AsPathExt on String {
  String get asPath => '/$this';
}
