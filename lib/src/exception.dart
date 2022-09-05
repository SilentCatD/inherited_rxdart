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

/// Exception to be thrown when trying to set the bloc [RxBlocBase.initialized]
/// variable to False, the default value of this variable is False when the
/// bloc is created.
class BlocInitializedSetToFalseException implements Exception {
  @override
  String toString() {
    return "Setting the initialized variable of blocs to False is not allowed";
  }
}

/// Exception to be thrown when an initialized bloc, which
/// [RxBlocBase.initialized] are [True], are set again. For blocs can only be
/// init one time.
class BlocInitializedASecondTimeException implements Exception {
  @override
  String toString() {
    return "Initialized variable of an initialized bloc is set to True a second time";
  }
}
