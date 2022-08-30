import 'package:flutter/material.dart';

import 'rx_bloc.dart';
import 'rx_provider.dart';
import 'type_def.dart';

/// Base class for [RxBuilder] and [RxSingleStateBuilder], which value
/// is built around generic type, thus is flexible to be base of the two.
/// The generic types in this case is [B] for the type of bloc and [S] for
/// state.
class RxBuilderBase<B extends RxBlocBase, S> extends StatefulWidget {
  const RxBuilderBase({
    Key? key,
    required this.builder,
    this.shouldRebuildWidget,
    this.shouldRebuildSingleState,
  })  : assert(shouldRebuildWidget == null || shouldRebuildSingleState == null),
        super(key: key);

  /// Typical Builder function, which called when the bloc this widget depend
  /// on require its to rebuild itself with new value.
  final RxBlocWidgetBuilder<S> builder;

  /// Function to determine whether this widget should rebuild itself when state
  /// changed.
  final ShouldRebuildWidget<S>? shouldRebuildWidget;

  /// Function to determine whether this widget should rebuild itself when state
  /// changed.
  final ShouldRebuildSingleState<S>? shouldRebuildSingleState;

  @override
  State<RxBuilderBase<B, S>> createState() => _RxBuilderBaseState<B, S>();
}

class _RxBuilderBaseState<B extends RxBlocBase, S>
    extends State<RxBuilderBase<B, S>> {
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
class RxBuilder<B extends RxSilentBloc<S>, S> extends RxBuilderBase<B, S> {
  const RxBuilder({
    Key? key,
    required RxBlocWidgetBuilder<S> builder,
    ShouldRebuildWidget<S>? shouldRebuildWidget,
  }) : super(
            key: key,
            builder: builder,
            shouldRebuildWidget: shouldRebuildWidget);
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
class RxSingleStateBuilder<B extends RxSingleStateBloc>
    extends RxBuilderBase<B, B> {
  const RxSingleStateBuilder({
    Key? key,
    required RxBlocWidgetBuilder<B> builder,
    ShouldRebuildSingleState? shouldRebuildWidget,
  }) : super(
            key: key,
            builder: builder,
            shouldRebuildSingleState: shouldRebuildWidget);
}
