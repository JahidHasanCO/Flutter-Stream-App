import 'package:flutter/foundation.dart';

extension NullableObjectExt on Object? {
  /// A string representation of this object.
  /// * Parse `null` into 'N/A' (Not Available) or given value.
  /// * See also [toString] doc comment.
  String toStringNullParsed([String value = 'N/A']) =>
      this == null ? value : toString();

  //// {@macro doPrint}
  void doPrint([String prefix = '', int level = 3]) {
    if (kDebugMode) {
      // final code = switch (level) { 0 => 36, 1 => 33, 2 => 31, _ => 32 };
      // 1018 is the size of character chunk (Dart supports max 1023 reduced 5
      // for special character that colorizes.
      RegExp('.{1,1018}')
          .allMatches(toString())
          // .map((m) => m.group(0))
          // below line was fine but problem from vscode 1.94 not printing color
          // breaks as  [32mNAMES: ()[0m
          // .map((m) => '\x1B[${code}m$prefix${m.group(0)}\x1B[0m')
          .map((m) => '$prefix${m.group(0)}')
          // ignore: avoid_print
          .forEach(print);
    }
  }

// void mark([int level = 3]) {
//   if (kDebugMode) {
//     final code = switch (level) { 0 => 36, 1 => 33, 2 => 31, _ => 32 };
//     final text = '\x1B[${code}mMark: ${toString()}\x1B[0m';
//     // ignore: avoid_print
//     RegExp('.{1,800}').allMatches(text).map((m) => m.group(0)).forEach(print);
//   }
// }

  /// Whether this object is null or empty String/Iterable/Map.
// bool get isNullOrEmpty {
//   final obj = this;
//   if (obj is String) {
//     return obj.isEmpty;
//   } else if (obj is Iterable) {
//     return obj.isEmpty;
//   } else if (obj is Map) {
//     return obj.isEmpty;
//   }
//   return obj == null;
// }
}
