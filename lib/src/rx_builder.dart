import 'package:flutter/material.dart';

import 'rx_bloc.dart';
import 'rx_provider.dart';
import 'type_def.dart';

class RxBuilder<B extends RxBloc<S>, S> extends StatefulWidget {
  const RxBuilder({
    Key? key,
    required this.builder,
    this.shouldRebuildWidget,
  }) : super(key: key);
  final RxBlocWidgetBuilder<S> builder;
  final ShouldRebuildWidget<S>? shouldRebuildWidget;

  @override
  State<RxBuilder<B, S>> createState() => _RxBuilderState<B, S>();
}

class _RxBuilderState<B extends RxBloc<S>, S> extends State<RxBuilder<B, S>> {
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
    if (_cachedWidget == null) {
      newWidget = widget.builder(context, _state);
      _cachedWidget = newWidget;
      _cachedState = _state;
    } else {
      final shouldRebuild =
          widget.shouldRebuildWidget?.call(_cachedState!, _state) ?? true;
      newWidget =
          shouldRebuild ? widget.builder(context, _state) : _cachedWidget;
    }
    return newWidget!;
  }
}
