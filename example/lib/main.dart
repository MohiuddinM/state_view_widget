import 'package:flutter/material.dart';
import 'package:state_view_widget/state_view_widget.dart';

void main() {
  runApp(MaterialApp(home: const CounterApp()));
}

class CounterApp extends StateViewWidget<CounterApp> {
  const CounterApp({super.key});

  @override
  CounterAppState get state => CounterAppState();

  @override
  CounterAppView get view => const CounterAppView(title: 'CounterApp');
}

@StateClass()
class CounterAppState extends StateOf<CounterApp> {
  int _counter = 0;
  int? _c;
  late String _title;
  var _list;
  late List<int> _nonlist;
  Widget? _k;
  late Map<int, Widget> _map;
}

class CounterAppView extends ViewOf<CounterApp, CounterAppState> {
  const CounterAppView({required this.title, super.key});

  final String title;

  @override
  Widget buildView(BuildContext context, CounterAppState state) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '${state.list}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          state.counter++;
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
