import 'package:flutter/material.dart';

import 'exception.dart';
import 'rx_bloc.dart';
import 'rx_builder.dart';
import 'rx_listener.dart';
import 'type_def.dart';

/// Combination of [RxStateListener] and [RxBuilder].
///
/// Work with:
/// * [RxBloc]
/// * [RxCubit]
class RxStateConsumer<B extends RxCubit<S>, S> extends StatefulWidget {
  const RxStateConsumer({
    Key? key,
    this.stateCallback,
    this.shouldRebuildWidget,
    required this.builder,
  })  : _fromValue = false,
        _value = null,
        super(key: key);

  const RxStateConsumer.value({
    required B value,
    Key? key,
    this.stateCallback,
    this.shouldRebuildWidget,
    required this.builder,
  })  : _fromValue = true,
        _value = value,
        super(key: key);

  final bool _fromValue;
  final B? _value;

  final RxBlocEventListener<S>? stateCallback;
  final RxBlocWidgetBuilder<S> builder;
  final ShouldRebuildWidget<S>? shouldRebuildWidget;

  @override
  State<RxStateConsumer<B, S>> createState() => _RxStateConsumerState<B, S>();
}

class _RxStateConsumerState<B extends RxCubit<S>, S>
    extends State<RxStateConsumer<B, S>> {
  late final bool _fromValue;
  B? _bloc;

  @override
  void initState() {
    super.initState();
    _fromValue = widget._fromValue;
    if (_fromValue) {
      _bloc = widget._value;
    }
  }

  @override
  void didUpdateWidget(covariant RxStateConsumer<B, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((_fromValue && !widget._fromValue) ||
        (!_fromValue && widget._fromValue)) {
      throw RxMapError();
    }
    if (_fromValue) {
      if (oldWidget._value != widget._value) {
        _bloc = widget._value;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_fromValue) {
      return RxStateListener<B, S>.value(
        value: _bloc!,
        stateCallback: widget.stateCallback,
        child: RxBuilder<B, S>.value(
          value: _bloc!,
          shouldRebuildWidget: widget.shouldRebuildWidget,
          builder: widget.builder,
        ),
      );
    } else {
      return RxStateListener<B, S>(
        stateCallback: widget.stateCallback,
        child: RxBuilder<B, S>(
          shouldRebuildWidget: widget.shouldRebuildWidget,
          builder: widget.builder,
        ),
      );
    }
  }
}

/// Combination of [RxListener] and [RxBuilder].
///
/// Work with:
/// * [RxBloc]
class RxConsumer<B extends RxBloc<S, N>, S, N> extends StatefulWidget {
  const RxConsumer({
    Key? key,
    required this.builder,
    this.shouldRebuildWidget,
    this.stateCallback,
    this.notificationCallback,
  })  : _value = null,
        _fromValue = false,
        super(key: key);

  const RxConsumer.value({
    Key? key,
    required B value,
    required this.builder,
    this.shouldRebuildWidget,
    this.stateCallback,
    this.notificationCallback,
  })  : _value = value,
        _fromValue = true,
        super(key: key);

  final bool _fromValue;
  final B? _value;
  final RxBlocEventListener<S>? stateCallback;
  final RxBlocWidgetBuilder<S> builder;
  final ShouldRebuildWidget<S>? shouldRebuildWidget;
  final RxBlocEventListener<N>? notificationCallback;

  @override
  State<RxConsumer<B, S, N>> createState() => _RxConsumerState<B, S, N>();
}

class _RxConsumerState<B extends RxBloc<S, N>, S, N>
    extends State<RxConsumer<B, S, N>> {
  late final bool _fromValue;
  B? _bloc;

  @override
  void initState() {
    super.initState();
    _fromValue = widget._fromValue;
    if (_fromValue) {
      _bloc = widget._value;
    }
  }

  @override
  void didUpdateWidget(covariant RxConsumer<B, S, N> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((_fromValue && !widget._fromValue) ||
        (!_fromValue && widget._fromValue)) {
      throw RxMapError();
    }
    if (_fromValue) {
      if (oldWidget._value != widget._value) {
        _bloc = widget._value;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_fromValue) {
      return RxListener<B, S, N>.value(
        value: _bloc!,
        stateCallback: widget.stateCallback,
        notificationCallback: widget.notificationCallback,
        child: RxBuilder<B, S>.value(
          value: _bloc!,
          shouldRebuildWidget: widget.shouldRebuildWidget,
          builder: widget.builder,
        ),
      );
    } else {
      return RxListener<B, S, N>(
        stateCallback: widget.stateCallback,
        notificationCallback: widget.notificationCallback,
        child: RxBuilder<B, S>(
          shouldRebuildWidget: widget.shouldRebuildWidget,
          builder: widget.builder,
        ),
      );
    }
  }
}

/// Combination of [RxViewModelListener] and [RxViewModelBuilder].
///
/// Work with:
/// * [RxViewModel]
class RxViewModelConsumer<B extends RxViewModel> extends StatefulWidget {
  const RxViewModelConsumer({
    Key? key,
    this.stateCallback,
    required this.builder,
    this.shouldRebuildWidget,
  })  : _value = null,
        _fromValue = false,
        super(key: key);

  const RxViewModelConsumer.value({
    Key? key,
    required B value,
    this.stateCallback,
    required this.builder,
    this.shouldRebuildWidget,
  })  : _value = value,
        _fromValue = true,
        super(key: key);

  final bool _fromValue;
  final B? _value;
  final RxBlocEventListener<B>? stateCallback;
  final RxBlocWidgetBuilder<B> builder;
  final ShouldRebuildViewModel<B>? shouldRebuildWidget;

  @override
  State<RxViewModelConsumer<B>> createState() => _RxViewModelConsumerState<B>();
}

class _RxViewModelConsumerState<B extends RxViewModel>
    extends State<RxViewModelConsumer<B>> {
  late final bool _fromValue;
  B? _bloc;

  @override
  void initState() {
    super.initState();
    _fromValue = widget._fromValue;
    if (_fromValue) {
      _bloc = widget._value;
    }
  }

  @override
  void didUpdateWidget(covariant RxViewModelConsumer<B> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((_fromValue && !widget._fromValue) ||
        (!_fromValue && widget._fromValue)) {
      throw RxMapError();
    }
    if (_fromValue) {
      if (oldWidget._value != widget._value) {
        _bloc = widget._value;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_fromValue) {
      return RxViewModelListener<B>.value(
        value: _bloc!,
        stateCallback: widget.stateCallback,
        child: RxViewModelBuilder<B>.value(
          value: _bloc!,
          builder: widget.builder,
          shouldRebuildWidget: widget.shouldRebuildWidget,
        ),
      );
    } else {
      return RxViewModelListener<B>(
        stateCallback: widget.stateCallback,
        child: RxViewModelBuilder<B>(
          builder: widget.builder,
          shouldRebuildWidget: widget.shouldRebuildWidget,
        ),
      );
    }
  }
}
