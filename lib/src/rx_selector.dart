import 'package:flutter/material.dart';
import 'rx_bloc.dart';
import 'rx_provider.dart';
import 'type_def.dart';

/// Widget for selectively rebuild ui base on a property of the whole state [S].
///
/// Base Widget for [RxSelector] and [RxSingleStateSelector].
class RxSelectorBase<B extends RxBlocBase, S, T> extends StatefulWidget {
  const RxSelectorBase({
    Key? key,
    required this.stateRebuildSelector,
    required this.builder,
  }) : super(key: key);

  /// Function to select the property for rebuilding decision, only when  the
  /// property changed between states, would the ui rebuild.
  final StateRebuildSelector<S, T> stateRebuildSelector;

  /// Typical builder function, return a widget.
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

/// Widget for selectively rebuild ui base on a property [T] of the whole
/// state [S].
///
/// For example:
///
/// ```dart
/// RxSelector<CounterBloc, MyState, String>(
///   stateRebuildSelector: (state) {
///     return state.text;
///   }, builder: (context, state) {
///     debugPrint("build Text");
///     return Text("state text: ${state.text}");
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
    required RxBlocWidgetBuilder<S> builder,
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
///   }, builder: (context, state) {
///       debugPrint("build num2");
///       return Text("state num2: ${state.num2}");
///   }),
/// ```
/// ... the builder function will only be executed and a new widget is built
/// when [state.text] changed between state.
///
/// Work with:
/// * [RxSingleStateBloc]
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
