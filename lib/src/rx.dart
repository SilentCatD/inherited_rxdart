import 'package:get_it/get_it.dart';
import 'package:inherited_rxdart/inherited_rxdart.dart';

/// Static class to register and unregister an Rx or service.
class Rx {
  /// Function to put an Rx lazily, which can be get with [Rx.get]. This
  /// function will call the [init] Function of [RxBase]
  static void put<T extends RxBase>(Create<T> create) {
    return GetIt.I.registerLazySingleton<T>(
        () => create.call()
          ..init()
          ..disposeWhenPop = true, dispose: (T rx) {
      return rx.dispose();
    });
  }

  /// Function to add an Rx, which can be get with [Rx.get]. This function will
  /// not the [init] Function of [RxBase]
  static void putI<T extends RxBase>(T instance) {
    return GetIt.I.registerSingleton<T>(instance);
  }

  /// Function to get instance of type [T] of [RxBase]
  static T get<T extends RxBase>() {
    return GetIt.I<T>();
  }

  /// Function to unregister an instance of type [T] of [RxBase].
  /// If the instance is registered with [Rx.put], the [RxBase.dispose] function
  /// will also be called.
  static void pop<T extends RxBase>() {
    final instance = get<T>();
    GetIt.I.unregister<T>(
      instance: instance,
      disposingFunction: (T instance) {
        if (!instance.disposed && instance.disposeWhenPop) {
          instance.dispose();
        }
      },
    );
  }

  /// Function to put a simple instance of any class, which can be get with
  /// [Rx.getS].
  static void putS<T extends Object>(Create<T> create) {
    return GetIt.I.registerLazySingleton<T>(() => create.call());
  }

  /// Function to put an instance lazily, which can be get with [Rx.getS].
  static void putSI<T extends Object>(T instance) {
    return GetIt.I.registerSingleton<T>(instance);
  }

  /// Function to get an instance of any type.
  static T getS<T extends Object>() {
    return GetIt.I<T>();
  }

  /// Function to unregister instance of any type.
  static void popS<T extends Object>() {
    final instance = getS<T>();
    GetIt.I.unregister<T>(
      instance: instance,
    );
  }
}
