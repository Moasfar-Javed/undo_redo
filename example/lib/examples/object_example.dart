import 'package:example/models/staff.dart';
import 'package:flutter/material.dart';
import 'package:undo_redo/undo_redo.dart';

class ObjectExample extends StatefulWidget {
  const ObjectExample({super.key});

  @override
  State<ObjectExample> createState() => _ObjectExampleState();
}

class _ObjectExampleState extends State<ObjectExample> {
  final UndoRedoManager<Staff> _undoRedoManager = UndoRedoManager<Staff>();
  Staff _staff = Staff(name: 'Foo Bar', ratings: [2, 3, 5]);
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    _populateControllers();
    _undoRedoManager.initialize(_staff.clone());

    _nameController.addListener(() {
      if (_nameController.text != _staff.name) {
        _staff.name = _nameController.text;
        _onValueChange();
      }
    });

    super.initState();
  }

  _populateControllers() {
    _nameController.text = _staff.name;
  }

  void _onValueChange() {
    _undoRedoManager.captureState(_staff.clone());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("object example"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'staff details:',
              ),
              TextField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(
                height: 20,
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'rig reviews here 😏:',
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDropdown(_staff.ratings[0], (value) {
                    if (value != null) {
                      _staff.ratings[0] = value;
                      _onValueChange();
                    }
                  }),
                  _buildDropdown(_staff.ratings[1], (value) {
                    if (value != null) {
                      _staff.ratings[1] = value;
                      _onValueChange();
                    }
                  }),
                  _buildDropdown(_staff.ratings[2], (value) {
                    if (value != null) {
                      _staff.ratings[2] = value;
                      _onValueChange();
                    }
                  }),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      var undoData = _undoRedoManager.undo();

                      if (undoData != null) {
                        _staff = undoData.clone();
                        _populateControllers();
                        setState(() {});
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
                      var redoData = _undoRedoManager.redo();
                      if (redoData != null) {
                        _staff = redoData.clone();
                        _populateControllers();
                        setState(() {});
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var initialData = _undoRedoManager.clearHistory();
          if (initialData != null) {
            _staff = initialData.clone();
            _populateControllers();
            setState(() {});
          }
        },
        tooltip: 'Reset',
        child: const Icon(Icons.restart_alt),
      ),
    );
  }

  Widget _buildDropdown(
    int value,
    Function(int?) onChanged,
  ) {
    return DropdownButton<int>(
      value: value,
      onChanged: onChanged,
      items: [1, 2, 3, 4, 5].map<DropdownMenuItem<int>>((int val) {
        return DropdownMenuItem<int>(
          value: val,
          child: Text(val.toString()),
        );
      }).toList(),
    );
  }
}
