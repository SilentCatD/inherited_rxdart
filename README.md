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

A simple state management solution that combine the power of inherited widget and rxdart

## Features

Create state management logic for your app using multitude of blocs, which internal
is just stream and rxdart, you can access them anywhere in your widget tree when
provided using providers.

## Getting started

Started by providing blocs and service for your widget's subtree like this:

```dart
class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: RxProvider<CounterBloc>(
          create: () => CounterBloc(10),
          child: MyHomePage(),
        )
    );
  }
}
```

And then access them anywhere in your subtree with:

```dart

final bloc = RxProvider.of<CounterBloc>(context);
```

## Usage

View documents of each API for more details. The library support multiple type of blocs and related widgets.

- RxSingleStateBloc: for simple model based state-management, shipped with related widget:
    - RxSingleStateBuilder: for handle rebuilding widget when a new state is emitted.
    - RxSingleStateSelector: for selectively rebuilding when state changed.
    - RxSingleStateListener: for a listener callback when state changed.
    - RxSingleStateConsumer: combination of builder and listener.

For other blocs, there will be specific widget for each purpose include: rebuilding, listening,...

- RxBuilder: For building widgets based on states.
- RxListener: For listening to state changes and notifications.
- RxStateListener: For listening to state changes only.
- RxConsumer: Combination of RxListener and RxBuilder.
- RxStateConsumer: Combination of RxStateListener and RxBuilder.
- RxSelector: For selectively rebuilding widgets based on specific property of state.


- RxSilentBloc: for a bloc, which will emit states throughout its life-cycle and rebuild widgets
  when necessary. Work with:
    - RxBuilder
    - RxSelector
    - RxStateConsumer
    - RxStateListener


- RxBloc: bloc with notification beside states, which can be listened and react accordingly. Work with:
    - RxBuilder
    - RxListener
    - RxStateListener
    - RxConsumer
    - RxStateConsumer
    - RxSelector

There's also simple service provider for controller/repo or simply to inject an instance through a widget
subtree.
- ServiceProvider

## Additional information

To provide multiple blocs or model instance, the use of these widget is encouraged:

- RxMultiProvider
- MultiServiceProvider

To quickly access blocs/services, rather than use these function:
```dart
RxProvider.of<MyBloc>(context);
ServiceProvider.of<MyService>(context);
```
One can use:
```dart
context.watch<MyBloc>(); // for getting an instance of a bloc.
context.read<MyBloc>(); // for getting an instance of a bloc and subscribe to it's changes.
context.get<MyService>(); //for getting an instance of a service. 
```
