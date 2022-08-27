class RxBlocNotProvidedException implements Exception {
  RxBlocNotProvidedException(this.type);

  final Type type;

  @override
  String toString() {
    return "Can't find Provided Bloc of type $type";
  }
}

class RxBlocMustBeOfSpecificType implements Exception {
  @override
  String toString() {
    return "Bloc must be of specific type";
  }
}
