## 2.2.2

* Fix return type of GetIt.

## 2.2.1

* Remove required in service provider

## 2.2.0

* Add listeners state callback

## 2.1.0

* Add create with context function

## 2.0.0+1

* Format

## 2.0.0

* Remove Rx static class to avoid name clash, it's functionality is now a part of RxProvider
* Make transformer of RxEventDispatcherMixin more flexible

## 1.6.2

* Hotfix context.watch

## 1.6.1

* Hotfix not rebuild as dependency changed.

## 1.6.0+1

* Update doc

## 1.6.0

* Introduce event dispatcher, allow event stream from ui to bloc.

## 1.5.0

* Correct doc
* Change Rx class structure
* Rework import

## 1.4.2

* Edit README, doc
* Change Error classes name

## 1.4.1

* Fix initial value late

## 1.4.0

* Add Rx Static class

## 1.3.0+1

* Format

## 1.3.0

* Builders and Listeners now have a value constructor. Which can take an instance of rx.

## 1.2.0

* Rx now can add/remove listener

## 1.1.1+1

* Edit README

## 1.1.1

* Edit README and add doc

## 1.1.0

* Add RxValue and RxValueBuilder for simple reactive state management.

## 1.0.2

* Upgrade rxdart to ^0.27.0
* Edit README

## 1.0.1

* Hide subject for each bloc
* Add guard check before add state
* Downgrade rxdart to 0.26.0 and cope with its changes

## 1.0.0+1

* Edit example

## 1.0.0

* Change all "SingleState" blocs and related Widget name to "ViewModel"
* Modify README

## 0.0.5+2

* Add more details to README

## 0.0.5+1

* Add doc to main README

## 0.0.5

* Internal changes of RxBlocBase, add function to notify a new state has been emitted.
* Add initialized variable to bloc, to indicate whether it has been initialized.

## 0.0.4

* Remove generic type requirement in RxSingleStateBloc
* Add implementations for Builder, Listener, Consumer of RxSingleStateBloc
* Remove dynamic type of BuilderBase/ListenerBase
* Rework selector/builder implementation (remove unnecessary variable/state/value)

## 0.0.3+2

* Format

## 0.0.3+1

* Removing base export

## 0.0.3

* Rework Listener
* Rework Consumer
* Add doc

## 0.0.2

* Pubspec modification and remove export

## 0.0.1

* Initial development release