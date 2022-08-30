/// An [Exception] to be throw when this current subtree don't have any provided
/// bloc of [Type].
class RxBlocNotProvidedException implements Exception {
  RxBlocNotProvidedException(this.type);

  final Type type;

  @override
  String toString() {
    return "Can't find Provided Bloc of type $type";
  }
}

/// An [Exception] to be throw when the specific [Type] of this bloc is not
/// provided, please specified the generic parameters before doing any query:
/// ```dart
/// // bad
/// RxProvider.of(context);
/// ```
///
/// ```dart
/// //good
/// RxProvider.of<CounterBloc>(context);
/// ```
class RxBlocMustBeOfSpecificTypeException implements Exception {
  @override
  String toString() {
    return "Bloc must be of specific type";
  }
}

/// An [Exception] to be throw when this current subtree don't have any
/// provided service of [Type].
class ServiceNotProvidedException implements Exception {
  ServiceNotProvidedException(this.type);

  final Type type;

  @override
  String toString() {
    return "Can't find Provided Service of type $type";
  }
}

/// An [Exception] to be throw when the specific [Type] of this Service is not
/// provided, please specified the generic parameters before doing any query:
/// ```dart
/// // bad
/// ServiceProvider.of(context);
/// ```
///
/// ```dart
/// //good
/// ServiceProvider.of<MyRepo>(context);
/// ```
class ServiceMustBeOfSpecificTypeException implements Exception {
  @override
  String toString() {
    return "Service must be of specific type";
  }
}
