import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

abstract class RxBloc<S> {
  RxBloc(this.initialState)
      : stateSubject = BehaviorSubject<S>.seeded(initialState);

  @protected
  final S initialState;

  @protected
  final BehaviorSubject<S> stateSubject;

  @nonVirtual
  S get state => stateSubject.value;

  @nonVirtual
  set state(S value) => stateSubject.value = value;

  @nonVirtual
  Stream<S> get stateStream => stateSubject.stream.distinct();

  @mustCallSuper
  Future<void> init() async {}

  @mustCallSuper
  Future<void> dispose() {
    return stateSubject.close();
  }
}

mixin EventDispatcher<E> {
  @protected
  final PublishSubject<E> notificationSubject = PublishSubject<E>();

  @nonVirtual
  Stream<E> get notificationStream => notificationSubject.stream;

  @nonVirtual
  void notify(E value) => notificationSubject.add(value);
}
