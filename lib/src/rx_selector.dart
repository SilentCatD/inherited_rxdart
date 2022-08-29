import 'package:flutter/material.dart';
import 'rx_bloc.dart';
import 'rx_provider.dart';
import 'type_def.dart';

class RxSelector<B extends RxBloc<S>, S, T> extends StatefulWidget {
  const RxSelector({
    Key? key,
    required this.stateRebuildSelector,
    required this.builder,
  }) : super(key: key);
  final StateRebuildSelector<S, T> stateRebuildSelector;
  final RxBlocWidgetBuilder<S> builder;

  @override
  State<RxSelector<B, S, T>> createState() => _RxSelectorState<B, S, T>();
}

class _RxSelectorState<B extends RxBloc<S>, S, T>
    extends State<RxSelector<B, S, T>> {
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
