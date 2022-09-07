import 'rx_bloc.dart';

/// Extension for [RxValue].
///
/// Short hand way to create an [RxValue].
///
/// ```dart
/// final myVal = RxValue<int>(0);
/// ```
/// ... is equivalent to:
///
/// ```dart
/// final myVal = 0.rx;
/// ```
/// It can be created on any type of object.
extension RxValueExtension<T> on T {
  RxValue<T> get rx {
    return RxValue<T>(this);
  }
}
