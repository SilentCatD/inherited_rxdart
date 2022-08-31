import 'package:flutter/material.dart';
import 'rx_bloc.dart';
import 'rx_provider.dart';
import 'type_def.dart';

class RxSelectorBase<B extends RxBlocBase, S, T> extends StatefulWidget {
  const RxSelectorBase({
    Key? key,
    required this.stateRebuildSelector,
    required this.builder,
  }) : super(key: key);
  final StateRebuildSelector<S, T> stateRebuildSelector;
  final RxBlocWidgetBuilder<S> builder;

  @override
  State<RxSelectorBase<B, S, T>> createState() =>
      _RxSelectorBaseState<B, S, T>();
}

class _RxSelectorBaseState<B extends RxBlocBase, S, T>
    extends State<RxSelectorBase<B, S, T>> {
  Widget? _cachedWidget;
  T? _cachedValue;
  late T _value;
  late S _state;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _state = context.watch<B>().state;
    _value = widget.stateRebuildSelector(_state);
  }

  @override
  Widget build(BuildContext context) {
    Widget? newWidget;
    if (_cachedValue == null ||
        _cachedValue != widget.stateRebuildSelector(_state)) {
      newWidget = widget.builder(context, _state);
      _cachedWidget = newWidget;
      _cachedValue = _value;
    } else {
      newWidget = _cachedWidget;
    }
    return newWidget!;
  }
}

class RxSelector<B extends RxSilentBloc<S>, S, T>
    extends RxSelectorBase<B, S, T> {
  const RxSelector({
    Key? key,
    required StateRebuildSelector<S, T> stateRebuildSelector,
    required RxBlocWidgetBuilder<S> builder,
  }) : super(
            key: key,
            stateRebuildSelector: stateRebuildSelector,
            builder: builder);
}

class RxSingleStateSelector<B extends RxSingleStateBloc<B>, T>
    extends RxSelectorBase<B, B, T> {
  const RxSingleStateSelector({
    Key? key,
    required StateRebuildSelector<B, T> stateRebuildSelector,
    required RxBlocWidgetBuilder<B> builder,
  }) : super(
            key: key,
            stateRebuildSelector: stateRebuildSelector,
            builder: builder);
}
