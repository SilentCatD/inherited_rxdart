import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

abstract class RxBlocBase<S> {
  RxBlocBase(S initialState)
      : stateSubject = BehaviorSubject<S>.seeded(initialState);

  @protected
  @nonVirtual
  final BehaviorSubject<S> stateSubject;

  @nonVirtual
  S get state => stateSubject.value;

  @nonVirtual
  @protected
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

abstract class RxBloc<S, N> extends RxBlocBase<S> {
  RxBloc(S initialState) : super(initialState);

  @protected
  @nonVirtual
  final PublishSubject<N> notificationSubject = PublishSubject<N>();

  @nonVirtual
  @protected
  void notify(N value) => notificationSubject.add(value);

  @nonVirtual
  Stream<N> get notificationStream => notificationSubject.stream;

  @mustCallSuper
  @override
  Future<void> dispose() async {
    await super.dispose();
    return notificationSubject.close();
  }
}
