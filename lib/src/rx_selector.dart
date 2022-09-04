import 'package:flutter/material.dart';
import 'rx_bloc.dart';
import 'rx_provider.dart';
import 'type_def.dart';

/// Widget for selectively rebuild ui base on a property of the whole state [S].
///
/// Base Widget for [RxSelector] and [RxSingleStateSelector].
class RxSelectorBase<B extends RxBlocBase<S>, S, T> extends StatefulWidget {
  const RxSelectorBase({
    Key? key,
    required this.stateRebuildSelector,
    required this.builder,
  }) : super(key: key);

  /// Function to select the property for rebuilding decision, only when  the
  /// property changed between states, would the ui rebuild.
  final StateRebuildSelector<S, T> stateRebuildSelector;

  /// Typical builder function, return a widget.
  final RxBlocWidgetBuilder<T> builder;

  @override
  State<RxSelectorBase<B, S, T>> createState() =>
      _RxSelectorBaseState<B, S, T>();
}

class _RxSelectorBaseState<B extends RxBlocBase<S>, S, T>
    extends State<RxSelectorBase<B, S, T>> {
  Widget? _cachedWidget;
  T? _cachedValue;
  late T _value;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.watch<B>().state;
    _value = widget.stateRebuildSelector(state);
  }

  @override
  Widget build(BuildContext context) {
    if (_cachedValue == null || _cachedValue != _value) {
      _cachedWidget = widget.builder(context, _value);
      _cachedValue = _value;
    }
    return _cachedWidget!;
  }
}

/// Widget for selectively rebuild ui base on a property [T] of the whole
/// state [S].
///
/// For example:
///
/// ```dart
/// RxSelector<CounterBloc, MyState, String>(
///   stateRebuildSelector: (state) {
///     return state.text;
///   }, builder: (context, value) {
///     debugPrint("build Text");
///     return Text("state text: $value");
///   }),
/// ```
/// ... the builder function will only be executed and a new widget is built
/// when [state.text] changed between state.
///
/// Work with:
/// * [RxSilentBloc]
/// * [RxBloc]
class RxSelector<B extends RxSilentBloc<S>, S, T>
    extends RxSelectorBase<B, S, T> {
  const RxSelector({
    Key? key,
    required StateRebuildSelector<S, T> stateRebuildSelector,
    required RxBlocWidgetBuilder<T> builder,
  }) : super(
            key: key,
            stateRebuildSelector: stateRebuildSelector,
            builder: builder);
}

/// Widget for selectively rebuild ui base on value of type [T] emitted by bloc
/// [B], with B is a subtype of [RxSingleStateBloc].
///
/// For example:
///
/// ```dart
///  RxSingleStateSelector<CounterBloc3, int>(
///   stateRebuildSelector: (state) {
///     return state.num2;
///   }, builder: (context, value) {
///       debugPrint("build num2");
///       return Text("state num2: $value");
///   }),
/// ```
/// ... the builder function will only be executed and a new widget is built
/// when [state.text] changed between state.
///
/// Work with:
/// * [RxSingleStateBloc]
class RxSingleStateSelector<B extends RxSingleStateBloc, T>
    extends StatefulWidget {
  const RxSingleStateSelector({
    Key? key,
    required this.stateRebuildSelector,
    required this.builder,
  }) : super(key: key);

  final StateRebuildSelector<B, T> stateRebuildSelector;
  final RxBlocWidgetBuilder<T> builder;

  @override
  State<RxSingleStateSelector<B, T>> createState() =>
      _RxSingleStateSelectorState<B, T>();
}

class _RxSingleStateSelectorState<B extends RxSingleStateBloc, T>
    extends State<RxSingleStateSelector<B, T>> {
  Widget? _cachedWidget;
  T? _cachedValue;
  late T _value;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.watch<B>().state as B;
    _value = widget.stateRebuildSelector(state);
  }

  @override
  Widget build(BuildContext context) {
    if (_cachedValue == null || _cachedValue != _value) {
      _cachedWidget = widget.builder(context, _value);
      _cachedValue = _value;
    }
    return _cachedWidget!;
  }
}
