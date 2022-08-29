import 'package:flutter/material.dart';

import 'rx_bloc.dart';
import 'rx_provider.dart';
import 'type_def.dart';

class _RxBuilderBase<B extends RxBlocBase, S> extends StatefulWidget {
  const _RxBuilderBase({
    Key? key,
    required this.builder,
    this.shouldRebuildWidget,
    this.shouldRebuildSingleState,
  })  : assert(shouldRebuildWidget == null || shouldRebuildSingleState == null),
        super(key: key);
  final RxBlocWidgetBuilder<S> builder;
  final ShouldRebuildWidget<S>? shouldRebuildWidget;
  final ShouldRebuildSingleState<S>? shouldRebuildSingleState;

  @override
  State<_RxBuilderBase<B, S>> createState() => _RxBuilderBaseState<B, S>();
}

class _RxBuilderBaseState<B extends RxBlocBase, S>
    extends State<_RxBuilderBase<B, S>> {
  Widget? _cachedWidget;
  S? _cachedState;
  late S _state;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _state = context.watch<B>().state;
  }

  @override
  Widget build(BuildContext context) {
    Widget? newWidget;

    if (_cachedWidget == null ||
        ((widget.shouldRebuildWidget?.call(_cachedState as S, _state) ??
                true) &&
            (widget.shouldRebuildSingleState?.call(_state) ?? true))) {
      newWidget = widget.builder(context, _state);
      _cachedWidget = newWidget;
      _cachedState = _state;
    } else {
      newWidget = _cachedWidget;
    }
    return newWidget!;
  }
}

class RxBuilder<B extends RxSilentBloc<S>, S> extends _RxBuilderBase<B, S> {
  const RxBuilder({
    Key? key,
    required RxBlocWidgetBuilder<S> builder,
    ShouldRebuildWidget<S>? shouldRebuildWidget,
  }) : super(
            key: key,
            builder: builder,
            shouldRebuildWidget: shouldRebuildWidget);
}

class RxSingleStateBuilder<B extends RxSingleStateBloc>
    extends _RxBuilderBase<B, B> {
  const RxSingleStateBuilder({
    Key? key,
    required RxBlocWidgetBuilder<B> builder,
    ShouldRebuildSingleState? shouldRebuildWidget,
  }) : super(
            key: key,
            builder: builder,
            shouldRebuildSingleState: shouldRebuildWidget);
}
