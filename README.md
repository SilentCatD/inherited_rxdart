<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

[![pub package](https://img.shields.io/pub/v/inherited_rxdart?color=green&include_prereleases&style=plastic)](https://pub.dev/packages/inherited_rxdart)

A simple state management solution that combine the power of inherited widget and rxdart

## Features

Create state management logic for your app using multitude of blocs, which internal is just stream
and rxdart, you can access them anywhere in your widget tree when provided using providers.

## Getting started

Started by providing blocs and service for your widget's subtree like this:

First import it:

```dart
import 'package:inherited_rxdart/inherited_rxdart.dart';
```

Create your bloc and state:

```dart
@immutable
class MyState {
  final int number;
  final String text;

  const MyState({required this.number, required this.text});

  MyState copyWith({int? number, String? text}) {
    return MyState(number: number ?? this.number, text: text ?? this.text);
  }
}

// Define bloc with two type:
// MyState: State of the bloc
// String: Type of notification
class CounterBloc extends RxBloc<MyState, String> {
  CounterBloc(MyState initialState) : super(initialState);

  void showDialog() {
    // will notify all notification listeners
    notify("showDialog");
  }

  void changeText(String newText) {
    // will cause dependent to rebuild
    state = state.copyWith(text: newText);
  }

  void increase() {
    // will cause dependent to rebuild
    state = state.copyWith(number: state.number + 1);
  }

  void decrease() {
    // will cause dependent to rebuild
    state = state.copyWith(number: state.number - 1);
  }
}
```

And start using it in your app:

```dart
class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: RxProvider<CounterBloc>(
          create: () => CounterBloc(const MyState(text: "hi", number: 0)),
          child: MyHomePage(),
        )
    );
  }
}
```

Access them anywhere in your subtree with:

```dart

final bloc = RxProvider.of<CounterBloc>(context);
```

## Usage

View documents of each API for more details. The library support bloc pattern and view model pattern
for your app.

### Bloc's Widgets

For blocs, there will be specific widget for each purpose include: rebuilding, listening,...

- RxBuilder: For building widgets based on states.
- RxListener: For listening to state changes and notifications.
- RxStateListener: For listening to state changes only.
- RxConsumer: Combination of RxListener and RxBuilder.
- RxStateConsumer: Combination of RxStateListener and RxBuilder.
- RxSelector: For selectively rebuilding widgets based on specific property of state.

### RxCubit:

A simple bloc, which will emit states throughout its life-cycle and rebuild widgets when necessary.
Work with:

- RxBuilder
- RxSelector
- RxStateConsumer
- RxStateListener

### RxBloc:

Bloc with notification beside states, which can be listened and react accordingly. Work with:

- RxBuilder
- RxListener
- RxStateListener
- RxConsumer
- RxStateConsumer
- RxSelector

### RxViewModel

For simple view model based state-management, shipped with related widget:

- RxViewModelBuilder: for handle rebuilding widget when a new state is emitted.
- RxViewModelSelector: for selectively rebuilding when state changed.
- RxViewModelListener: for a listener callback when state changed.
- RxViewModelConsumer: combination of builder and listener.

### RxValue

A value for reactive state management, will cause its dependent to rebuild when its value is set.

- RxValueBuilder: build to work with RxValue.

### ServiceProvider

There's also simple service provider for repo or simply to inject an instance through a
widget subtree.

- ServiceProvider

### Register global Singleton

Though not really inherited, this library do provide the use of register an instance through GetIt,
and use them in builders, listeners .value constructor. This feature can be access with RxProvider static method

### EventDispatcherMixin

Mixin to add event dispatch capability to RxCubit/RxBloc and register
a callback to those event.

By default, there's only one stream from RxCubit/RxBloc and that is
RxBase.stateStream, this stream would output states to rebuild ui.

This mixin introduce another stream from ui to RxCubit/RxBloc that can
be used to handle an event type and a subtype of it. Which each can be
transformed using StreamTransformer.

## Additional information

To provide multiple blocs/view model/service instances, the use of these widget is encouraged:

- RxMultiProvider
- MultiServiceProvider

To quickly access blocs/services, rather than use these function:

```dart
RxProvider.of<MyBloc>(context);
ServiceProvider.of<MyService>(context);
```

One can use:

```dart
context.watch<MyBloc>(); // for getting an instance of a bloc / view model and subscribe to it's changes.
context.read<MyBloc>(); // for getting an instance of a bloc/view model
context.get<MyService>(); //for getting an instance of a service. 
```

And

```dart

final text = RxValue<String>("hello");
```

Is equivalent to:

```dart

final text = "hello".rx;
```
