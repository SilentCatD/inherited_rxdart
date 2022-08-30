import 'dart:async';

import 'package:flutter/material.dart';

import 'rx_bloc.dart';
import 'rx_provider.dart';
import 'type_def.dart';

/// Listener widget for bloc [B] of type [RxBloc], state of type [S] and
/// notification of type [N] which can listen state, notification, but will not
/// rebuild your widget.
/// Suitable for [showDialog] and handling [Navigator.push]
///
/// ```dart
///  RxListener<CounterBloc, MyState, String>(
///       notificationCallback: (context, state) {
///         if (state == "showDialog") {
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
class RxBlocNotificationListener<B extends RxBloc<S, N>, S, N>
    extends RxBlocStateListener<B, S> {
  const RxBlocNotificationListener({
    Key? key,
    RxBlocEventListener<S>? stateCallback,
    this.notificationCallback,
    required Widget child,
  }) : super(key: key, stateCallback: stateCallback, child: child);

  /// Callback for notification emitted from [RxBloc]
  final RxBlocEventListener<N>? notificationCallback;

  @override
  _RxBlocNotificationListenerState<B, S, N> createState() =>
      _RxBlocNotificationListenerState<B, S, N>();
}

class _RxBlocNotificationListenerState<B extends RxBloc<S, N>, S, N>
    extends _RxBlocStateListenerState<B, S> {
  StreamSubscription<N>? _notificationSubscription;

  @override
  void _sub() {
    super._sub();
    _notificationSubscription = _bloc.notificationStream.listen((notification) {
      if (!mounted) return;
      widget.notificationCallback?.call(context, notification);
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

class RxBlocStateListener<B extends RxBlocBase<S>, S> extends StatefulWidget {
  const RxBlocStateListener({Key? key, required this.child, this.stateCallback})
      : super(key: key);

  final RxBlocEventListener<S>? stateCallback;

  final Widget child;

  @override
  State<RxBlocStateListener<B, S>> createState() =>
      _RxBlocStateListenerState<B, S>();
}

class _RxBlocStateListenerState<B extends RxBlocBase<S>, S>
    extends State<RxBlocStateListener<B, S>> {
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
