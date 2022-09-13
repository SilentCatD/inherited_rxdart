import 'dart:async';

import 'package:flutter/material.dart';
import 'exception.dart';
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
  /// Default constructor, will automatically lookup for RxCubit of type [B].
  const RxBuilder({
    Key? key,
    required this.builder,
    this.shouldRebuildWidget,
  })  : _value = null,
        _fromValue = false,
        super(key: key);

  /// Value constructor, take a concrete instance of RxCubit.
  const RxBuilder.value({
    Key? key,
    required this.builder,
    this.shouldRebuildWidget,
    required B value,
  })  : _value = value,
        _fromValue = true,
        super(key: key);
  final bool _fromValue;
  final B? _value;

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
  B? _bloc;
  late final bool _fromValue;

  StreamSubscription<S>? _subscription;

  void _sub(B bloc) {
    _subscription = bloc.stateStream.listen((event) {
      _handleUpdate(event);
    });
  }

  void _unSub() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _handleUpdate(S state) {
    if (!mounted) return;
    setState(() {
      _state = state;
    });
  }

  @override
  void initState() {
    super.initState();
    _fromValue = widget._fromValue;
    if (_fromValue) {
      _bloc = widget._value;
      _state = _bloc!.state;
      _sub(_bloc!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fromValue) {
      _state = context.watch<B>().state;
    }
  }

  @override
  void didUpdateWidget(covariant RxBuilder<B, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((_fromValue && !widget._fromValue) ||
        (!_fromValue && widget._fromValue)) {
      throw RxMapError();
    }
    if (_fromValue) {
      if (oldWidget._value != widget._value) {
        if (_subscription != null) {
          _unSub();
        }
        _bloc = widget._value;
        _sub(_bloc!);
      }
    }
  }

  @override
  void dispose() {
    _unSub();
    super.dispose();
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

/// Builder widget to subscribe for changes of specific ViewModel of type [B]
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
  /// Default constructor, will automatically lookup for [RxViewModelBuilder] of
  /// type [B].
  const RxViewModelBuilder({
    Key? key,
    required this.builder,
    this.shouldRebuildWidget,
  })  : _fromValue = false,
        _value = null,
        super(key: key);

  /// Value constructor, take a concrete instance of RxViewModel.
  const RxViewModelBuilder.value({
    Key? key,
    required this.builder,
    this.shouldRebuildWidget,
    required B value,
  })  : _fromValue = true,
        _value = value,
        super(key: key);
  final bool _fromValue;
  final B? _value;

  /// Typical Builder function, which called when the ViewModel this widget
  /// depend on require it to rebuild itself with new value.
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
  late final bool _fromValue;

  StreamSubscription<RxViewModel>? _subscription;

  void _sub(B viewModel) {
    _subscription = viewModel.stateStream.listen((event) {
      _handleUpdate(event as B);
    });
  }

  void _unSub() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _handleUpdate(B viewModel) {
    if (!mounted) return;
    setState(() {
      _state = viewModel;
    });
  }

  @override
  void initState() {
    super.initState();
    _fromValue = widget._fromValue;
    if (_fromValue) {
      _state = widget._value!;
      _sub(_state);
    }
  }

  @override
  void didUpdateWidget(covariant RxViewModelBuilder<B> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((_fromValue && !widget._fromValue) ||
        (!_fromValue && widget._fromValue)) {
      throw RxMapError();
    }
    if (_fromValue) {
      if (oldWidget._value != widget._value) {
        if (_subscription != null) {
          _unSub();
        }
        _state = widget._value!;
        _sub(_state);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fromValue) {
      _state = context.watch<B>().state as B;
    }
  }

  @override
  void dispose() {
    _unSub();
    super.dispose();
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

/// Widget to work with [RxValue].
///
/// Take an [RxValue] and rebuild when the value emitted changed.
/// ```dart
/// RxValueBuilder(
///   value: context.read<MyModel>().number,
///   // builder function will be called each time the value is set.
///   builder: (context, value){
///     return ElevatedButton(
///       onPressed: (){
///         myViewModel.increase();
///       }
///       child: Text("$value"),
///     );
///   }
/// ),
/// ```
class RxValueBuilder<T> extends StatefulWidget {
  const RxValueBuilder({
    Key? key,
    required this.value,
    required this.builder,
  }) : super(key: key);

  /// Function called when rebuilding widget.
  final RxBlocWidgetBuilder<T> builder;

  /// Reactive value that will cause this widget to be rebuilt when changed.
  final RxValue<T> value;

  @override
  State<RxValueBuilder<T>> createState() => _RxValueBuilderState<T>();
}

class _RxValueBuilderState<T> extends State<RxValueBuilder<T>> {
  StreamSubscription<T>? _subscription;
  late RxValue<T> _rxValue;
  late T _value;
  T? _oldValue;
  Widget? _cached;

  void _sub(RxValue<T> value) {
    _subscription = value.stateStream.listen((event) {
      _handleUpdate(event);
    });
  }

  void _handleUpdate(T value) {
    if (!mounted) return;
    setState(() {
      _value = value;
    });
  }

  void _unSub() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void initState() {
    super.initState();
    _rxValue = widget.value;
    _sub(_rxValue);
    _value = _rxValue.value;
  }

  @override
  void didUpdateWidget(covariant RxValueBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (_subscription != null) {
        _unSub();
      }
      _rxValue = widget.value;
      _sub(_rxValue);
    }
  }

  @override
  void dispose() {
    _unSub();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cached == null || _oldValue != _value) {
      _cached = widget.builder(context, _value);
      _oldValue = _value;
    }
    return _cached!;
  }
}
