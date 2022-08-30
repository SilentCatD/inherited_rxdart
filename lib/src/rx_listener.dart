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
class RxListener<B extends RxBloc<S, N>, S, N> extends StatefulWidget {
  const RxListener({
    Key? key,
    this.notificationCallback,
    this.stateCallback,
    required this.child,
  }) : super(key: key);

  /// Callback for notification emitted from [RxBloc]
  final RxBlocEventListener<N>? notificationCallback;

  /// Callback for state emitted from [RxBloc]
  final RxBlocEventListener<S>? stateCallback;

  /// Child widget of this [RxListener]
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
