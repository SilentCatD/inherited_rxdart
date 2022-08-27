import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'rx_provider.dart';

class RxMultiProvider extends Nested {
  RxMultiProvider(
      {Key? key, required List<RxProvider> providers, required Widget child})
      : super(key: key, children: providers, child: child);
}
