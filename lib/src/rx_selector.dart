import 'dart:async';

import 'package:flutter/material.dart';
import 'exception.dart';
import 'rx_provider.dart';
import 'type_def.dart';

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
/// * [RxCubit]
/// * [RxBloc]
class RxSelector<B extends RxCubit<S>, S, T> extends StatefulWidget {
  /// Default constructor, will automatically lookup for RxCubit of type [B].
  const RxSelector({
    Key? key,
    required this.builder,
    required this.stateRebuildSelector,
  })  : _fromValue = false,
        _value = null,
        super(key: key);

  /// Value constructor, take a concrete instance of RxCubit.
  const RxSelector.value({
    Key? key,
    required B value,
    required this.builder,
    required this.stateRebuildSelector,
  })  : _fromValue = true,
        _value = value,
        super(key: key);

  final bool _fromValue;
  final B? _value;

  /// Function to select the property for rebuilding decision, only when  the
  /// property changed between states, would the ui rebuild.
  final StateRebuildSelector<S, T> stateRebuildSelector;

  /// Typical builder function, return a widget.
  final RxBlocWidgetBuilder<T> builder;

  @override
  State<RxSelector<B, S, T>> createState() => _RxSelectorState<B, S, T>();
}

class _RxSelectorState<B extends RxCubit<S>, S, T>
    extends State<RxSelector<B, S, T>> {
  late T _value;
  late final bool _fromValue;
  late B _bloc;

  StreamSubscription<S>? _subscription;

  void _sub(B bloc) {
    _subscription = bloc.stateStream.listen((event) {
      _handleUpdate(widget.stateRebuildSelector(event));
    });
  }

  void _unSub() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _handleUpdate(T value) {
    if (!mounted) return;
    if (value != _value) {
      setState(() {
        _value = value;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fromValue = widget._fromValue;
    if (_fromValue) {
      _bloc = widget._value!;
    } else {
      _bloc = context.watch<B>();
    }
    _value = widget.stateRebuildSelector(_bloc.state);
    _sub(_bloc);
  }

  @override
  void didUpdateWidget(covariant RxSelector<B, S, T> oldWidget) {
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
        _bloc = widget._value!;
        _sub(_bloc);
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
    return widget.builder(context, _value);
  }
}

/// Widget for selectively rebuild ui base on value of type [T] emitted by bloc
/// [B], with B is a subtype of [RxViewModel].
///
/// For example:
///
/// ```dart
///  RxViewModelSelector<CounterBloc3, int>(
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
/// * [RxViewModel]
class RxViewModelSelector<B extends RxViewModel, T> extends StatefulWidget {
  /// Default constructor, will automatically lookup for RxViewModel of type [B].
  const RxViewModelSelector({
    Key? key,
    required this.stateRebuildSelector,
    required this.builder,
  })  : _value = null,
        _fromValue = false,
        super(key: key);

  /// Value constructor, take a concrete instance of RxViewModel.
  const RxViewModelSelector.value({
    Key? key,
    required B value,
    required this.stateRebuildSelector,
    required this.builder,
  })  : _value = value,
        _fromValue = true,
        super(key: key);

  final B? _value;
  final bool _fromValue;

  final StateRebuildSelector<B, T> stateRebuildSelector;
  final RxBlocWidgetBuilder<T> builder;

  @override
  State<RxViewModelSelector<B, T>> createState() =>
      _RxViewModelSelectorState<B, T>();
}

class _RxViewModelSelectorState<B extends RxViewModel, T>
    extends State<RxViewModelSelector<B, T>> {
  late T _value;
  late final bool _fromValue;
  late B _viewModel;
  StreamSubscription<RxViewModel>? _subscription;

  void _sub(B bloc) {
    _subscription = bloc.stateStream.listen((event) {
      _handleUpdate(widget.stateRebuildSelector(event as B));
    });
  }

  void _unSub() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _handleUpdate(T value) {
    if (!mounted) return;
    if (_value != value) {
      setState(() {
        _value = value;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fromValue = widget._fromValue;
    if (_fromValue) {
      _viewModel = widget._value!;
    } else {
      _viewModel = context.read<B>();
    }
    _value = widget.stateRebuildSelector(_viewModel);
    _sub(_viewModel);
  }

  @override
  void didUpdateWidget(covariant RxViewModelSelector<B, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((_fromValue && !widget._fromValue) ||
        (!_fromValue && widget._fromValue)) {
      throw RxMapError();
    }
    if (_fromValue) {
      if (widget._value != oldWidget._value) {
        if (_subscription != null) {
          _unSub();
        }
        _viewModel = widget._value!;
        _sub(_viewModel);
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
    return widget.builder(context, _value);
  }
}
