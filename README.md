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

And then access them anywhere in your subtree  with:

```dart
final bloc = RxProvider.of<CounterBloc>(context);
```

## Usage

More details coming soon

## Additional information

