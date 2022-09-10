import 'package:flutter/material.dart';
import 'exception.dart';
import 'type_def.dart';
import 'package:nested/nested.dart';
import 'rx_provider.dart';

/// Widget to provide a service of type [S] to a subtree.
///
/// The default constructor indicate the creation of above mentioned service [S]
/// through [Create]. However, in case the reuse of existed service is required,
/// [ServiceProvider.value] should be used instead.
///
/// Different from [RxProvider], [ServiceProvider] take any class, and does not
/// manage the life cycle operation of these object. It should be used with
/// Service class like Repository to use it's function, not to store any mutable
/// variable/state in it.
///
/// ```dart
/// ServiceProvider<MyService>(
///     create: () => MyService(),
///     child: const MyHomePage(),
/// ),
/// ```
///
/// The [ServiceProvider.value] is useful when you need to provide an existed
/// service to another screen.
///
/// ```dart
/// Navigator.of(context).push(MaterialPageRoute(builder: (_) {
///     return ServiceProvider.value(
///         value:
///            ServiceProvider.of<MyService>(context, listen: false),
///         child: const MyNested());
/// }));
/// ```
/// If multiple services are to be provided at once, consider
/// [MultiServiceProvider] to avoid deeply nested [ServiceProvider] widgets.
class ServiceProvider<S> extends SingleChildStatefulWidget {
  ServiceProvider({Key? key, Widget? child, required Create<S> create})
      : _service = create(),
        super(key: key, child: child);

  const ServiceProvider.value(
      {Key? key, required Widget child, required S value})
      : _service = value,
        super(key: key, child: child);
  final S _service;

  /// Method to locate and get the provided service of this subtree.
  ///
  /// Type [T] is required to be specified. Failing to so will throw
  /// [ServiceMustBeOfSpecificTypeException], and failing to find a service of
  /// specified type will thrown [ServiceNotProvidedException].
  /// Consider [ServiceContext.get] for a short-hand way to call this function.
  static T of<T>(BuildContext context) {
    if (T == dynamic) {
      throw ServiceMustBeOfSpecificTypeException();
    }
    final element = context.getElementForInheritedWidgetOfExactType<
        _InheritedServiceScope<T>>() as _InheritedServiceElement<T>?;
    final service = element?.service;
    if (service is! T) {
      throw ServiceNotProvidedException(T);
    }
    return service;
  }

  @override
  State<ServiceProvider<S>> createState() => _ServiceProviderState<S>();
}

class _ServiceProviderState<S> extends SingleChildState<ServiceProvider<S>> {
  late S _service;

  @override
  void initState() {
    super.initState();
    _service = widget._service;
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(child != null, "usage outside of MultiProviders not allowed");
    return _InheritedServiceScope<S>(
      service: _service,
      child: child!,
    );
  }
}

class _InheritedServiceScope<S> extends InheritedWidget {
  const _InheritedServiceScope({required Widget child, required this.service})
      : super(child: child);

  final S service;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

  @override
  _InheritedServiceElement<S> createElement() {
    return _InheritedServiceElement<S>(this);
  }
}

class _InheritedServiceElement<S> extends InheritedElement {
  _InheritedServiceElement(InheritedWidget widget) : super(widget);

  S get service => widget.service;

  @override
  _InheritedServiceScope<S> get widget =>
      super.widget as _InheritedServiceScope<S>;
}

extension ServiceContext on BuildContext {
  /// Short hand way to use:
  /// ```dart
  ///   ServiceProvider.of<B>(context);
  /// ```
  T get<T>() {
    return ServiceProvider.of<T>(this);
  }
}
