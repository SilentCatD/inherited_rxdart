import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

abstract class RxBlocBase<S> {
  const RxBlocBase(Subject stateSubject) : _stateSubject = stateSubject;

  bool get shouldSkipFirstBuild;

  @nonVirtual
  @protected
  final Subject _stateSubject;

  S get state;

  @protected
  Subject get subject => _stateSubject;

  Stream get stateStream => subject.stream;

  @mustCallSuper
  Future<void> init() async {}

  @mustCallSuper
  Future<void> dispose() {
    return _stateSubject.close();
  }
}

abstract class RxSingleStateBloc extends RxBlocBase<RxSingleStateBloc> {
  RxSingleStateBloc() : super(PublishSubject());

  @override
  @nonVirtual
  bool get shouldSkipFirstBuild => false;

  @override
  RxSingleStateBloc get state => this;

  @protected
  @nonVirtual
  void stateChanged() {
    _stateSubject.add(null);
  }
}

abstract class RxSilentBloc<S> extends RxBlocBase<S> {
  RxSilentBloc(S initialState) : super(BehaviorSubject<S>.seeded(initialState));


  @override
  @nonVirtual
  bool get shouldSkipFirstBuild => true;

  @override
  @protected
  BehaviorSubject<S> get subject => _stateSubject as BehaviorSubject<S>;

  @override
  @nonVirtual
  S get state => subject.value;

  @nonVirtual
  @protected
  set state(S value) => subject.value = value;

  @override
  @nonVirtual
  Stream<S> get stateStream => subject.stream.distinct();
}

abstract class RxBloc<S, N> extends RxSilentBloc<S> {
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
