import 'package:flutter/material.dart';

typedef Create<T> = T Function();
typedef RxBlocWidgetBuilder<T> = Widget Function(BuildContext context, T);
typedef RxBlocEventListener<S> = void Function(BuildContext context, S state);
typedef ShouldRebuildWidget<S> = bool Function(S prev, S curr);
typedef StateRebuildSelector<S, T> = T Function(S state);
typedef ShouldRebuildSingleState<S> = bool Function(S state);
