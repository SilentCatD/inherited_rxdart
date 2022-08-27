import 'package:flutter/material.dart';

import 'rx_bloc.dart';
import 'rx_provider.dart';
import 'type_def.dart';

class RxBuilder<B extends RxBloc<S>, S> extends StatelessWidget {
  const RxBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);
  final RxBlocWidgetBuilder<S> builder;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<B>().state;
    return builder(context, state);
  }
}
