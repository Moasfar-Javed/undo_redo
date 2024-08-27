import 'package:flutter/material.dart';
import 'package:undo_redo/undo_redo.dart';

class ListExample extends StatefulWidget {
  const ListExample({super.key});

  @override
  State<ListExample> createState() => _ListExampleState();
}

class _ListExampleState extends State<ListExample> {
  final UndoRedoManager<List<double>> _undoRedoManager =
      UndoRedoManager<List<double>>();
  List<double> _sliderValues = [0.0, 0.0];

  @override
  void initState() {
    _undoRedoManager.initialize(List.from(_sliderValues));
    super.initState();
  }

  void _onValueChange() {
    _undoRedoManager.captureState(List.from(_sliderValues));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("list example"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'adjust the sliders: [${_sliderValues.first.toStringAsFixed(2)}, ${_sliderValues.last.toStringAsFixed(2)}]',
            ),
            Slider(
              value: _sliderValues.first,
              onChanged: (value) {
                setState(() {
                  _sliderValues.first = value;
                });
                _onValueChange();
              },
            ),
            Slider(
              value: _sliderValues.last,
              onChanged: (value) {
                setState(() {
                  _sliderValues.last = value;
                });
                _onValueChange();
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    List<double>? undoData = _undoRedoManager.undo();
                    if (undoData != null) {
                      setState(() {
                        _sliderValues = List.from(undoData);
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
                    List<double>? redoData = _undoRedoManager.redo();
                    if (redoData != null) {
                      setState(() {
                        _sliderValues = List.from(redoData);
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
        onPressed: () {
          List<double>? initialData = _undoRedoManager.clearHistory();
          if (initialData != null) {
            setState(() {
              _sliderValues = List.from(initialData);
            });
          }
        },
        tooltip: 'Reset',
        child: const Icon(Icons.restart_alt),
      ),
    );
  }
}
