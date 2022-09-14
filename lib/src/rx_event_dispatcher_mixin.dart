import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'exception.dart';
import 'type_def.dart';
import 'rx_provider.dart';

/// Mixin to add event dispatch capability to [RxCubit], [RxBloc] and register
/// a callback to those event.
///
/// By default, there's only one stream from [RxCubit]/[RxBloc] and that is
/// [RxBase.stateStream], this stream would output states to rebuild ui.
///
/// This mixin introduce another stream from ui to [RxCubit]/[RxBloc] that can
/// be used to handle an event type and a subtype of it. Which each can be
/// transformed using [StreamTransformer].
///
/// This mixin take in 2 generic type. The first one is the state's type [S]
/// of [RxCubit]/[RxBloc] and the second one is event type [E].
///
/// ```dart
///abstract class MyCounterEvent {}
///
/// class CounterIncreased extends MyCounterEvent {}
///
/// class CounterDecreased extends MyCounterEvent {}
///
/// class MyCounter extends RxCubit<int> with EventDispatcherMixin<int, MyCounterEvent> {
///   MyCounter() : super(0) {
///     on<CounterIncreased>((event) => state++);
///     on<CounterDecreased>((event) => state--);
///   }
/// }
/// void main(){
///   final counter = MyCounter();
///   counter.dispatch(CounterDecreased());
/// }
/// ```
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
        throw DuplicateTypeRegistryException(T);
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
