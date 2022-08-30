import 'package:flutter/material.dart';

import 'rx_listener.dart';
import 'rx_builder.dart';
import 'rx_bloc.dart';
import 'type_def.dart';

/// Combination of [RxListener] and [RxBuilder] for bloc [B] of type [RxBloc],
/// state [S] and notification [N]
class RxConsumer<B extends RxBloc<S, N>, S, N> extends StatelessWidget {
  const RxConsumer({
    Key? key,
    this.notificationCallback,
    this.stateCallback,
    required this.builder,
    this.shouldRebuildWidget,
  }) : super(key: key);

  /// Callback for notification emitted from [RxBloc]
  final RxBlocEventListener<N>? notificationCallback;

  /// Callback for state emitted from [RxBloc]
  final RxBlocEventListener<S>? stateCallback;

  /// Typical Builder function, which called when the bloc this widget depend
  /// on require its to rebuild itself with new value.
  final RxBlocWidgetBuilder<S> builder;

  /// Function to determine whether this widget should rebuild itself when state
  /// changed.
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
