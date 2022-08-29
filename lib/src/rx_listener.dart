import 'dart:async';

import 'package:flutter/material.dart';

import 'rx_bloc.dart';
import 'rx_provider.dart';
import 'type_def.dart';

class RxListener<B extends RxBloc<S, N>, S, N> extends StatefulWidget {
  const RxListener({
    Key? key,
    this.notificationCallback,
    this.stateCallback,
    required this.child,
  }) : super(key: key);
  final RxBlocEventListener<N>? notificationCallback;
  final RxBlocEventListener<S>? stateCallback;

  final Widget child;

  @override
  State<RxListener<B, S, N>> createState() => _RxListenerState<B, S, N>();
}

class _RxListenerState<B extends RxBloc<S, N>, S, N>
    extends State<RxListener<B, S, N>> {
  StreamSubscription<N>? _notificationSubscription;
  StreamSubscription<S>? _stateSubscription;
  late B _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<B>();
    _sub();
  }

  void _sub() {
    _notificationSubscription = _bloc.notificationStream.listen((notification) {
      if (!mounted) return;
      widget.notificationCallback?.call(context, notification);
    });
    _stateSubscription = _bloc.stateStream.listen((state) {
      if (!mounted) return;
      widget.stateCallback?.call(context, state);
    });
  }

  void _unSub() {
    _notificationSubscription?.cancel();
    _stateSubscription?.cancel();
    _notificationSubscription = null;
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
