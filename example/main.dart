import 'package:flutter/material.dart';
import 'package:inherited_rxdart/inherited_rxdart.dart';

void main() => runApp(const App());

@immutable
class MyState {
  final int number;
  final String text;

  const MyState({required this.number, required this.text});

  MyState copyWith({int? number, String? text}) {
    return MyState(number: number ?? this.number, text: text ?? this.text);
  }
}

class CounterBloc extends RxBloc<MyState, String> {
  CounterBloc(MyState initialState) : super(initialState);

  void showDialog() {
    notify("showDialog");
  }

  void changeText(String newText) {
    state = state.copyWith(text: newText);
  }

  void increase() {
    state = state.copyWith(number: state.number + 1);
  }

  void decrease() {
    state = state.copyWith(number: state.number - 1);
  }
}

class CounterBloc2 extends RxCubit<int> {
  CounterBloc2(int initialState) : super(initialState);

  void increase() {
    state++;
  }

  void decrease() {
    state--;
  }
}

class CounterViewModel extends RxViewModel {
  int num;
  int num2;

  CounterViewModel(this.num, [this.num2 = 0]);

  void increase() {
    num++;
    num2++;
    stateChanged();
  }

  void decrease() {
    num--;
    // num2--;
    stateChanged();
  }
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RxMultiProvider(
        providers: [
          RxProvider<CounterBloc>(
              create: () => CounterBloc(const MyState(text: "hi", number: 0))),
          RxProvider<CounterBloc2>(create: () => CounterBloc2(10)),
          RxProvider<CounterViewModel>(
            create: () => CounterViewModel(20),
          ),
        ],
        child: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("build MyHomePage");
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MyCounter(),
            RxSelector<CounterBloc, MyState, String>(
                stateRebuildSelector: (state) {
              return state.text;
            }, builder: (context, value) {
              debugPrint("build Text");
              return Text("state text: $value");
            }),
            RxViewModelSelector<CounterViewModel, int>(
                stateRebuildSelector: (state) {
              return state.num2;
            }, builder: (context, value) {
              debugPrint("build num2");
              return Text("state num2: $value");
            }),
            TextField(
              onSubmitted: (value) {
                RxProvider.of<CounterBloc>(context, listen: false)
                    .changeText(value);
              },
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                    onPressed: () {
                      RxProvider.of<CounterBloc>(context, listen: false)
                          .increase();
                      RxProvider.of<CounterBloc2>(context, listen: false)
                          .increase();
                      RxProvider.of<CounterViewModel>(context, listen: false)
                          .increase();
                    },
                    child: const Text("Increase")),
                ElevatedButton(
                    onPressed: () {
                      RxProvider.of<CounterBloc>(context, listen: false)
                          .decrease();
                      RxProvider.of<CounterBloc2>(context, listen: false)
                          .decrease();
                      RxProvider.of<CounterViewModel>(context, listen: false)
                          .decrease();
                    },
                    child: const Text("Decrease")),
              ],
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                    return RxProvider.value(
                        value:
                            RxProvider.of<CounterBloc>(context, listen: false),
                        child: const MyNested());
                  }));
                },
                child: const Text("New Screen")),
          ],
        ),
      ),
    );
  }
}

class MyCounter extends StatelessWidget {
  const MyCounter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("build MyCounter");
    return RxListener<CounterBloc, MyState, String>(
      stateCallback: (context, state) {
        debugPrint(
            "from RxBlocListener: CounterBloc/${state.number}/${state.text}");
      },
      child: RxStateListener<CounterBloc2, int>(
        stateCallback: (context, state) {
          debugPrint("from RxStateListener: CounterBloc2/$state");
        },
        child: RxStateListener<CounterBloc, MyState>(
          stateCallback: (context, state) {
            debugPrint(
                "from RxStateListener: CounterBloc/${state.number}/${state.text}");
          },
          child: RxViewModelListener<CounterViewModel>(
            stateCallback: (context, state) {
              debugPrint(
                  "from RxStateListener: CounterBloc3/${state.num}/${state.num2}");
            },
            child: Column(
              children: [
                RxBuilder<CounterBloc, MyState>(
                  builder: (context, state) {
                    debugPrint("build Number 1");
                    return Text('counter bloc 1:  ${state.number}');
                  },
                  shouldRebuildWidget: (prev, curr) {
                    return prev.number != curr.number;
                  },
                ),
                RxBuilder<CounterBloc2, int>(
                  builder: (context, state) {
                    debugPrint("build Number 2");
                    return Text('counter bloc 2:  $state');
                  },
                  shouldRebuildWidget: (prev, curr) {
                    return curr < 10;
                  },
                ),
                RxViewModelBuilder<CounterViewModel>(
                  builder: (context, state) {
                    debugPrint("build Number 3");
                    return Text('counter bloc 3:  ${state.num}');
                  },
                  shouldRebuildWidget: (state) {
                    return state.num < 20;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyNested extends StatelessWidget {
  const MyNested({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("build MyNested");
    return RxListener<CounterBloc, MyState, String>(
      notificationCallback: (context, notification) {
        if (notification == "showDialog") {
          showDialog(
              context: context,
              builder: (context) {
                return const Dialog(
                  child: Text("This is a dialog"),
                );
              });
        }
      },
      stateCallback: (context, state) {
        debugPrint("this is stateCallback");
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RxBuilder<CounterBloc, MyState>(builder: (context, state) {
                debugPrint("build BlocBuilder 2 ");
                return Text(state.number.toString());
              }),
              ElevatedButton(
                  onPressed: () {
                    RxProvider.of<CounterBloc>(context, listen: false)
                        .showDialog();
                  },
                  child: const Text("show notification")),
            ],
          ),
        ),
      ),
    );
  }
}
