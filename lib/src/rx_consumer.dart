import 'package:flutter/material.dart';

import 'rx_listener.dart';
import 'rx_builder.dart';
import 'rx_bloc.dart';
import 'type_def.dart';

class RxConsumer<B extends RxBloc<S, N>, S, N> extends StatelessWidget {
  const RxConsumer({
    Key? key,
    this.notificationCallback,
    this.stateCallback,
    required this.builder,
    this.shouldRebuildWidget,
  }) : super(key: key);

  final RxBlocEventListener<N>? notificationCallback;
  final RxBlocEventListener<S>? stateCallback;
  final RxBlocWidgetBuilder<S> builder;
  final ShouldRebuildWidget<S>? shouldRebuildWidget;

  @override
  Widget build(BuildContext context) {
    return RxListener<B, S, N>(
      stateCallback: stateCallback,
      notificationCallback: notificationCallback,
      child: RxBuilder<B, S>(
        builder: builder,
        shouldRebuildWidget: shouldRebuildWidget,
      ),
    );
  }
}
