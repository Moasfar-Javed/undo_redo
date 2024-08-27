import 'package:flutter_test/flutter_test.dart';
import 'package:undo_redo/undo_redo.dart';

class TestCloneable implements Cloneable<TestCloneable> {
  final int value;
  final String text;

  TestCloneable(this.value, this.text);

  @override
  TestCloneable clone() {
    return TestCloneable(value, text);
  }
}

void main() {
  group('Cloneable', () {
    test('should create a clone with the same values', () {
      final original = TestCloneable(42, 'Hello');
      final clone = original.clone();

      expect(clone.value, equals(original.value));
      expect(clone.text, equals(original.text));
      expect(
          clone, isNot(same(original))); // Ensure clone is a different instance
    });

    test('should handle cloning of empty and default values', () {
      final original = TestCloneable(0, '');
      final clone = original.clone();

      expect(clone.value, equals(original.value));
      expect(clone.text, equals(original.text));
      expect(
          clone, isNot(same(original))); // Ensure clone is a different instance
    });

    test('should handle cloning of objects with complex types', () {
      final original = TestCloneable(42, 'Hello');
      final clone = original.clone();

      expect(clone,
          isNot(equals(original))); // Ensure the clone is a different object
      expect(clone.value, equals(42));
      expect(clone.text, equals('Hello'));
    });

    test('should clone correctly for different instances', () {
      final original1 = TestCloneable(1, 'A');
      final original2 = TestCloneable(2, 'B');

      final clone1 = original1.clone();
      final clone2 = original2.clone();

      expect(clone1.value, equals(original1.value));
      expect(clone1.text, equals(original1.text));
      expect(clone2.value, equals(original2.value));
      expect(clone2.text, equals(original2.text));
      expect(
          clone1,
          isNot(same(
              clone2))); // Ensure clones of different instances are not the same
    });
  });
}
