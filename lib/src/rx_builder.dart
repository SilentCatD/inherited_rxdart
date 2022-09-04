import 'package:flutter/material.dart';

import 'rx_bloc.dart';
import 'rx_provider.dart';
import 'type_def.dart';

/// Builder function to subscribe for changes of specific Bloc of type [B]
/// like [RxBloc], [RxSilentBloc] with state [S]
///
/// * [RxBlocWidgetBuilder] for widget building operation, which will only
/// be called when a new state is emitted and [ShouldRebuildWidget] is true
/// (or not specified)
///
/// ```dart
///   RxBuilder<CounterBloc, MyState>(
///     builder: (context, state) {
///       debugPrint("build Number 1");
///         return Text('counter bloc 1:  ${state.number}');
///       },
///       shouldRebuildWidget: (prev, curr) {
///         return prev.number != curr.number;
///       },
///   ),
/// ```
class RxBuilder<B extends RxSilentBloc<S>, S> extends StatefulWidget {
  const RxBuilder({
    Key? key,
    required this.builder,
    this.shouldRebuildWidget,
  }) : super(key: key);

  /// Typical Builder function, which called when the bloc this widget depend
  /// on require its to rebuild itself with new value.
  final RxBlocWidgetBuilder<S> builder;

  /// Function to determine whether this widget should rebuild itself when state
  /// changed.
  final ShouldRebuildWidget<S>? shouldRebuildWidget;

  @override
  State<RxBuilder<B, S>> createState() => _RxBuilderState<B, S>();
}

class _RxBuilderState<B extends RxSilentBloc<S>, S>
    extends State<RxBuilder<B, S>> {
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
    if (_cachedWidget == null ||
        (widget.shouldRebuildWidget?.call(_cachedState as S, _state) ?? true)) {
      _cachedWidget = widget.builder(context, _state);
      _cachedState = _state;
    }
    return _cachedWidget!;
  }
}

/// Builder function to subscribe for changes of specific Bloc of type [B]
/// like [RxSingleStateBloc]
///
/// * [RxBlocWidgetBuilder] for widget building operation.
/// Which will only be called when a new state is emitted and
/// [ShouldRebuildSingleState] is true (or not specified)
///
/// ```dart
///  RxSingleStateBuilder<CounterBloc3>(
///      builder: (context, state) {
///          debugPrint("build Number 3");
///          return Text('counter bloc 3:  ${state.num}');
///      },
///      shouldRebuildWidget: (state) {
///          return state.num < 20;
///      },
///  ),
/// ```
class RxSingleStateBuilder<B extends RxSingleStateBloc> extends StatefulWidget {
  const RxSingleStateBuilder({
    Key? key,
    required this.builder,
    this.shouldRebuildWidget,
  }) : super(key: key);

  /// Typical Builder function, which called when the bloc this widget depend
  /// on require its to rebuild itself with new value.
  final RxBlocWidgetBuilder<B> builder;

  /// Function to determine whether this widget should rebuild itself when state
  /// changed.
  final ShouldRebuildSingleState<B>? shouldRebuildWidget;

  @override
  State<RxSingleStateBuilder<B>> createState() =>
      _RxSingleStateBuilderState<B>();
}

class _RxSingleStateBuilderState<B extends RxSingleStateBloc>
    extends State<RxSingleStateBuilder<B>> {
  Widget? _cachedWidget;
  late B _state;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _state = context.watch<B>().state as B;
  }

  @override
  Widget build(BuildContext context) {
    if (_cachedWidget == null ||
        (widget.shouldRebuildWidget?.call(_state) ?? true)) {
      _cachedWidget = widget.builder(context, _state);
    }
    return _cachedWidget!;
  }
}
