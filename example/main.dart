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

class CounterBloc2 extends RxSilentBloc<int> {
  CounterBloc2(int initialState) : super(initialState);

  void increase() {
    state++;
  }

  void decrease() {
    state--;
  }
}

class CounterBloc3 extends RxSingleStateBloc {
  int num;
  int num2;

  CounterBloc3(this.num, [this.num2 = 0]);

  @override
  CounterBloc3 get state => super.state as CounterBloc3;

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
      home: RxProvider<CounterBloc>(
        create: () => CounterBloc(const MyState(text: "hi", number: 10)),
        child: RxProvider<CounterBloc2>(
          create: () => CounterBloc2(10),
          child: RxProvider<CounterBloc3>(
            create: () => CounterBloc3(10),
            child: const MyHomePage(),
          ),
        ),
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
            }, builder: (context, state) {
              debugPrint("build Text");
              return Text("state text: ${state.text}");
            }),
            RxSingleStateSelector<CounterBloc3, int>(
                stateRebuildSelector: (state) {
              return state.num2;
            }, builder: (context, state) {
              debugPrint("build num2");
              return Text("state num2: ${state.num2}");
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
                      RxProvider.of<CounterBloc3>(context, listen: false)
                          .increase();
                    },
                    child: const Text("Increase")),
                ElevatedButton(
                    onPressed: () {
                      RxProvider.of<CounterBloc>(context, listen: false)
                          .decrease();
                      RxProvider.of<CounterBloc2>(context, listen: false)
                          .decrease();
                      RxProvider.of<CounterBloc3>(context, listen: false)
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
    return Column(
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
        RxSingleStateBuilder<CounterBloc3>(
          builder: (context, state) {
            debugPrint("build Number 3");
            return Text('counter bloc 3:  ${state.num}');
          },
          shouldRebuildWidget: (state) {
            return state.num < 20;
          },
        ),
      ],
    );
  }
}

class MyNested extends StatelessWidget {
  const MyNested({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("build MyNested");
    return RxListener<CounterBloc, MyState, String>(
      notificationCallback: (context, state) {
        if (state == "showDialog") {
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
