import 'package:meta/meta.dart';

import 'type_def.dart';

class _CallbackNode<S> {
  final StateListenerCallback<S> callback;
  _CallbackNode<S>? next;

  _CallbackNode({required this.callback, this.next});
}

mixin RxListenableMixin<S>{
  _CallbackNode<S>? _head;
  _CallbackNode<S>? _tail;


  void addListener(StateListenerCallback<S> callback) {
    if (_head == null) {
      assert(_tail == null);
      _head = _CallbackNode(callback: callback);
      _tail = _head;
    } else {
      assert(_tail != null && _tail!.next == null);
      _tail!.next = _CallbackNode(callback: callback);
      _tail = _tail!.next;
    }
  }

  void removeListener(StateListenerCallback<S> callback) {
    _CallbackNode<S>? prev;
    _CallbackNode<S>? curr = _head;
    if (curr != null && curr.callback == callback) {
      _head = curr.next;
      if (curr == _tail) {
        _tail = null;
      }
    } else {
      while (curr != null && curr.callback != callback) {
        prev = curr;
        curr = curr.next;
      }
      if (curr == null) {
        return;
      }
      if (curr == _tail) {
        _tail = prev;
      }
      prev?.next = curr.next;
    }
  }

  @protected
  void notifyListeners(S value) {
    _notifyListeners(_head, value);
  }

  void _notifyListeners(_CallbackNode<S>? head, S value) {
    if (head != null) {
      head.callback.call(value);
      _notifyListeners(head.next, value);
    }
  }
}
