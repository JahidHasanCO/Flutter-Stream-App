import 'package:stream_app/utils/utils.dart';

extension StringExt on String {
  String get streamUrl =>
      Constants.streamBaseUrl + this + Constants.hslEndPoint;

  String get downloadUrl =>
      Constants.streamBaseUrl + this + Constants.downloadEndPoint;
}
