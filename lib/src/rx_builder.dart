import 'package:flutter/material.dart';

import 'rx_bloc.dart';
import 'rx_provider.dart';
import 'type_def.dart';

/// Builder function to subscribe for changes of specific Bloc of type [B]
/// like [RxBloc], [RxCubit] with state [S]
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
class RxBuilder<B extends RxCubit<S>, S> extends StatefulWidget {
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

class _RxBuilderState<B extends RxCubit<S>, S> extends State<RxBuilder<B, S>> {
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
/// like [RxViewModel]
///
/// * [RxBlocWidgetBuilder] for widget building operation.
/// Which will only be called when a new state is emitted and
/// [ShouldRebuildViewModel] is true (or not specified)
///
/// ```dart
///  RxViewModelBuilder<CounterBloc3>(
///      builder: (context, state) {
///          debugPrint("build Number 3");
///          return Text('counter bloc 3:  ${state.num}');
///      },
///      shouldRebuildWidget: (state) {
///          return state.num < 20;
///      },
///  ),
/// ```
class RxViewModelBuilder<B extends RxViewModel> extends StatefulWidget {
  const RxViewModelBuilder({
    Key? key,
    required this.builder,
    this.shouldRebuildWidget,
  }) : super(key: key);

  /// Typical Builder function, which called when the bloc this widget depend
  /// on require its to rebuild itself with new value.
  final RxBlocWidgetBuilder<B> builder;

  /// Function to determine whether this widget should rebuild itself when state
  /// changed.
  final ShouldRebuildViewModel<B>? shouldRebuildWidget;

  @override
  State<RxViewModelBuilder<B>> createState() => _RxViewModelBuilderState<B>();
}

class _RxViewModelBuilderState<B extends RxViewModel>
    extends State<RxViewModelBuilder<B>> {
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
