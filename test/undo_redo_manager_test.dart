import 'package:flutter_test/flutter_test.dart';
import 'package:undo_redo/undo_redo.dart';

void main() {
  group('UndoRedoManager', () {
    late UndoRedoManager<int> undoRedoManager;

    setUp(() {
      undoRedoManager = UndoRedoManager<int>();
      undoRedoManager.initialize(0);
    });

    test('should perform actions and undo multiple times', () {
      undoRedoManager.captureState(1);
      undoRedoManager.captureState(2);
      undoRedoManager.captureState(3);

      expect(undoRedoManager.undo(), equals(2));
      expect(undoRedoManager.undo(), equals(1));
      expect(undoRedoManager.undo(), equals(0));
      expect(undoRedoManager.undo(), isNull);
    });

    test('should redo actions after undo', () {
      undoRedoManager.captureState(1);
      undoRedoManager.captureState(2);
      undoRedoManager.undo();
      undoRedoManager.undo();

      expect(undoRedoManager.redo(), equals(1));
      expect(undoRedoManager.redo(), equals(2));
      expect(undoRedoManager.redo(), isNull);
    });

    test('should handle multiple undos and redos correctly', () {
      undoRedoManager.captureState(1);
      undoRedoManager.captureState(2);
      undoRedoManager.captureState(3);

      undoRedoManager.undo();
      undoRedoManager.undo();

      undoRedoManager.captureState(4);
      undoRedoManager.captureState(5);

      expect(undoRedoManager.undo(), equals(4));
      expect(undoRedoManager.undo(), equals(1));
      expect(undoRedoManager.redo(), equals(4));
      expect(undoRedoManager.redo(), equals(5));
    });

    test('should not allow undo/redo when there are no actions', () {
      expect(undoRedoManager.canUndo(), isFalse);
      expect(undoRedoManager.canRedo(), isFalse);

      expect(undoRedoManager.undo(), isNull);
      expect(undoRedoManager.redo(), isNull);
    });
  });
}
