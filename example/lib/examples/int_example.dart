import 'package:flutter/material.dart';
import 'package:undo_redo/undo_redo.dart';

class IntExample extends StatefulWidget {
  const IntExample({super.key});

  @override
  State<IntExample> createState() => _IntExampleState();
}

class _IntExampleState extends State<IntExample> {
  final UndoRedoManager<int> _undoRedoManager = UndoRedoManager<int>();
  int _counter = 0;

  @override
  void initState() {
    _undoRedoManager.initialize(_counter);
    super.initState();
  }

  void _incrementCounter() {
    _counter++;
    _undoRedoManager.captureState(_counter);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("int example"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'you have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    int? undoData = _undoRedoManager.undo();
                    if (undoData != null) {
                      setState(() {
                        _counter = undoData;
                      });
                    }
                  },
                  icon: Icon(
                    Icons.undo,
                    color: _undoRedoManager.canUndo()
                        ? Theme.of(context).colorScheme.primary
                        : Colors.black38,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    int? redoData = _undoRedoManager.redo();
                    if (redoData != null) {
                      setState(() {
                        _counter = redoData;
                      });
                    }
                  },
                  icon: Icon(
                    Icons.redo,
                    color: _undoRedoManager.canRedo()
                        ? Theme.of(context).colorScheme.primary
                        : Colors.black38,
                  ),
                )
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
