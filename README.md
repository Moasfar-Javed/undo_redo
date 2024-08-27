# undo_redo

This is a simple and powerful Dart package that provides easy-to-use undo and redo functionality with additional convenience methods. Whether you're working with simple primitives or complex objects, this package helps you implement undo/redo effortlessly.

## Platform Support

| Android | iOS | MacOS | Web | Linux | Windows |
| :-----: | :-: | :---: | :-: | :---: | :-----: |
|   ✅    | ✅  |  ✅   | ✅  |  ✅   |   ✅    |

## Demo

Explore the live web demo to see the package in action

## Getting Started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  undo_redo: <latest>
```

Import it:

```dart
import 'package:undo_redo/undo_redo.dart';
```

## Usage

#### Example 1 - Primitives
Using the package's UndoRedoManager on primitives.

```dart
final UndoRedoManager<int> _undoRedoManager = UndoRedoManager<int>();

@override
void initState() {
    _undoRedoManager.initialize(0); // Initial state
    super.initState();
}

void _incrementCounter() {
    _counter++;
    _undoRedoManager.captureState(_counter); // Capture the new state
    setState(() {});
}

// Undo the last action
int? undoData = _undoRedoManager.undo();

// Redo the last undone action
int? redoData = _undoRedoManager.redo();

// Reset to the initial state
int? initialData = _undoRedoManager.clearHistory();

// Check if an undo is possible
bool canUndo = _undoRedoManager.canUndo();

// Check if a redo is possible
bool canRedo = _undoRedoManager.canRedo();
```

#### Example 2 - Non-primitives
Using the package's UndoRedoManager on primitives.

Note
> For all non-primitive types you MUST create a deep copy of the data. Since the non-primitive types such as collections, lists and objects are passed by reference they will be overwritten if used as-is

For Lists

```dart
//This refers to the same memory location(s)
List<int> ages = originalAges; 
//This a deep copy and not the same reference in memory
List<int> ages = List.from(originalAges); 
```

For Objects extend the Cloneable interface to provide a simple `clone()` method

```dart
class Staff extends Cloneable<Staff> {
  String name;
  List<int> ratings;

  @override
  Staff clone() {
    return Staff(
      name: name,
      ratings: List.from(ratings),
    );
  }
}
```

Now, you can manage undo/redo for complex objects:

```dart
final UndoRedoManager<Staff> _undoRedoManager = UndoRedoManager<Staff>();
Staff _staff = Staff(name: 'Foo Bar', ratings: [2, 3, 5]);

@override
void initState() {
    _undoRedoManager.initialize(_staff.clone()); // Capture the initial state
    super.initState();
}

void _onValueChange() {
    _undoRedoManager.captureState(_staff.clone()); // Capture the new state
    setState(() {});
}

// Undo the last action
void undo() {
    var undoData = _undoRedoManager.undo();
    if (undoData != null) {
        _staff = undoData.clone(); // Restore to the previous state
    }
}
```
## Contributions

Contributions are welcome! Please feel free to submit a pull request or report issues on the package's GitHub