import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'exception.dart';
import 'rx_bloc.dart';
import 'type_def.dart';

/// Widget to provide a bloc of type [B] to a subtree.
///
/// The default constructor indicate the creation of above mentioned bloc [B]
/// through [Create]. However, in case the reuse of existed bloc is required,
/// [RxProvider.value] should be used instead.
///
/// If the default constructor is used, created bloc's [RxBase.init] and
/// [RxBase.dispose] are called automatically. In case of reusing existed
/// bloc, life cycle of this bloc must be handled by the implementer.
///
/// ```dart
/// RxProvider<CounterBloc3>(
///     create: () => CounterBloc3(10),
///     child: const MyHomePage(),
/// ),
/// ```
///
/// The [RxProvider.value] is useful when you need to provide an existed bloc
/// to another screen.
///
/// ```dart
/// Navigator.of(context).push(MaterialPageRoute(builder: (_) {
///     return RxProvider.value(
///         value:
///            RxProvider.of<CounterBloc>(context, listen: false),
///         child: const MyNested());
/// }));
/// ```
/// If multiple bloc are to be provided at once, consider [RxMultiProvider] to
/// avoid deeply nested [RxProvider] widgets.
class RxProvider<B extends RxBase> extends SingleChildStatefulWidget {
  const RxProvider({
    Key? key,
    required Create<B> create,
    Widget? child,
  })  : _isCreated = true,
        _create = create,
        _bloc = null,
        super(key: key, child: child);

  const RxProvider.value({
    Key? key,
    required B value,
    Widget? child,
  })  : _bloc = value,
        _isCreated = false,
        _create = null,
        super(key: key, child: child);

  final B? _bloc;
  final bool _isCreated;
  final Create<B>? _create;

  /// Method to locate and get the provided bloc of this subtree.
  ///
  /// Type [T] is required to be a subtype of [RxBase] and must be specified
  /// Failing to so will throw [RxBlocMustBeOfSpecificTypeException], and
  /// failing to find a bloc of specified type will thrown
  /// [RxBlocNotProvidedException].
  ///
  /// The parameter listen will determine whether to subscribe to the bloc [T]
  /// when it emit new states or just simple get instance of the bloc.
  ///
  /// In many case, subscribing the whole [BuildContext] to a bloc changes is
  /// unnecessary, doing so will cause this whole widget with associated
  /// [BuildContext] to rebuild each time a new state emitted. So always
  /// consider to specified this parameter to false instead.
  ///
  /// Consider [RxContext.watch] or [RxContext.read] for a short-hand way to
  /// call this function.
  ///
  /// Do notice that the use of:
  ///
  /// ```dart
  ///  RxProvider.of<CounterBloc>(context, listen: false);
  /// ```
  /// or
  ///
  /// ```dart
  ///   context.watch<CounterBloc>();
  /// ```
  ///
  /// is valid in [State.initState], while:
  ///
  /// ```dart
  /// RxProvider.of<CounterBloc>(context, listen: true);
  /// ```
  ///
  /// or
  ///
  /// ```dart
  ///   context.watch<CounterBloc>();
  /// ```
  ///
  /// is not valid. You CAN get the instance of the bloc in [State.initState]
  /// but CAN NOT subscribe to its changes.
  static T of<T extends RxBase>(BuildContext context, {bool listen = true}) {
    if (T == dynamic) {
      throw RxBlocMustBeOfSpecificTypeException();
    }
    final element = context
            .getElementForInheritedWidgetOfExactType<_InheritedBlocScope<T>>()
        as _InheritedBlocElement<T>?;
    final bloc = element?.bloc;
    if (bloc is! T) {
      throw RxBlocNotProvidedException(T);
    }
    if (listen) {
      context.dependOnInheritedWidgetOfExactType<_InheritedBlocScope<T>>();
    }
    return bloc;
  }

  @override
  State<RxProvider<B>> createState() => _RxProviderState<B>();
}

class _RxProviderState<B extends RxBase>
    extends SingleChildState<RxProvider<B>> {
  late final B _bloc;
  late final bool _isCreated;

  @override
  void initState() {
    super.initState();
    _isCreated = widget._isCreated;
    if (_isCreated) {
      _bloc = widget._create!.call();
      _bloc.init();
    } else {
      _bloc = widget._bloc!;
    }
  }

  @override
  void dispose() {
    if (_isCreated) {
      _bloc.dispose();
    }
    return super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(child != null, "usage outside of MultiProviders not allowed");
    return _InheritedBlocScope<B>(
      bloc: _bloc,
      child: child!,
    );
  }
}

class _InheritedBlocScope<B extends RxBase> extends InheritedWidget {
  final B bloc;

  const _InheritedBlocScope(
      {Key? key, required this.bloc, required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant _InheritedBlocScope<B> oldWidget) {
    return false;
  }

  @override
  _InheritedBlocElement<B> createElement() {
    return _InheritedBlocElement<B>(this);
  }
}

class _InheritedBlocElement<B extends RxBase> extends InheritedElement {
  B get bloc => widget.bloc;
  StreamSubscription? _streamSubscription;
  bool _dirty = false;
  late final bool _shouldSkipFirstBuild;
  bool _isFirstBuild = true;

  _InheritedBlocElement(_InheritedBlocScope<B> widget) : super(widget) {
    _sub(widget.bloc);
    _shouldSkipFirstBuild = widget.bloc.shouldSkipFirstBuild;
  }

  @override
  _InheritedBlocScope<B> get widget => super.widget as _InheritedBlocScope<B>;

  void _sub(B bloc) {
    _streamSubscription = bloc.stateStream.listen((_) {
      _handleUpdate();
    });
  }

  void _unSub() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }

  void _handleUpdate() {
    if (_shouldSkipFirstBuild && _isFirstBuild) {
      return;
    }
    _dirty = true;
    markNeedsBuild();
  }

  @override
  void update(covariant _InheritedBlocScope<B> newWidget) {
    final B oldBloc = widget.bloc;
    final B newBloc = newWidget.bloc;
    if (oldBloc != newBloc) {
      if (_streamSubscription != null) {
        _unSub();
      }
      _sub(newBloc);
    }
    super.update(newWidget);
  }

  @override
  Widget build() {
    if (_dirty) {
      notifyClients(widget);
      _dirty = false;
    }
    if (_isFirstBuild) {
      _isFirstBuild = false;
    }
    return super.build();
  }

  @override
  void unmount() {
    _unSub();
    super.unmount();
  }
}

extension RxContext on BuildContext {
  /// Short hand way to use:
  /// ```dart
  ///   RxProvider.of<B>(context, listen: false);
  /// ```
  /// Do notice that the use of:
  /// ```dart
  ///  RxProvider.of<CounterBloc>(context, listen: false);
  /// ```
  /// or
  ///
  /// ```dart
  ///   context.watch<CounterBloc>();
  /// ```
  ///
  /// is valid in [State.initState], while:
  ///
  /// ```dart
  /// RxProvider.of<CounterBloc>(context, listen: true);
  /// ```
  ///
  /// or
  ///
  /// ```dart
  ///   context.watch<CounterBloc>();
  /// ```
  ///
  /// is not valid. You CAN get the instance of the bloc in [State.initState]
  /// but CAN NOT subscribe to its changes.
  B read<B extends RxBase>() {
    return RxProvider.of<B>(this, listen: false);
  }

  /// Short hand way to use:
  /// ```dart
  ///   RxProvider.of<B>(context, listen: true);
  /// ```
  /// Do notice that the use of:
  /// ```dart
  ///  RxProvider.of<CounterBloc>(context, listen: false);
  /// ```
  /// or
  ///
  /// ```dart
  ///   context.watch<CounterBloc>();
  /// ```
  ///
  /// is valid in [State.initState], while:
  ///
  /// ```dart
  /// RxProvider.of<CounterBloc>(context, listen: true);
  /// ```
  ///
  /// or
  ///
  /// ```dart
  ///   context.watch<CounterBloc>();
  /// ```
  ///
  /// is not valid. You CAN get the instance of the bloc in [State.initState]
  /// but CAN NOT subscribe to its changes.
  B watch<B extends RxBase>() {
    return RxProvider.of<B>(this, listen: true);
  }
}
