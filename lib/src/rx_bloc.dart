part of 'rx_provider.dart';

/// Base class for others Rx, subclass this when making a new type of Rx.
///
/// The type [S] would be the type of value of [Stream] and [state].
///
/// The init and dispose logic of these Rx are called automatically by
/// [RxProvider], so implementer of these class don't have to, but if an Rx
/// object are created outside of [RxProvider] (ex: [RxProvider.value]), its
/// life cycle operation (init, dispose) must be handled and ensured by
/// implementer.
abstract class RxBase<S> with RxListenableMixin<S> {
  /// This Rx need a type of subject to work with.
  RxBase(Subject<S> stateSubject)
      : _stateSubject = stateSubject,
        _initialized = false,
        _disposed = false {
    _listenerSubscription = stateStream.listen((event) {
      notifyListeners(event);
    });
  }

  late bool _disposeWhenPop;

  bool _initialized;

  late final StreamSubscription<S> _listenerSubscription;

  @nonVirtual
  bool get initialized => _initialized;

  bool _disposed;

  bool get disposed => _disposed;

  /// Whether the Rx is disposed.
  ///
  /// This variable should not be set outside the [dispose] function. The value
  /// to be set for this variable can't be False, this is to prevent an
  /// disposed Rx is mark as disposed when the [dispose] function has been run.
  ///
  /// It also can't be set a second time, this mean disposed Rx will stay
  /// disposed.
  set disposed(bool value) {
    if (!value) {
      throw RxDisposedSetToFalseException();
    }
    if (disposed) {
      throw RxDisposedASecondTimeException();
    }
    _disposed = value;
  }

  /// Whether the Rx is initialized.
  ///
  /// This variable should not be set outside the [init] function. The value to
  /// be set for this variable can't be False, this is to prevent an initialized
  /// Rx is mark as uninitialized when the [init] function has been run.
  ///
  /// It also can't be set a second time, this mean initialized Rx will stay
  /// initialized for the whole of its life-span.
  @nonVirtual
  @protected
  set initialized(bool value) {
    if (!value) {
      throw RxInitializedSetToFalseException();
    }
    if (initialized) {
      throw RxInitializedASecondTimeException();
    }
    _initialized = value;
  }

  /// Whether to skip the first build trigger by stream, for when using
  /// [BehaviorSubject], the first state rebuild is not really necessary and
  /// can be optimized by this variable.
  bool get _shouldSkipFirstBuild;

  @nonVirtual
  @protected
  final Subject<S> _stateSubject;

  /// The current state this Rx is holding.
  S get state;

  /// Function to emit new state values to the [stateStream].
  @nonVirtual
  @protected
  void _stateChanged(S value) {
    if (!_stateSubject.isClosed) {
      _stateSubject.sink.add(value);
    }
  }

  /// The subject this Rx will use, because built on rxdart, those subject
  /// maybe:
  /// * [PublishSubject] for [RxViewModel] and notifications
  /// * [BehaviorSubject] for [RxBloc], [RxCubit], [RxValue]
  @protected
  Subject<S> get _subject => _stateSubject;

  /// The value stream of this Rx, which listened by the library and cause the
  /// rebuild of dependents, subclass can override this to add filter,
  /// throttle,...
  Stream<S> get stateStream => _subject.stream;

  /// [StreamSubscription] of [stateStream] stream.
  StreamSubscription<S> listen(StateListenerCallback<S> callback) {
    return stateStream.listen(callback);
  }

  /// Initialize logic for this Rx, will be automatically called by
  /// [RxProvider] if the [Create] function is used in constructor.
  @mustCallSuper
  Future<void> init() async {
    initialized = true;
  }

  /// Disposing logic for this Rx, will be automatically called by
  /// [RxProvider] if the [Create] function is used in constructor.
  @mustCallSuper
  Future<void> dispose() async {
    disposed = true;
    await _stateSubject.close();
    await _listenerSubscription.cancel();
  }
}

/// Simple view model based state management without complicated state,
/// notification,etc,... similar to [ChangeNotifierProvider].
///
/// Classes extending this class only need to call [RxViewModel.stateChanged]
/// to notify all other dependent that the state of this view model has changed
/// and need to rebuild. For example:
///
/// ```dart
/// class CounterViewModel extends RxViewModel {
///   int num;
///   int num2;
///
///   CounterViewModel(this.num, [this.num2 = 0]);
///
///   @override
///   CounterViewModel get state => super.state as CounterViewModel;
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
/// There are classes that handle the rebuild or listen to the states of this
/// type of view model dependent:
/// * [RxViewModelBuilder]
/// * [RxViewModelSelector]
/// * [RxViewModelListener]
/// * [RxViewModelConsumer]
///
/// The init and dispose logic of these view model are called automatically by
/// [RxProvider], so implementer of these class don't have to, but if an Rx
/// object are created outside of [RxProvider] (ex: [RxProvider.value]), its
/// life cycle operation (init, dispose) must be handled and ensured by
/// implementer.
abstract class RxViewModel extends RxBase<RxViewModel> {
  /// This view model will use [PublishSubject] as its internal.
  RxViewModel() : super(PublishSubject<RxViewModel>());

  /// Whether to skip the first build trigger by stream, for when using
  /// [BehaviorSubject], the first state rebuild is not really necessary and
  /// can be optimized by this variable.
  /// For this case, this value should be false, because the nature of
  /// [PublishSubject] not emitting last value when listened
  @override
  @nonVirtual
  bool get _shouldSkipFirstBuild => false;

  /// The current state this view model is holding. Which in this case is this
  /// object itself, so internal mutable variable and the dependent that depend
  /// on those will be rebuilt accordingly.
  @override
  RxViewModel get state => this;

  /// Signature function of [RxViewModel], call to this function
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
/// [RxCubit.state] is used:
///
/// ```dart
/// state = newState
/// ```
///
/// Here's an example of class subclassing this:
///```dart
/// class CounterBloc2 extends RxCubit<int> {
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
/// The init and dispose logic of these Rx are called automatically by
/// [RxProvider], so implementer of these class don't have to, but if an Rx
/// object are created outside of [RxProvider] (ex: [RxProvider.value]), its
/// life cycle operation (init, dispose) must be handled and ensured by
/// implementer.
abstract class RxCubit<S> extends RxBase<S> {
  /// Using [BehaviorSubject] as its internal, this bloc will need an
  /// [initialState], which will then be [BehaviorSubject.seeded] by the
  /// subject.
  RxCubit(this.initialState) : super(BehaviorSubject<S>.seeded(initialState));
  final S initialState;

  /// Whether to skip the first build trigger by stream, for when using
  /// [BehaviorSubject], the first state rebuild is not really necessary and
  /// can be optimized by this variable.
  /// For this case, this value should be true, because the nature of
  /// [BehaviorSubject] will emit last value when listened, the value at
  /// the start is not necessary in the build of widgets.
  @override
  @nonVirtual
  bool get _shouldSkipFirstBuild => true;

  /// The subject this bloc will use, because built on rxdart, those subject
  /// maybe:
  /// * [PublishSubject] for [RxViewModel] and notifications
  /// * [BehaviorSubject] for [RxBloc], [RxCubit], [RxValue]
  @override
  @protected
  BehaviorSubject<S> get _subject => _stateSubject as BehaviorSubject<S>;

  /// The current state this bloc is holding. In this case is the last [state]
  /// emitted by the publish subject.
  @override
  @nonVirtual
  S get state => _subject.valueOrNull ?? initialState;

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
  Stream<S> get stateStream => _subject.stream.distinct();
}

/// A bloc with many supported features that this library is designed for.
///
/// Generic type [S] in this bloc would be the type of [state] it will be
/// emitting, and [N] would be the type of notification event.
///
/// This class extends [RxCubit] to add one new feature to it:
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
/// The init and dispose logic of these Rx are called automatically by
/// [RxProvider], so implementer of these class don't have to, but if an Rx
/// object are created outside of [RxProvider] (ex: [RxProvider.value]), its
/// life cycle operation (init, dispose) must be handled and ensured by
/// implementer.
abstract class RxBloc<S, N> extends RxCubit<S> {
  /// Using [BehaviorSubject] as its internal, this bloc will need an
  /// [initialState], which will then be [BehaviorSubject.seeded] by the
  /// subject.
  RxBloc(S initialState) : super(initialState);

  /// Notification subject for this bloc.
  @protected
  @nonVirtual
  final PublishSubject<N> _notificationSubject = PublishSubject<N>();

  /// Function to call when notifying its notification listener, will be
  /// caught be [RxListener].
  @nonVirtual
  @protected
  void notify(N value) {
    if (!_notificationSubject.isClosed) {
      return _notificationSubject.add(value);
    }
  }

  /// The notification stream to be emit to listener, subclass can override
  /// this to add filter.
  Stream<N> get notificationStream => _notificationSubject.stream;

  /// Disposing logic for this bloc, will be automatically called by
  /// [RxProvider] if the [Create] function is used in constructor.
  @mustCallSuper
  @override
  Future<void> dispose() async {
    await super.dispose();
    await _notificationSubject.close();
  }
}

/// Class for making reactive value.
///
/// Create value of type T and observing it's changes with [RxValueBuilder].
/// Each time an [RxValue] is set by it's setter [RxValue.value], all of the
/// dependent [RxValueBuilder] widget will call it's build function again.
///
/// ```dart
/// class MyViewModel{
///   final number = RxValue<int>(0);
///   void increase(){
///     number.value++;
///   }
/// }
///
/// final myViewModel = MyViewModel();
///
/// RxValueBuilder(
///   value: myViewModel.number,
///   // builder function will be called each time the value is set.
///   builder: (context, value){
///     return ElevatedButton(
///       onPressed: (){
///         myViewModel.increase();
///       }
///       child: Text("$value"),
///     );
///   }
/// ),
/// ```
///
/// A short hand way to create an [RxValue]  of type T is to just use
/// [RxValueExtension], which add: getter rx.
///
/// ```dart
/// class MyViewModel{
///   final number = 0.rx;
///   final text = "hello".rx;
/// }
/// ```
///
/// An [RxValue] can be used as a property of [RxViewModel], or with any [RxBase]
/// or even services (if the init and dispose function is not needed), to inject
/// it through inherited widget.
///
/// An [RxValue] property can be get by:
///
/// ```dart
/// RxValueBuilder(
///   value: context.read<MyModel>().number,
///   // builder function will be called each time the value is set.
///   builder: (context, value){
///     return ElevatedButton(
///       onPressed: (){
///         myViewModel.increase();
///       }
///       child: Text("$value"),
///     );
///   }
/// ),
/// ```
///
/// ... given that MyModel have been provided to this subtree with providers.
class RxValue<T> extends RxBase<T> {
  RxValue(this.initialValue) : super(BehaviorSubject<T>.seeded(initialValue));

  /// Initial value of the stream
  final T initialValue;

  /// The subject this RxValue will use, because built on rxdart, those subject
  /// maybe:
  /// * [PublishSubject] for [RxViewModel] and notifications
  /// * [BehaviorSubject] for [RxBloc], [RxCubit], [RxValue]
  @override
  @protected
  BehaviorSubject<T> get _subject => _stateSubject as BehaviorSubject<T>;

  /// Whether to skip the first build trigger by stream, for when using
  /// [BehaviorSubject], the first state rebuild is not really necessary and
  /// can be optimized by this variable.
  @override
  bool get _shouldSkipFirstBuild => true;

  T get value => _subject.valueOrNull ?? initialValue;

  /// Signature function of [RxValue], calling this will cause all of
  /// [RxValueBuilder] that dependent on this object to be rebuilt.
  set value(T value) => _stateChanged(value);

  /// The state stream of this will be distinct, two consecutive state of the
  /// same value will not be emitted two time.
  @override
  Stream<T> get stateStream => _subject.stream.distinct();

  /// Delegate to [value].
  @override
  T get state => value;
}
