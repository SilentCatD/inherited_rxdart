import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'rx_provider.dart';

/// A widget that should be used when you want to provide multiple [RxProvider]
/// at once, without nesting them.
///
/// For example:
///
/// ```dart
/// class App extends StatelessWidget {
///   const App({Key? key}) : super(key: key);
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: RxMultiProvider(
///         providers: [
///           RxProvider<CounterBloc>(
///               create: () => CounterBloc(const MyState(text: "hi", number: 10))),
///           RxProvider<CounterBloc2>(create: () => CounterBloc2(10)),
///           RxProvider<CounterBloc3>(create: () => CounterBloc3(10)),
///         ],
///         child: const MyHomePage(),
///       ),
///     );
///   }
/// }
/// ```
///
/// ... is equivalent to:
///
///```dart
/// class App extends StatelessWidget {
///   const App({Key? key}) : super(key: key);
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: RxProvider<CounterBloc>(
///         create: () => CounterBloc(const MyState(text: "hi", number: 10)),
///        child: RxProvider<CounterBloc2>(
///          create: () => CounterBloc2(10),
///          child: RxProvider<CounterBloc3>(
///            create: () => CounterBloc3(10),
///             child: const MyHomePage(),
///           ),
///         ),
///       ),
///     );
///   }
/// }
/// ```
class RxMultiProvider extends Nested {
  RxMultiProvider(
      {Key? key, required List<RxProvider> providers, required Widget child})
      : super(key: key, children: providers, child: child);
}
