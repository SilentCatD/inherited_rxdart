import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'service_provider.dart';

/// A widget that should be used when you want to provide multiple
/// [ServiceProvider] at once, without nesting them.
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
///       home: MultiServiceProvider(
///         providers: [
///           ServiceProvider<MyService>(
///               create: () => MyService(),
///           ServiceProvider<MyService2>(
///               create: () => MyService2(),
///           ServiceProvider<MyService3>(
///               create: () => MyService3(),
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
///       home: ServiceProvider<MyService>(
///         create: () => MyService(),
///        child: ServiceProvider<MyService2>(
///          create: () => MyService2(),
///          child: ServiceProvider<MyService3>(
///            create: () => MyService3(),
///             child: const MyHomePage(),
///           ),
///         ),
///       ),
///     );
///   }
/// }
/// ```
class MultiServiceProvider extends Nested {
  MultiServiceProvider(
      {Key? key,
      required List<SingleChildWidget> services,
      required Widget child})
      : super(key: key, children: services, child: child);
}
