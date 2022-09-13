import 'dart:async';
import 'dart:collection';

import 'package:rxdart/rxdart.dart';

import 'rx_provider.dart';

typedef EventCallback<T> = FutureOr<void> Function(T event);

mixin EventDispatcherMixin<S, E> on RxCubit<S> {
  final _eventSet = HashSet<Type>();

  final _compositeSubscription = CompositeSubscription();
  final _eventStream = PublishSubject<E>();

  void add(E event) {
    _eventStream.add(event);
  }

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
    _eventStream.where((event) => event is T) as Stream<T>;
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

abstract class MyEvent {}

class Event1 extends MyEvent {
  final int? b;

  Event1(this.b);
}

class Event2 extends MyEvent {
  final int? a;

  Event2(this.a);
}


class A extends RxCubit<int> with EventDispatcherMixin<int, MyEvent> {
  A(int initialState) : super(initialState) {
    on<Event1>((event) {
      state += event.b ?? 0;
    });
    on<Event2>((event) {
      state += event.a ?? 0;
    });
  }
}

void main() {
  final a = A(0);
  a.add(Event1(5));
}
