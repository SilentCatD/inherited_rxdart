import 'rx_bloc.dart';

extension RxValueExtension<T> on T {
  RxValue<T> get rx {
    return RxValue<T>(this);
  }
}
