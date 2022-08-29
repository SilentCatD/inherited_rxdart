import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

import 'exception.dart';
import 'rx_bloc.dart';
import 'type_def.dart';

class RxProvider<B extends RxBlocBase> extends SingleChildStatefulWidget {
  RxProvider({
    Key? key,
    required Create<B> create,
    required Widget child,
  })  : _bloc = create(),
        _isCreated = true,
        super(key: key, child: child);

  const RxProvider.value({
    Key? key,
    required B value,
    required Widget child,
  })  : _bloc = value,
        _isCreated = false,
        super(key: key, child: child);

  final B _bloc;
  final bool _isCreated;

  static T of<T extends RxBlocBase>(BuildContext context, {bool listen = true}) {
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

class _RxProviderState<B extends RxBlocBase>
    extends SingleChildState<RxProvider<B>> {
  late final B _bloc;
  late final bool _isCreated;

  @override
  void initState() {
    super.initState();
    _bloc = widget._bloc;
    _isCreated = widget._isCreated;
    if (_isCreated) {
      _bloc.init();
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
    return _InheritedBlocScope<B>(
      bloc: _bloc,
      child: child!,
    );
  }
}

class _InheritedBlocScope<B extends RxBlocBase> extends InheritedWidget {
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

class _InheritedBlocElement<B extends RxBlocBase> extends InheritedElement {
  B get bloc => widget.bloc;
  StreamSubscription? _streamSubscription;
  bool _dirty = false;

  _InheritedBlocElement(_InheritedBlocScope<B> widget) : super(widget) {
    _sub(widget.bloc);
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
    return super.build();
  }

  @override
  void unmount() {
    _unSub();
    super.unmount();
  }
}

extension RxContext on BuildContext {
  B read<B extends RxBlocBase>() {
    return RxProvider.of<B>(this, listen: false);
  }

  B watch<B extends RxBlocBase>() {
    return RxProvider.of<B>(this, listen: true);
  }
}
