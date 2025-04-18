/// A generic class that manages undo and redo operations for a stack of actions.
///
/// This class is useful for implementing undo and redo functionality in applications
/// where actions need to be reversible. It maintains two internal stacks: one for undo
/// operations and one for redo operations. The memory can be limited by specifying a
/// [maxMemory] value.
class UndoRedoManager<T> {
  final List<T> _undoStack = [];
  final List<T> _redoStack = [];
  final int? maxMemory;

  /// Creates an undo/redo manager with an optional memory limit.
  ///
  /// If [maxMemory] is specified, it limits the number of states stored in the
  /// undo stack. If `null`, the memory is unlimited.
  ///
  /// Parameters:
  /// - [maxMemory]: The maximum number of states to retain in memory for undo/redo.
  UndoRedoManager({this.maxMemory});

  /// Initializes the undo/redo manager with an initial state.
  ///
  /// This method should be called to set up the initial state before any undo or redo
  /// operations are performed.
  ///
  /// Requires:
  /// - [state]: The initial action to initialize the undo/redo stack with. This must be passed by value.
  void initialize(T state) {
    if (_undoStack.isNotEmpty || _redoStack.isNotEmpty) {
      dispose();
    }
    captureState(state);
  }

  /// Disposes the manager by clearing both undo and redo stacks.
  ///
  /// This method is used to clean up resources when the undo/redo manager is no longer needed.
  void dispose() {
    _undoStack.clear();
    _redoStack.clear();
  }

  /// Adds the state to the undo stack.
  ///
  /// This method should be called every time an action is performed. It clears the redo
  /// stack to ensure that redo operations are only available for actions that have been undone.
  ///
  /// If [maxMemory] is specified, the oldest states are removed to stay within the memory limit.
  ///
  /// Requires:
  /// - [state]: The current state to be added to the undo stack. This must be passed by value.
  void captureState(T state) {
    _undoStack.add(state);
    _redoStack.clear();

    // Enforce memory limit if maxMemory is set
    if (maxMemory != null && _undoStack.length > maxMemory!) {
      _undoStack.removeAt(0); // Remove the oldest state
    }
  }

  /// Undoes the last action and returns the previous state if available.
  ///
  /// If there is a state to undo, it will be removed from the undo stack and added to
  /// the redo stack. The previous state before the undone action will be returned.
  ///
  /// Returns:
  /// - Undone state [T].
  /// - `null` if there is no state to undo.
  T? undo() {
    if (canUndo()) {
      final action = _undoStack.removeLast();
      _redoStack.add(action);
      return _undoStack.isNotEmpty ? _undoStack.last : null;
    }
    return null;
  }

  /// Redoes the last undone action and returns the current state.
  ///
  /// If there is a state to redo, it will be removed from the redo stack and added back
  /// to the undo stack. The redone action will be returned.
  ///
  /// Returns:
  /// - Redone state [T].
  /// - `null` if there is no state to redo.
  T? redo() {
    if (canRedo()) {
      final action = _redoStack.removeLast();
      _undoStack.add(action);
      return action;
    }
    return null;
  }

  /// Checks if there is an action available to undo.
  ///
  /// Returns:
  /// - `true` if there is more than one state in the undo stack, indicating that
  /// an undo operation is possible.
  /// - Otherwise, returns `false`.
  bool canUndo() {
    return _undoStack.length > 1;
  }

  /// Checks if there is an action available to redo.
  ///
  /// Returns:
  /// - `true` if there are states in the redo stack that can be redone.
  /// - Otherwise, returns `false`.
  bool canRedo() {
    return _redoStack.isNotEmpty;
  }

  /// Clears the history of undo and redo actions.
  ///
  /// This method clears both the undo and redo stacks, effectively resetting the
  /// manager. The initial state, if any, is returned after clearing the history.
  ///
  /// Returns:
  /// - The initial state [T] if the undo stack is not empty.
  /// - `null` if the stack was empty.
  T? clearHistory() {
    T? initialState;
    if (_undoStack.isNotEmpty) {
      initialState = _undoStack.first;
    }

    _undoStack.clear();
    _redoStack.clear();
    return initialState;
  }

  /// Gets the history of undo-able actions.
  ///
  /// Returns:
  /// - The state history as [List<T>]
  List<T> history() {
    return _undoStack;
  }
}
