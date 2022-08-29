import 'package:flutter/material.dart';
import 'exception.dart';
import 'type_def.dart';
import 'package:nested/nested.dart';

class ServiceProvider<S> extends SingleChildStatefulWidget {
  ServiceProvider({Key? key, Widget? child, required Create<S> create})
      : _service = create(),
        super(key: key, child: child);

  const ServiceProvider.value(
      {Key? key, required Widget child, required S value})
      : _service = value,
        super(key: key, child: child);
  final S _service;

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
  T get<T>() {
    return ServiceProvider.of<T>(this);
  }
}
