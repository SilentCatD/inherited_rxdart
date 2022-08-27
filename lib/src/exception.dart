class RxBlocNotProvidedException implements Exception {
  RxBlocNotProvidedException(this.type);

  final Type type;

  @override
  String toString() {
    return "Can't find Provided Bloc of type $type";
  }
}

class RxBlocMustBeOfSpecificTypeException implements Exception {
  @override
  String toString() {
    return "Bloc must be of specific type";
  }
}

class ServiceNotProvidedException implements Exception {
  ServiceNotProvidedException(this.type);

  final Type type;

  @override
  String toString() {
    return "Can't find Provided Service of type $type";
  }
}

class ServiceMustBeOfSpecificTypeException implements Exception {
  @override
  String toString() {
    return "Service must be of specific type";
  }
}
