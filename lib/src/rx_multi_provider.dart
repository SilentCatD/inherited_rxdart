import 'package:flutter/material.dart';
import 'package:inherited_rx_dart/inherited_rx_dart.dart';
import 'package:nested/nested.dart';

class RxMultiProvider extends Nested {
  RxMultiProvider(
      {Key? key, required List<RxProvider> providers, required Widget child})
      : super(key: key, children: providers, child: child);
}
