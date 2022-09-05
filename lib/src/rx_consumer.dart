import 'package:flutter/material.dart';

import 'rx_bloc.dart';
import 'rx_builder.dart';
import 'rx_listener.dart';
import 'type_def.dart';

/// Combination of [RxStateListener] and [RxBuilder].
///
/// Work with:
/// * [RxBloc]
/// * [RxCubit]
class RxStateConsumer<B extends RxCubit<S>, S> extends StatefulWidget {
  const RxStateConsumer({
    Key? key,
    this.stateCallback,
    this.shouldRebuildWidget,
    required this.builder,
  }) : super(key: key);

  final RxBlocEventListener<S>? stateCallback;
  final RxBlocWidgetBuilder<S> builder;
  final ShouldRebuildWidget<S>? shouldRebuildWidget;

  @override
  State<RxStateConsumer<B, S>> createState() => _RxStateConsumerState<B, S>();
}

class _RxStateConsumerState<B extends RxCubit<S>, S>
    extends State<RxStateConsumer<B, S>> {
  @override
  Widget build(BuildContext context) {
    return RxStateListener<B, S>(
      stateCallback: widget.stateCallback,
      child: RxBuilder<B, S>(
        shouldRebuildWidget: widget.shouldRebuildWidget,
        builder: widget.builder,
      ),
    );
  }
}

/// Combination of [RxListener] and [RxBuilder].
///
/// Work with:
/// * [RxBloc]
class RxConsumer<B extends RxBloc<S, N>, S, N> extends StatefulWidget {
  const RxConsumer({
    Key? key,
    required this.builder,
    this.shouldRebuildWidget,
    this.stateCallback,
    this.notificationCallback,
  }) : super(key: key);

  final RxBlocEventListener<S>? stateCallback;
  final RxBlocWidgetBuilder<S> builder;
  final ShouldRebuildWidget<S>? shouldRebuildWidget;
  final RxBlocEventListener<N>? notificationCallback;

  @override
  State<RxConsumer<B, S, N>> createState() => _RxConsumerState<B, S, N>();
}

class _RxConsumerState<B extends RxBloc<S, N>, S, N>
    extends State<RxConsumer<B, S, N>> {
  @override
  Widget build(BuildContext context) {
    return RxListener<B, S, N>(
      stateCallback: widget.stateCallback,
      notificationCallback: widget.notificationCallback,
      child: RxBuilder<B, S>(
        shouldRebuildWidget: widget.shouldRebuildWidget,
        builder: widget.builder,
      ),
    );
  }
}

/// Combination of [RxViewModelListener] and [RxViewModelBuilder].
///
/// Work with:
/// * [RxViewModel]
class RxViewModelConsumer<B extends RxViewModel> extends StatefulWidget {
  const RxViewModelConsumer({
    Key? key,
    this.stateCallback,
    required this.builder,
    this.shouldRebuildWidget,
  }) : super(key: key);
  final RxBlocEventListener<B>? stateCallback;
  final RxBlocWidgetBuilder<B> builder;
  final ShouldRebuildViewModel<B>? shouldRebuildWidget;

  @override
  State<RxViewModelConsumer<B>> createState() => _RxViewModelConsumerState<B>();
}

class _RxViewModelConsumerState<B extends RxViewModel>
    extends State<RxViewModelConsumer<B>> {
  @override
  Widget build(BuildContext context) {
    return RxViewModelListener<B>(
      stateCallback: widget.stateCallback,
      child: RxViewModelBuilder<B>(
        builder: widget.builder,
        shouldRebuildWidget: widget.shouldRebuildWidget,
      ),
    );
  }
}
