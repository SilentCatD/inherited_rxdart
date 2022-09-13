part of 'rx_provider.dart';

/// Static class to register and unregister an Rx or service.
class Rx {
  /// Function to put an Rx lazily, which can be get with [Rx.get]. This
  /// function will call the [init] Function of [RxBase] if the Create function
  /// create a [RxBase].
  static void put<T extends Object>(Create<T> create) {
    return GetIt.I.registerLazySingleton<T>(() {
      final instance = create.call();
      if (instance is RxBase) {
        instance.init();
        instance._disposeWhenPop = true;
        return instance;
      }
      return instance;
    }, dispose: (T rx) {
      if (T is RxBase) {
        return (rx as RxBase).dispose();
      }
    });
  }

  /// Function to add an Rx, which can be get with [Rx.get]. This function will
  /// not the [init] Function of [RxBase] if [T] is subtype of [RxBase]
  static void putI<T extends Object>(T instance) {
    return GetIt.I.registerSingleton<T>(instance);
  }

  /// Function to get instance of type [T]
  static T get<T extends Object>() {
    return GetIt.I<T>();
  }

  /// Function to unregister an instance of type [T]
  /// If the instance is registered with [Rx.put] and T is [RxBase], the
  /// [RxBase.dispose] function will also be called.
  static void pop<T extends Object>() {
    final instance = get<T>();
    GetIt.I.unregister<T>(
      instance: instance,
      disposingFunction: (T instance) {
        if (instance is RxBase) {
          if (!instance.disposed && instance._disposeWhenPop) {
            instance.dispose();
          }
        }
      },
    );
  }
}
