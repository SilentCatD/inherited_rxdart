import 'package:flutter/material.dart';
import 'rx_bloc.dart';

import 'type_def.dart';

class _CallbackNode<S> {
  final StateListenerCallback<S> callback;
  _CallbackNode<S>? next;

  _CallbackNode({required this.callback, this.next});
}

/// Mixin to handle callback emitted from state, similar to [ChangeNotifier] but
/// with a stream value.
mixin RxListenableMixin<S> {
  _CallbackNode<S>? _head;
  _CallbackNode<S>? _tail;

  /// Add a callback that will response to [RxBase.stateStream] when it emitted
  /// new state.
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

  /// Remove a callback from the callbacks list.
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

  /// trigger all callback, this is by default called automatically when a new
  /// state is emitted by the [RxBase.stateStream].
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
