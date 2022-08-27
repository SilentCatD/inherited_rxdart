import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

class MultiServiceProvider extends Nested {
  MultiServiceProvider(
      {Key? key,
      required List<SingleChildWidget> services,
      required Widget child})
      : super(key: key, children: services, child: child);
}
