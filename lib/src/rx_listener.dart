import 'dart:async';

import 'package:flutter/material.dart';

import 'rx_bloc.dart';
import 'rx_provider.dart';
import 'type_def.dart';

class RxListener<B extends RxBloc, E> extends StatefulWidget {
  const RxListener({
    Key? key,
    required this.listener,
    required this.child,
  }) : super(key: key);
  final RxBlocEventListener<E> listener;
  final Widget child;

  @override
  State<RxListener<B, E>> createState() => _RxListenerState<B, E>();
}

class _RxListenerState<B extends RxBloc, E> extends State<RxListener<B, E>> {
  StreamSubscription<E>? _subscription;
  late B _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<B>();
    assert(_bloc is EventDispatcher<E>);
    _sub();
  }

  void _sub() {
    _subscription =
        (_bloc as EventDispatcher<E>).notificationStream.listen((event) {
      if (!mounted) return;
      widget.listener(context, event);
    });
  }

  void _unSub() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    _unSub();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
