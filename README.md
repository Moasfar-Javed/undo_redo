# undo_redo
[![undo_redo](https://github.com/moasfar-javed/undo_redo/actions/workflows/dart.yml/badge.svg)](https://github.com/fluttercommunity/plus_plugins/actions/workflows/share_plus.yaml)
[![pub points](https://img.shields.io/pub/points/undo_redo?color=2E8B57&label=pub%20points)](https://pub.dev/packages/lines_of_code/score)
[![pub package](https://img.shields.io/pub/v/undo_redo.svg)](https://pub.dev/packages/lines_of_code)

This is a simple and powerful Dart package that provides easy-to-use undo and redo functionality with additional convenience methods. Whether you're working with simple primitives or complex objects, this package helps you implement undo/redo effortlessly.

## Platforms

| Android | iOS | MacOS | Web | Linux | Windows |
| :-----: | :-: | :---: | :-: | :---: | :-----: |
|   ✅    | ✅  |  ✅   | ✅  |  ✅   |   ✅    |

## Demo

Explore the [live web demo](https://undo-redo.dijinx.com) to see the package in action

<div style="display: flex; justify-content: space-between;">
    <img src="https://media.giphy.com/media/iW9U8xDb8SMFEreLxv/giphy.gif" alt="Basic example using integers" style="width: 32%;"/>
    <img src="https://media.giphy.com/media/DVkeKmZS8riMYb8EPb/giphy.gif" alt="Deep copy example using list" style="width: 32%;"/>
    <img src="https://media.giphy.com/media/tnXGfJze1OpGJxiBjk/giphy.gif" alt="Deep copy example using custom object" style="width: 32%;"/>
</div>

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

#### Example 1: Undo/Redo with Primitives
Managing state changes with primitive types is straightforward:

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

#### Example 2: Undo/Redo with Non-Primitives

> When working with non-primitive types such as objects or collections, you must use a deep copy to ensure that state changes are independent

##### For Lists

```dart
//This refers to the same memory location(s)
List<int> ages = originalAges; 
//This a deep copy and not the same reference in memory
List<int> ages = List.from(originalAges); 
```
##### For Custom Objects
Extend the `Cloneable` class to provide a deep copy method:

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

###### Alternatively
Use the `CloneableMixin` if you are already extending a class:

```dart
class Staff extends People with CloneableMixin<Staff> {
  ...
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

Contributions are welcome! Please feel free to submit a pull request or report issues on the [package's GitHub](https://github.com/Moasfar-Javed/undo_redo)
