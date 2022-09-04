import 'dart:async';

import 'package:flutter/material.dart';

import 'rx_bloc.dart';
import 'rx_provider.dart';
import 'type_def.dart';

/// Base class for other bloc listener
///
/// Will execute callback when a new state of type [S] is emitted from the bloc
/// of type [B].
abstract class RxListenerBase<B extends RxBlocBase<S>, S>
    extends StatefulWidget {
  const RxListenerBase({Key? key, required this.child, this.stateCallback})
      : super(key: key);

  /// This widget require a child, which will not be affected by these callback
  final Widget child;
  final RxBlocEventListener<S>? stateCallback;

  @override
  State<RxListenerBase<B, S>> createState() => _RxListenerBaseState<B, S>();
}

class _RxListenerBaseState<B extends RxBlocBase<S>, S>
    extends State<RxListenerBase<B, S>> {
  late B _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<B>();
    _sub();
  }

  StreamSubscription<S>? _stateSubscription;

  void _sub() {
    _stateSubscription = _bloc.stateStream.listen((state) {
      if (!mounted) return;
      widget.stateCallback?.call(context, state);
    });
  }

  void _unSub() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
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
/// * [RxSilentBloc]
///
/// Does not work with:
/// * [RxSingleStateBloc]
class RxStateListener<B extends RxSilentBloc<S>, S>
    extends RxListenerBase<B, S> {
  const RxStateListener(
      {Key? key, required Widget child, RxBlocEventListener<S>? stateCallback})
      : super(key: key, stateCallback: stateCallback, child: child);
}

/// Listener for listening state changes for [RxSingleStateBloc]
///
/// Will execute [stateCallback] when a new state of type [S] is emitted from
/// the bloc of type [B].
///
/// Work only with:
/// * [RxSingleStateBloc]
class RxSingleStateListener<B extends RxSingleStateBloc>
    extends StatefulWidget {
  const RxSingleStateListener(
      {Key? key, required this.child, this.stateCallback})
      : super(key: key);

  final Widget child;
  final RxBlocEventListener<B>? stateCallback;

  @override
  State<RxSingleStateListener<B>> createState() =>
      _RxSingleStateListenerState<B>();
}

class _RxSingleStateListenerState<B extends RxSingleStateBloc>
    extends State<RxSingleStateListener<B>> {
  late B _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<B>();
    _sub();
  }

  StreamSubscription<RxSingleStateBloc>? _stateSubscription;

  void _sub() {
    _stateSubscription = _bloc.stateStream.listen((state) {
      if (!mounted) return;
      widget.stateCallback?.call(context, state as B);
    });
  }

  void _unSub() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
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
  const RxListener(
      {Key? key,
      required Widget child,
      RxBlocEventListener<S>? stateCallback,
      this.notificationCallback})
      : super(key: key, stateCallback: stateCallback, child: child);
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
  void _sub() {
    super._sub();
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
