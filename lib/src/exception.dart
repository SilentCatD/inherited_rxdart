import 'package:inherited_rxdart/inherited_rxdart.dart';

import 'rx_provider.dart';

/// An [Exception] to be throw when this current subtree don't have any provided
/// RxBase of [Type].
class RxNotProvidedException implements Exception {
  RxNotProvidedException(this.type);

  final Type type;

  @override
  String toString() {
    return "Can't find Provided RxBase of type $type";
  }
}

/// An [Exception] to be throw when the specific [Type] of this RxBase is not
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
class RxMustBeOfSpecificTypeException implements Exception {
  @override
  String toString() {
    return "Rx instance must be of specific type";
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

/// Exception to be thrown when trying to set the RxBase [RxBase.initialized]
/// variable to False, the default value of this variable is False when the
/// Rx is created.
class RxInitializedSetToFalseException implements Exception {
  @override
  String toString() {
    return "Setting the initialized variable of Rx to False is not allowed";
  }
}

/// Exception to be thrown when an initialized Rx, which
/// [RxBase.initialized] are [True], are set again. For Rx can only be
/// init one time.
class RxInitializedASecondTimeException implements Exception {
  @override
  String toString() {
    return "Initialized variable of an initialized Rx is set to True a second time";
  }
}

/// Exception to be thrown when trying to set the RxBase [RxBase.disposed]
/// variable to False, the default value of this variable is False when the
/// Rx is created.
class RxDisposedSetToFalseException implements Exception {
  @override
  String toString() {
    return "Setting the initialized variable of Rx to False is not allowed";
  }
}

/// Exception to be thrown when an initialized Rx, which
/// [RxBase.disposed] are [True], are set again. For Rx can only be
/// dispose one time.
class RxDisposedASecondTimeException implements Exception {
  @override
  String toString() {
    return "Initialized variable of an initialized Rx is set to True a second time";
  }
}

/// Exception to be thrown when the RxWidget constructor change from .value
/// to creation constructor and vice-versa. The use of this is not yet supported.
class RxMapError implements Exception {
  @override
  String toString() {
    return "Failed to map from a .value constructor to creation constructor. "
        "While the instance changes of .value constructor is handled, the"
        "change between .value constructor and creation constructor is not "
        "allowed.";
  }
}

/// Exception to be thrown by [EventDispatcherMixin] when a duplication of event
/// type handler is registered.
class DuplicateTypeRegistryException implements Exception {
  final Type type;

  const DuplicateTypeRegistryException(this.type);

  @override
  String toString() {
    return "Failed to register a duplication event type $type. An event type can only be register for event-handling once.";
  }
}
