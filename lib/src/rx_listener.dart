import 'dart:async';

import 'package:flutter/material.dart';

import 'exception.dart';
import 'rx_bloc.dart';
import 'rx_provider.dart';
import 'type_def.dart';

/// Base class for other bloc listener
///
/// Will execute callback when a new state of type [S] is emitted from the bloc
/// of type [B].
abstract class RxListenerBase<B extends RxBase<S>, S> extends StatefulWidget {
  /// Default constructor, will automatically lookup for RxBase of type [B].
  const RxListenerBase({Key? key, required this.child, this.stateCallback})
      : _value = null,
        _fromValue = false,
        super(key: key);

  /// Value constructor, take a concrete instance of RxBase.
  const RxListenerBase.value(
      {Key? key, required this.child, this.stateCallback, required B value})
      : _value = value,
        _fromValue = true,
        super(key: key);

  /// This widget require a child, which will not be affected by these callback
  final Widget child;
  final RxBlocEventListener<S>? stateCallback;
  final B? _value;
  final bool _fromValue;

  @override
  State<RxListenerBase<B, S>> createState() => _RxListenerBaseState<B, S>();
}

class _RxListenerBaseState<B extends RxBase<S>, S>
    extends State<RxListenerBase<B, S>> {
  late B _bloc;
  late final bool _fromValue;

  StreamSubscription<S>? _stateSubscription;

  void _sub(B bloc) {
    _stateSubscription = bloc.stateStream.listen((state) {
      if (!mounted) return;
      widget.stateCallback?.call(context, state);
    });
  }

  void _unSub() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
  }

  @override
  void initState() {
    super.initState();
    _fromValue = widget._fromValue;
    if (_fromValue) {
      _bloc = widget._value!;
    } else {
      _bloc = context.read<B>();
    }
    _sub(_bloc);
  }

  @override
  void didUpdateWidget(covariant RxListenerBase<B, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((_fromValue && !widget._fromValue) ||
        (!_fromValue && widget._fromValue)) {
      throw RxMapError();
    }
    if (_fromValue) {
      if (oldWidget._value != widget._value) {
        if (_stateSubscription != null) {
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
    return super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Listener for listening state changes.
///
/// Work with:
/// * [RxBloc]
/// * [RxCubit]
///
/// Does not work with:
/// * [RxViewModel]
class RxStateListener<B extends RxCubit<S>, S> extends RxListenerBase<B, S> {
  /// Default constructor, will automatically lookup for RxCubit of type [B].
  const RxStateListener(
      {Key? key, required Widget child, RxBlocEventListener<S>? stateCallback})
      : super(key: key, stateCallback: stateCallback, child: child);

  /// Value constructor, take a concrete instance of RxCubit.
  const RxStateListener.value(
      {Key? key,
      required Widget child,
      RxBlocEventListener<S>? stateCallback,
      required B value})
      : super.value(
          key: key,
          stateCallback: stateCallback,
          child: child,
          value: value,
        );
}

/// Listener for listening state changes for [RxViewModel]
///
/// Will execute [stateCallback] when a new state of type [S] is emitted from
/// the view model of type [B].
///
/// Work only with:
/// * [RxViewModel]
class RxViewModelListener<B extends RxViewModel> extends StatefulWidget {
  /// Default constructor, will automatically lookup for RxViewModel of type [B].
  const RxViewModelListener({Key? key, required this.child, this.stateCallback})
      : _value = null,
        _fromValue = false,
        super(key: key);

  /// Value constructor, take a concrete instance of RxViewModel.
  const RxViewModelListener.value(
      {Key? key, required this.child, this.stateCallback, required B value})
      : _value = value,
        _fromValue = true,
        super(key: key);

  final Widget child;
  final RxBlocEventListener<B>? stateCallback;
  final B? _value;
  final bool _fromValue;

  @override
  State<RxViewModelListener<B>> createState() => _RxViewModelListenerState<B>();
}

class _RxViewModelListenerState<B extends RxViewModel>
    extends State<RxViewModelListener<B>> {
  late B _bloc;

  late final bool _fromValue;

  StreamSubscription<RxViewModel>? _stateSubscription;

  void _sub(B bloc) {
    _stateSubscription = bloc.stateStream.listen((state) {
      if (!mounted) return;
      widget.stateCallback?.call(context, state as B);
    });
  }

  void _unSub() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
  }

  @override
  void initState() {
    super.initState();
    _fromValue = widget._fromValue;
    if (_fromValue) {
      _bloc = widget._value!;
    } else {
      _bloc = context.read<B>();
    }
    _sub(_bloc);
  }

  @override
  void didUpdateWidget(covariant RxViewModelListener<B> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((_fromValue && !widget._fromValue) ||
        (!_fromValue && widget._fromValue)) {
      throw RxMapError();
    }
    if (_fromValue) {
      if (oldWidget._value != widget._value) {
        if (_stateSubscription != null) {
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
    return super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Listener for listening state [S] changes and notification [N] for
/// [RxBloc].
///
/// Callback will be called accordingly. When a state [S] is emitted,
/// [stateCallback] will be called, and when a notification [N] is fired,
/// [notificationCallback] will be called.
///
/// Work only with:
/// * [RxBloc]
///
/// ```dart
///    RxListener<CounterBloc, MyState, String>(
///       notificationCallback: (context, notification) {
///         if (notification == "showDialog") {
///           showDialog(
///               context: context,
///               builder: (context) {
///                 return const Dialog(
///                   child: Text("This is a dialog"),
///                 );
///               });
///         }
///       },
///       stateCallback: (context, state) {
///         debugPrint("this is stateCallback");
///       },
///       child: Scaffold(
///         appBar: AppBar(),
///         body: Center(
///           child: Column(
///             mainAxisSize: MainAxisSize.min,
///             mainAxisAlignment: MainAxisAlignment.center,
///             children: [
///               RxBuilder<CounterBloc, MyState>(builder: (context, state) {
///                 debugPrint("build BlocBuilder 2 ");
///                 return Text(state.number.toString());
///               }),
///               ElevatedButton(
///                   onPressed: () {
///                     RxProvider.of<CounterBloc>(context, listen: false)
///                         .showDialog();
///                   },
///                   child: const Text("show notification")),
///             ],
///           ),
///         ),
///       ),
///     );
/// ```
class RxListener<B extends RxBloc<S, N>, S, N> extends RxListenerBase<B, S> {
  /// Default constructor, will automatically lookup for RxBloc of type [B].
  const RxListener(
      {Key? key,
      required Widget child,
      RxBlocEventListener<S>? stateCallback,
      this.notificationCallback})
      : super(key: key, stateCallback: stateCallback, child: child);

  /// Value constructor, take a concrete instance of RxBloc.
  const RxListener.value(
      {Key? key,
      required B value,
      required Widget child,
      RxBlocEventListener<S>? stateCallback,
      this.notificationCallback})
      : super.value(
            key: key, stateCallback: stateCallback, child: child, value: value);
  final RxBlocEventListener<N>? notificationCallback;

  @override
  _RxBlocListenerState<B, S, N> createState() =>
      _RxBlocListenerState<B, S, N>();
}

class _RxBlocListenerState<B extends RxBloc<S, N>, S, N>
    extends _RxListenerBaseState<B, S> {
  StreamSubscription<N>? _notificationSubscription;

  @override
  RxListener<B, S, N> get widget => super.widget as RxListener<B, S, N>;

  @override
  void _sub(B bloc) {
    super._sub(bloc);
    _notificationSubscription = _bloc.notificationStream.listen((notification) {
      if (!mounted) return;
      widget.notificationCallback?.call(context, notification);
    });
  }

  @override
  void _unSub() {
    super._unSub();
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
  }
}
