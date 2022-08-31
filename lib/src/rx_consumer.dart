import 'package:flutter/material.dart';
import 'rx_bloc.dart';
import 'rx_listener.dart';
import 'type_def.dart';
import 'rx_builder.dart';

/// Combination of [RxStateListener] and [RxBuilder].
///
/// Work with:
/// * [RxBloc]
/// * [RxSilentBloc]
class RxStateConsumer<B extends RxSilentBloc<S>, S> extends StatefulWidget {
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

class _RxStateConsumerState<B extends RxSilentBloc<S>, S>
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

/// Combination of [RxSingleStateListener] and [RxSingleStateBuilder].
///
/// Work with:
/// * [RxSingleStateBloc]
class RxSingleStateConsumer<B extends RxSingleStateBloc<B>>
    extends StatefulWidget {
  const RxSingleStateConsumer({
    Key? key,
    this.stateCallback,
    required this.builder,
    this.shouldRebuildWidget,
  }) : super(key: key);
  final RxBlocEventListener<B>? stateCallback;
  final RxBlocWidgetBuilder<B> builder;
  final ShouldRebuildSingleState<B>? shouldRebuildWidget;

  @override
  State<RxSingleStateConsumer<B>> createState() =>
      _RxSingleStateConsumerState<B>();
}

class _RxSingleStateConsumerState<B extends RxSingleStateBloc<B>>
    extends State<RxSingleStateConsumer<B>> {
  @override
  Widget build(BuildContext context) {
    return RxSingleStateListener<B>(
      stateCallback: widget.stateCallback,
      child: RxSingleStateBuilder<B>(
        builder: widget.builder,
        shouldRebuildWidget: widget.shouldRebuildWidget,
      ),
    );
  }
}
