import 'package:flutter/material.dart';
import 'package:inherited_rx_dart/inherited_rx_dart.dart';

class MyState {
  final int number;
  final String text;

  const MyState({required this.number, required this.text});

  MyState copyWith({int? number, String? text}) {
    return MyState(number: number ?? this.number, text: text ?? this.text);
  }
}

class CounterBloc extends RxBloc<MyState> with EventDispatcher<String> {
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

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RxProvider<CounterBloc>(
        create: () => CounterBloc(const MyState(text: "hi", number: 10)),
        child: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("build MyHomePage");
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MyCounter(),
            RxSelector<CounterBloc, MyState>(
                shouldRebuildWidget: (state1, state2) {
              return state1.text != state2.text;
            }, builder: (context, state) {
              print("build text");
              return Text("state text: ${state.text}");
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
                    },
                    child: const Text("Increase")),
                ElevatedButton(
                    onPressed: () {
                      RxProvider.of<CounterBloc>(context, listen: false)
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
    print("build MyCounter");
    return RxBuilder<CounterBloc, MyState>(
      builder: (context, state) {
        print("build BlocBuilder");
        return Text(state.number.toString());
      },
    );
  }
}

class MyNested extends StatelessWidget {
  const MyNested({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("build MyNested");
    return RxListener<CounterBloc, String>(
      listener: (context, state) {
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
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RxBuilder<CounterBloc, MyState>(builder: (context, state) {
                print("build BlocBuilder 2 ");
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