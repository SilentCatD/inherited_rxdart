import 'dart:async';

import 'package:flutter/material.dart';

import 'rx_bloc.dart';
import 'rx_provider.dart';
import 'type_def.dart';

abstract class RxListenerBase<B extends RxBlocBase, S> extends StatefulWidget {
  const RxListenerBase({Key? key, required this.child, this.stateCallback})
      : super(key: key);

  final Widget child;
  final RxBlocEventListener<S>? stateCallback;
}

class RxStateListener<B extends RxSilentBloc<S>, S>
    extends RxListenerBase<B, S> {
  const RxStateListener(
      {Key? key, required Widget child, RxBlocEventListener<S>? stateCallback})
      : super(key: key, stateCallback: stateCallback, child: child);

  @override
  State<RxStateListener<B, S>> createState() {
    return _RxListenerBaseState<RxStateListener<B, S>, B, S>();
  }
}

class RxSingleStateListener<B extends RxSingleStateBloc<B>>
    extends RxListenerBase<B, B> {
  const RxSingleStateListener(
      {Key? key, required Widget child, RxBlocEventListener<B>? stateCallback})
      : super(key: key, stateCallback: stateCallback, child: child);

  @override
  State<RxSingleStateListener<B>> createState() {
    return _RxListenerBaseState<RxSingleStateListener<B>, B, B>();
  }
}

class _RxListenerBaseState<T extends RxListenerBase<B, S>, B extends RxBlocBase,
    S> extends State<T> {
  late B _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<B>();
    _sub();
  }

  StreamSubscription<S>? _stateSubscription;

  void _sub() {
    _stateSubscription = (_bloc as RxBlocBase<S>).stateStream.listen((state) {
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

class RxBlocListener<B extends RxBloc<S, N>, S, N>
    extends RxListenerBase<B, S> {
  const RxBlocListener(
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
    extends _RxListenerBaseState<RxBlocListener<B, S, N>, B, S> {
  StreamSubscription<N>? _notificationSubscription;

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
