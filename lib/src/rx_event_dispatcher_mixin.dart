import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import 'rx_provider.dart';

typedef EventCallback<T> = FutureOr<void> Function(T event);

mixin EventDispatcherMixin<S, E> on RxCubit<S> {
  final _eventSet = HashSet<Type>();

  final _compositeSubscription = CompositeSubscription();
  final _eventStream = PublishSubject<E>();

  @nonVirtual
  void dispatch(E event) {
    if (disposed) return;
    _eventStream.add(event);
  }

  @protected
  @nonVirtual
  void on<T extends E>(EventCallback<T> callBack,
      {StreamTransformer<T, T>? transformer}) {
    assert(T != dynamic);
    assert(() {
      if (_eventSet.contains(T)) {
        throw Exception();
      }
      return true;
    }());
    _eventSet.add(T);
    Stream<T> subEventStream =
        _eventStream.where((event) => event is T).cast<T>();
    if (transformer != null) {
      subEventStream = subEventStream.transform(transformer);
    }
    final subSubscription = subEventStream.listen((event) async {
      await callBack.call(event);
    });
    _compositeSubscription.add(subSubscription);
  }

  @override
  Future<void> dispose() async {
    await _eventStream.close();
    await _compositeSubscription.dispose();
    await super.dispose();
  }
}