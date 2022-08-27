import 'package:flutter/material.dart';
import 'rx_bloc.dart';

typedef RxBlocCreate<B extends RxBloc> = B Function();
typedef RxBlocWidgetBuilder<T> = Widget Function(BuildContext context, T);
typedef RxBlocEventListener<S> = void Function(BuildContext context, S state);
typedef ShouldRebuildWidget<S> = bool Function(S prev, S curr);
