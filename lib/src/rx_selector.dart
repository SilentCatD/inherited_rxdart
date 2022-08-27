import 'package:flutter/material.dart';
import 'rx_bloc.dart';
import 'rx_provider.dart';
import 'type_def.dart';

class RxSelector<B extends RxBloc<S>, S> extends StatefulWidget {
  const RxSelector({
    Key? key,
    required this.shouldRebuildWidget,
    required this.builder,
  }) : super(key: key);
  final ShouldRebuildWidget<S> shouldRebuildWidget;
  final RxBlocWidgetBuilder<S> builder;

  @override
  State<RxSelector<B, S>> createState() => _RxSelectorState<B, S>();
}

class _RxSelectorState<B extends RxBloc<S>, S>
    extends State<RxSelector<B, S>> {
  Widget? oldWidget;
  S? oldState;
  late S newState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    newState = context.watch<B>().state;
  }

  @override
  Widget build(BuildContext context) {
    Widget? newWidget;
    if (oldWidget == null) {
      newWidget = widget.builder(context, newState);
      oldWidget = newWidget;
      oldState = newState;
    } else {
      final shouldRebuild = widget.shouldRebuildWidget(oldState!, newState);
      newWidget =
          shouldRebuild ? widget.builder(context, newState) : oldWidget;
    }
    return newWidget!;
  }
}
