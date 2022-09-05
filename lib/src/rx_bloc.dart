import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'exception.dart';

/// Base class for others bloc, subclass this when making a new bloc.
///
/// The type [S] would be the type of value of [Stream] and [state].
///
/// The init and dispose logic of these bloc are called automatically by
/// [RxProvider], so implementer of these class don't have to, but if a Bloc
/// object are created outside of [RxProvider] (ex: [RxProvider.value]), its
/// life cycle operation (init, dispose) must be handled and ensured by
/// implementer.
abstract class RxBlocBase<S> {
  /// This bloc need a type of subject to work with.
  RxBlocBase(Subject<S> stateSubject)
      : _stateSubject = stateSubject,
        _initialized = false;

  bool _initialized;

  @nonVirtual
  bool get initialized => _initialized;

  /// Whether the bloc is initialized.
  ///
  /// This variable should not be set outside the [init] function. The value to
  /// be set for this variable can't be False, this is to prevent an initialized
  /// bloc is mark as uninitialized when the init function has been run.
  ///
  /// It also can't be set a second time, this mean initialized bloc will stay
  /// initialized for the whole of its life-span.
  @nonVirtual
  set initialized(bool value) {
    if (!value) {
      throw BlocInitializedSetToFalseException();
    }
    if (initialized) {
      throw BlocInitializedASecondTimeException();
    }
    _initialized = value;
  }

  /// Whether to skip the first build trigger by stream, for when using
  /// [BehaviorSubject], the first state rebuild is not really necessary and
  /// can be optimized by this variable.
  bool get shouldSkipFirstBuild;

  @nonVirtual
  @protected
  final Subject<S> _stateSubject;

  /// The current state this bloc is holding.
  S get state;

  /// Function to emit new state values to the [stateStream].
  @nonVirtual
  @protected
  void _stateChanged(S value) {
    _stateSubject.sink.add(value);
  }

  /// The subject this bloc will use, because built on rxdart, those subject
  /// maybe:
  /// * [PublishSubject] for [RxSingleStateBloc] and notifications
  /// * [BehaviorSubject] for [RxBloc], [RxSilentBloc]
  @protected
  Subject<S> get subject => _stateSubject;

  /// The value stream of this bloc, which listened by the library and cause the
  /// rebuild of dependents, subclass can override this to add filter,
  /// throttle,...
  Stream<S> get stateStream => subject.stream;

  /// Initialize logic for this bloc, will be automatically called by
  /// [RxProvider] if the [Create] function is used in constructor.
  @mustCallSuper
  Future<void> init() async {
    initialized = true;
  }

  /// Disposing logic for this bloc, will be automatically called by
  /// [RxProvider] if the [Create] function is used in constructor.
  @mustCallSuper
  Future<void> dispose() {
    return _stateSubject.close();
  }
}

/// Simple bloc without complicated state, notification,etc,... similar to model
/// based state management like [ChangeNotifierProvider].
///
/// Bloc extending this class only need to call [RxSingleStateBloc.stateChanged]
/// to notify all other dependent that the state of this bloc has changed and
/// need to rebuild. For example:
///
/// ```dart
/// class CounterBloc3 extends RxSingleStateBloc {
///   int num;
///   int num2;
///
///   CounterBloc3(this.num, [this.num2 = 0]);
///
///   @override
///   CounterBloc3 get state => super.state as CounterBloc3;
///
///   void increase() {
///     num++;
///     num2++;
///     stateChanged();
///   }
///
///   void decrease() {
///     num--;
///     // num2--;
///     stateChanged();
///   }
/// }
///```
///
/// Because the simplicity of this modal based bloc, there are classes
/// that handle the rebuild or listen to the states of this type of
/// bloc dependent:
/// * [RxSingleStateBuilder]
/// * [RxSingleStateSelector]
/// * [RxSingleStateListener]
/// * [RxSingleStateConsumer]
///
/// The init and dispose logic of these bloc are called automatically by
/// [RxProvider], so implementer of these class don't have to, but if a Bloc
/// object are created outside of [RxProvider] (ex: [RxProvider.value]), its
/// life cycle operation (init, dispose) must be handled and ensured by
/// implementer.
abstract class RxSingleStateBloc extends RxBlocBase<RxSingleStateBloc> {
  /// This bloc will use [PublishSubject] as its internal.
  RxSingleStateBloc() : super(PublishSubject<RxSingleStateBloc>());

  /// Whether to skip the first build trigger by stream, for when using
  /// [BehaviorSubject], the first state rebuild is not really necessary and
  /// can be optimized by this variable.
  /// For this case, this value should be false, because the nature of
  /// [PublishSubject] not emitting last value when listened
  @override
  @nonVirtual
  bool get shouldSkipFirstBuild => false;

  /// The current state this bloc is holding. Which in this case is this
  /// object itself, so internal mutable variable and the dependent that depend
  /// on those will be rebuilt accordingly.
  @override
  RxSingleStateBloc get state => this;

  /// Signature function of [RxSingleStateBloc], call to this function
  /// will cause all the dependent widget of this bloc to be rebuilt.
  @protected
  @nonVirtual
  void stateChanged() => _stateChanged(this);
}

/// A bloc that will emit new states through out its life cycle.
///
/// Generic type [S] in this bloc would be the type of [state] it will be
/// emitting.
/// Will notify all of its dependent to rebuild when the setter
/// [RxSilentBloc.state] is used:
///
/// ```dart
/// state = newState
/// ```
///
/// Here's an example of class subclassing this:
///```dart
/// class CounterBloc2 extends RxSilentBloc<int> {
///   CounterBloc2(int initialState) : super(initialState);
///
///   void increase() {
///     state++;
///   }
///
///   void decrease() {
///     state--;
///   }
/// }
/// ```
///
/// The state in this case is [int], but it can also be your custom classes.
/// Though, implementer should think of state as [immutable] object, it does
/// not change by itself, states with different attributes are all separated
/// state. Thus the use of [immutable] keyword for state should be considered
/// as a good practice.
///
/// ```dart
/// @immutable
/// class MyState {
///   final int number;
///   final String text;
///
///   const MyState({required this.number, required this.text});
///
///   MyState copyWith({int? number, String? text}) {
///     return MyState(number: number ?? this.number, text: text ?? this.text);
///   }
/// }
/// ```
///
/// Dependent of [RxProvider] of this bloc can use the following widgets for
/// their rebuilding and listening for state changes:
/// * [RxBuilder]
/// * [RxSelector]
/// * [RxStateConsumer]
/// * [RxStateListener]
///
/// The init and dispose logic of these bloc are called automatically by
/// [RxProvider], so implementer of these class don't have to, but if a bloc
/// object are created outside of [RxProvider] (ex: [RxProvider.value]), its
/// life cycle operation (init, dispose) must be handled and ensured by
/// implementer.
abstract class RxSilentBloc<S> extends RxBlocBase<S> {
  /// Using [BehaviorSubject] as its internal, this bloc will need an
  /// [initialState], which will then be [BehaviorSubject.seeded] by the
  /// subject.
  RxSilentBloc(S initialState) : super(BehaviorSubject<S>.seeded(initialState));

  /// Whether to skip the first build trigger by stream, for when using
  /// [BehaviorSubject], the first state rebuild is not really necessary and
  /// can be optimized by this variable.
  /// For this case, this value should be true, because the nature of
  /// [BehaviorSubject] will emit last value when listened, the value at
  /// the start is not necessary in the build of widgets.
  @override
  @nonVirtual
  bool get shouldSkipFirstBuild => true;

  /// The subject this bloc will use, because built on rxdart, those subject
  /// maybe:
  /// * [PublishSubject] for [RxSingleStateBloc] and notifications
  /// * [BehaviorSubject] for [RxBloc], [RxSilentBloc]
  @override
  @protected
  BehaviorSubject<S> get subject => _stateSubject as BehaviorSubject<S>;

  /// The current state this bloc is holding. In this case is the last [state]
  /// emitted by the publish subject.
  @override
  @nonVirtual
  S get state => subject.value;

  /// Call to this setter will cause all dependent of this Bloc to be rebuilt.
  @nonVirtual
  @protected
  set state(S value) => _stateChanged(value);

  /// The value stream of this bloc, which listened by the library and cause the
  /// rebuild of dependents, subclass can override this to add filter,
  /// throttle,...
  /// The default [stateStream] in this bloc is [Stream.distinct] by nature,
  /// which means sequentially duplicated [state] emitted will be skipped
  /// to avoid unnecessary rebuilding.
  @override
  Stream<S> get stateStream => subject.stream.distinct();
}

/// A bloc with many supported features that this library is designed for.
///
/// Generic type [S] in this bloc would be the type of [state] it will be
/// emitting, and [N] would be the type of notification event.
///
/// This class extends [RxSilentBloc] to add one new feature to it:
/// notification.
/// Notification is the state or event that has nothing to do with the rebuild
/// of UI components, and for action only (ex: [showDialog], [Navigator.push],.)
///
/// Bloc that extending this class can use the setter [RxBloc.state] for
/// emitting new states, and use [RxBloc.notify] to emit new notifications.
///
/// ```dart
/// class CounterBloc extends RxBloc<MyState, String> {
///   CounterBloc(MyState initialState) : super(initialState);
///
///   void showDialog() {
///     notify("showDialog");
///   }
///
///   void changeText(String newText) {
///     state = state.copyWith(text: newText);
///   }
///
///   void increase() {
///     state = state.copyWith(number: state.number + 1);
///   }
///
///   void decrease() {
///     state = state.copyWith(number: state.number - 1);
///   }
/// }
/// ```
///
/// States emitted by this bloc will cause all dependent to be rebuild, while
/// notification can be listened by [RxListener].
///
/// Widgets that supported by this class are:
/// * [RxBuilder]
/// * [RxListener]
/// * [RxStateListener]
/// * [RxConsumer]
/// * [RxStateConsumer]
/// * [RxSelector]
///
/// The init and dispose logic of these bloc are called automatically by
/// [RxProvider], so implementer of these class don't have to, but if a Bloc
/// object are created outside of [RxProvider] (ex: [RxProvider.value]), its
/// life cycle operation (init, dispose) must be handled and ensured by
/// implementer.
abstract class RxBloc<S, N> extends RxSilentBloc<S> {
  /// Using [BehaviorSubject] as its internal, this bloc will need an
  /// [initialState], which will then be [BehaviorSubject.seeded] by the
  /// subject.
  RxBloc(S initialState) : super(initialState);

  /// Notification subject for this bloc.
  @protected
  @nonVirtual
  final PublishSubject<N> notificationSubject = PublishSubject<N>();

  /// Function to call when notifying its notification listener, will be
  /// caught be [RxListener].
  @nonVirtual
  @protected
  void notify(N value) => notificationSubject.add(value);

  /// The notification stream to be emit to listener, subclass can override
  /// this to add filter.
  Stream<N> get notificationStream => notificationSubject.stream;

  /// Disposing logic for this bloc, will be automatically called by
  /// [RxProvider] if the [Create] function is used in constructor.
  @mustCallSuper
  @override
  Future<void> dispose() async {
    await super.dispose();
    return notificationSubject.close();
  }
}
