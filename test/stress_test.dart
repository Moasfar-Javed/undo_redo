import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:undo_redo/undo_redo.dart';

// ---------------------------------------------------------------------------
// Complex model definitions
// ---------------------------------------------------------------------------

/// Simulates a rich document with nested sections, paragraphs, and formatting.
class Document extends Cloneable<Document> {
  final String title;
  final Map<String, dynamic> metadata;
  final List<Section> sections;

  Document({
    required this.title,
    required this.metadata,
    required this.sections,
  });

  @override
  Document clone() {
    return Document(
      title: title,
      metadata: _deepCloneMap(metadata),
      sections: sections.map((s) => s.clone()).toList(),
    );
  }

  static Map<String, dynamic> _deepCloneMap(Map<String, dynamic> original) {
    final result = <String, dynamic>{};
    for (final entry in original.entries) {
      if (entry.value is Map<String, dynamic>) {
        result[entry.key] = _deepCloneMap(entry.value as Map<String, dynamic>);
      } else if (entry.value is List) {
        result[entry.key] = List.from(entry.value as List);
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  int get estimatedFieldCount {
    int count = 2 + metadata.length; // title + metadata entries
    for (final s in sections) {
      count += 2; // heading + paragraphs list
      for (final p in s.paragraphs) {
        count += 1 + p.formatting.length;
      }
    }
    return count;
  }
}

class Section extends Cloneable<Section> {
  final String heading;
  final List<Paragraph> paragraphs;

  Section({required this.heading, required this.paragraphs});

  @override
  Section clone() {
    return Section(
      heading: heading,
      paragraphs: paragraphs.map((p) => p.clone()).toList(),
    );
  }
}

class Paragraph extends Cloneable<Paragraph> {
  final String text;
  final Map<String, bool> formatting; // bold, italic, underline, etc.

  Paragraph({required this.text, required this.formatting});

  @override
  Paragraph clone() {
    return Paragraph(
      text: text,
      formatting: Map.from(formatting),
    );
  }
}

/// Simulates a spreadsheet with rows and cells containing various data types.
class Spreadsheet extends Cloneable<Spreadsheet> {
  final String name;
  final List<List<Cell>> rows;

  Spreadsheet({required this.name, required this.rows});

  @override
  Spreadsheet clone() {
    return Spreadsheet(
      name: name,
      rows: rows
          .map((row) => row.map((cell) => cell.clone()).toList())
          .toList(),
    );
  }

  int get cellCount => rows.fold(0, (sum, row) => sum + row.length);
}

class Cell extends Cloneable<Cell> {
  final dynamic value;
  final String type; // 'string', 'number', 'formula', 'date'
  final Map<String, dynamic> style;

  Cell({required this.value, required this.type, required this.style});

  @override
  Cell clone() {
    return Cell(
      value: value,
      type: type,
      style: Map.from(style),
    );
  }
}

/// Simulates a canvas with many drawable elements (shapes, images, text).
class Canvas extends Cloneable<Canvas> {
  final int width;
  final int height;
  final List<CanvasElement> elements;
  final Map<String, List<int>> layers; // layer name -> element indices

  Canvas({
    required this.width,
    required this.height,
    required this.elements,
    required this.layers,
  });

  @override
  Canvas clone() {
    return Canvas(
      width: width,
      height: height,
      elements: elements.map((e) => e.clone()).toList(),
      layers: layers.map((k, v) => MapEntry(k, List<int>.from(v))),
    );
  }
}

class CanvasElement extends Cloneable<CanvasElement> {
  final String type; // 'rect', 'circle', 'text', 'image', 'path'
  final Map<String, double> position; // x, y, width, height, rotation
  final Map<String, dynamic> properties; // fill, stroke, opacity, etc.
  final List<double> pathData; // for complex paths

  CanvasElement({
    required this.type,
    required this.position,
    required this.properties,
    required this.pathData,
  });

  @override
  CanvasElement clone() {
    return CanvasElement(
      type: type,
      position: Map<String, double>.from(position),
      properties: Map<String, dynamic>.from(properties),
      pathData: List<double>.from(pathData),
    );
  }
}

/// Deeply nested tree structure to stress recursive cloning.
class TreeNode extends Cloneable<TreeNode> {
  final String id;
  final Map<String, dynamic> data;
  final List<TreeNode> children;

  TreeNode({required this.id, required this.data, required this.children});

  @override
  TreeNode clone() {
    return TreeNode(
      id: id,
      data: Map<String, dynamic>.from(data),
      children: children.map((c) => c.clone()).toList(),
    );
  }

  int get totalNodes {
    int count = 1;
    for (final child in children) {
      count += child.totalNodes;
    }
    return count;
  }

  int get depth {
    if (children.isEmpty) return 1;
    return 1 + children.map((c) => c.depth).reduce(max);
  }
}

/// Large binary-like payload (e.g., image editing with pixel data).
class BinaryPayload extends Cloneable<BinaryPayload> {
  final String label;
  final List<int> data;
  final Map<String, int> offsets;

  BinaryPayload(
      {required this.label, required this.data, required this.offsets});

  @override
  BinaryPayload clone() {
    return BinaryPayload(
      label: label,
      data: List<int>.from(data),
      offsets: Map<String, int>.from(offsets),
    );
  }
}

// ---------------------------------------------------------------------------
// Factories for generating test data at configurable scales
// ---------------------------------------------------------------------------

final _random = Random(42); // deterministic seed

String _randomString(int length) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789 ';
  return List.generate(length, (_) => chars[_random.nextInt(chars.length)])
      .join();
}

Document buildDocument({int sections = 10, int paragraphsPerSection = 20}) {
  return Document(
    title: _randomString(50),
    metadata: {
      'author': _randomString(20),
      'created': DateTime.now().toIso8601String(),
      'tags': List.generate(10, (_) => _randomString(8)),
      'settings': {
        'font': 'Arial',
        'size': 12,
        'margins': {'top': 1.0, 'bottom': 1.0, 'left': 0.75, 'right': 0.75},
      },
    },
    sections: List.generate(
      sections,
      (i) => Section(
        heading: _randomString(30),
        paragraphs: List.generate(
          paragraphsPerSection,
          (j) => Paragraph(
            text: _randomString(200),
            formatting: {
              'bold': _random.nextBool(),
              'italic': _random.nextBool(),
              'underline': _random.nextBool(),
              'strikethrough': _random.nextBool(),
              'highlight': _random.nextBool(),
            },
          ),
        ),
      ),
    ),
  );
}

Spreadsheet buildSpreadsheet({int rows = 100, int cols = 50}) {
  return Spreadsheet(
    name: 'Sheet-${_random.nextInt(1000)}',
    rows: List.generate(
      rows,
      (r) => List.generate(
        cols,
        (c) {
          final types = ['string', 'number', 'formula', 'date'];
          final type = types[_random.nextInt(types.length)];
          dynamic value;
          switch (type) {
            case 'string':
              value = _randomString(20);
              break;
            case 'number':
              value = _random.nextDouble() * 10000;
              break;
            case 'formula':
              value = '=SUM(A${r + 1}:Z${r + 1})';
              break;
            case 'date':
              value = DateTime.now()
                  .add(Duration(days: _random.nextInt(365)))
                  .toIso8601String();
              break;
          }
          return Cell(
            value: value,
            type: type,
            style: {
              'bgColor': '#${_random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
              'fontSize': 10 + _random.nextInt(6),
              'bold': _random.nextBool(),
            },
          );
        },
      ),
    ),
  );
}

Canvas buildCanvas({int elementCount = 500}) {
  final elements = List.generate(
    elementCount,
    (i) {
      final types = ['rect', 'circle', 'text', 'image', 'path'];
      final type = types[_random.nextInt(types.length)];
      return CanvasElement(
        type: type,
        position: {
          'x': _random.nextDouble() * 1920,
          'y': _random.nextDouble() * 1080,
          'width': _random.nextDouble() * 500,
          'height': _random.nextDouble() * 500,
          'rotation': _random.nextDouble() * 360,
        },
        properties: {
          'fill': '#${_random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
          'stroke': '#${_random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
          'strokeWidth': _random.nextDouble() * 5,
          'opacity': _random.nextDouble(),
          'shadow': _random.nextBool(),
          'blur': _random.nextDouble() * 10,
        },
        pathData: type == 'path'
            ? List.generate(200, (_) => _random.nextDouble() * 1000)
            : [],
      );
    },
  );

  return Canvas(
    width: 1920,
    height: 1080,
    elements: elements,
    layers: {
      'background': List.generate(
          elementCount ~/ 3, (i) => _random.nextInt(elementCount)),
      'foreground': List.generate(
          elementCount ~/ 3, (i) => _random.nextInt(elementCount)),
      'ui': List.generate(
          elementCount ~/ 3, (i) => _random.nextInt(elementCount)),
    },
  );
}

TreeNode buildTree({int depth = 5, int branchFactor = 4}) {
  if (depth <= 0) {
    return TreeNode(
      id: 'leaf-${_random.nextInt(100000)}',
      data: {'value': _random.nextDouble(), 'label': _randomString(15)},
      children: [],
    );
  }
  return TreeNode(
    id: 'node-$depth-${_random.nextInt(100000)}',
    data: {
      'value': _random.nextDouble(),
      'label': _randomString(15),
      'tags': List.generate(3, (_) => _randomString(5)),
    },
    children:
        List.generate(branchFactor, (_) => buildTree(depth: depth - 1, branchFactor: branchFactor)),
  );
}

BinaryPayload buildBinaryPayload({int sizeBytes = 100000}) {
  return BinaryPayload(
    label: _randomString(20),
    data: List.generate(sizeBytes, (_) => _random.nextInt(256)),
    offsets: {
      for (var i = 0; i < 100; i++) 'chunk_$i': _random.nextInt(sizeBytes),
    },
  );
}

// ---------------------------------------------------------------------------
// Benchmark helper
// ---------------------------------------------------------------------------

class BenchmarkResult {
  final String label;
  final Duration elapsed;
  final int operations;

  BenchmarkResult(this.label, this.elapsed, this.operations);

  double get opsPerSecond =>
      operations / (elapsed.inMicroseconds / 1000000.0);
  double get avgMicrosPerOp => elapsed.inMicroseconds / operations;

  @override
  String toString() =>
      '$label: ${elapsed.inMilliseconds}ms total, '
      '${avgMicrosPerOp.toStringAsFixed(1)}µs/op, '
      '${opsPerSecond.toStringAsFixed(0)} ops/s '
      '($operations ops)';
}

BenchmarkResult benchmark(String label, int ops, void Function() fn) {
  final sw = Stopwatch()..start();
  for (var i = 0; i < ops; i++) {
    fn();
  }
  sw.stop();
  return BenchmarkResult(label, sw.elapsed, ops);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // GROUP 1: Correctness with complex objects
  // =========================================================================
  group('Complex object correctness', () {
    test('Document: capture, undo, redo preserves deep state', () {
      final manager = UndoRedoManager<Document>();
      final doc1 = buildDocument(sections: 3, paragraphsPerSection: 5);
      manager.initialize(doc1.clone());

      // Mutate and capture
      final doc2 = doc1.clone();
      doc2.sections[0].paragraphs[0] = Paragraph(
        text: 'CHANGED',
        formatting: {'bold': true},
      );
      manager.captureState(doc2.clone());

      final doc3 = doc2.clone();
      doc3.sections.add(Section(heading: 'NEW', paragraphs: []));
      manager.captureState(doc3.clone());

      // Undo back to doc2
      final undone = manager.undo()!;
      expect(undone.sections.length, equals(doc2.sections.length));
      expect(undone.sections[0].paragraphs[0].text, equals('CHANGED'));

      // Undo back to doc1
      final undone2 = manager.undo()!;
      expect(undone2.sections.length, equals(doc1.sections.length));
      expect(undone2.sections[0].paragraphs[0].text,
          equals(doc1.sections[0].paragraphs[0].text));

      // Redo forward to doc2
      final redone = manager.redo()!;
      expect(redone.sections[0].paragraphs[0].text, equals('CHANGED'));
    });

    test('Spreadsheet: cell-level undo/redo accuracy', () {
      final manager = UndoRedoManager<Spreadsheet>();
      final sheet1 = buildSpreadsheet(rows: 10, cols: 10);
      manager.initialize(sheet1.clone());

      final originalValue = sheet1.rows[5][5].value;

      final sheet2 = sheet1.clone();
      sheet2.rows[5][5] = Cell(value: 'EDITED', type: 'string', style: {});
      manager.captureState(sheet2.clone());

      final undone = manager.undo()!;
      expect(undone.rows[5][5].value, equals(originalValue));

      final redone = manager.redo()!;
      expect(redone.rows[5][5].value, equals('EDITED'));
    });

    test('Canvas: element mutations are isolated across states', () {
      final manager = UndoRedoManager<Canvas>();
      final canvas1 = buildCanvas(elementCount: 50);
      manager.initialize(canvas1.clone());

      final canvas2 = canvas1.clone();
      canvas2.elements.add(CanvasElement(
        type: 'rect',
        position: {'x': 0, 'y': 0, 'width': 100, 'height': 100, 'rotation': 0},
        properties: {'fill': '#ff0000'},
        pathData: [],
      ));
      manager.captureState(canvas2.clone());

      expect(manager.undo()!.elements.length, equals(50));
      expect(manager.redo()!.elements.length, equals(51));
    });

    test('TreeNode: deep recursive clone preserves full subtree', () {
      final manager = UndoRedoManager<TreeNode>();
      final tree1 = buildTree(depth: 3, branchFactor: 3);
      final originalNodeCount = tree1.totalNodes;
      manager.initialize(tree1.clone());

      // Add a child to root
      final tree2 = tree1.clone();
      tree2.children.add(TreeNode(id: 'new', data: {'x': 1}, children: []));
      manager.captureState(tree2.clone());

      final undone = manager.undo()!;
      expect(undone.totalNodes, equals(originalNodeCount));
      expect(undone.children.length, equals(tree1.children.length));

      final redone = manager.redo()!;
      expect(redone.totalNodes, equals(originalNodeCount + 1));
    });

    test('BinaryPayload: large byte array clone is independent', () {
      final manager = UndoRedoManager<BinaryPayload>();
      final bp1 = buildBinaryPayload(sizeBytes: 50000);
      manager.initialize(bp1.clone());

      final bp2 = bp1.clone();
      // Flip all bytes
      for (var i = 0; i < bp2.data.length; i++) {
        bp2.data[i] = 255 - bp2.data[i];
      }
      manager.captureState(bp2.clone());

      final undone = manager.undo()!;
      // Original should be unchanged
      expect(undone.data[0], equals(bp1.data[0]));
      expect(undone.data[49999], equals(bp1.data[49999]));
    });

    test('maxMemory enforced with complex objects', () {
      final manager = UndoRedoManager<Document>(maxMemory: 5);
      final docs = List.generate(
          10, (_) => buildDocument(sections: 2, paragraphsPerSection: 3));

      manager.initialize(docs[0].clone());
      for (var i = 1; i < 10; i++) {
        manager.captureState(docs[i].clone());
      }

      // Should only be able to undo 4 times (5 states, current + 4 previous)
      int undoCount = 0;
      while (manager.canUndo()) {
        manager.undo();
        undoCount++;
      }
      expect(undoCount, equals(4));
    });
  });

  // =========================================================================
  // GROUP 2: Clone performance benchmarks
  // =========================================================================
  group('Clone performance', () {
    test('Document clone timing at various scales', () {
      final configs = [
        (sections: 5, paragraphs: 10, label: 'small (50 paragraphs)'),
        (sections: 20, paragraphs: 50, label: 'medium (1K paragraphs)'),
        (sections: 50, paragraphs: 100, label: 'large (5K paragraphs)'),
        (sections: 100, paragraphs: 200, label: 'huge (20K paragraphs)'),
      ];

      for (final cfg in configs) {
        final doc = buildDocument(
            sections: cfg.sections, paragraphsPerSection: cfg.paragraphs);
        final result = benchmark('Document clone [${cfg.label}]', 50, () {
          doc.clone();
        });
        // ignore: avoid_print
        print(result);
        // Even the huge doc should clone in under 500ms per op
        expect(result.avgMicrosPerOp, lessThan(500000));
      }
    });

    test('Spreadsheet clone timing at various scales', () {
      final configs = [
        (rows: 50, cols: 20, label: '1K cells'),
        (rows: 100, cols: 50, label: '5K cells'),
        (rows: 200, cols: 100, label: '20K cells'),
        (rows: 500, cols: 100, label: '50K cells'),
      ];

      for (final cfg in configs) {
        final sheet =
            buildSpreadsheet(rows: cfg.rows, cols: cfg.cols);
        final result = benchmark('Spreadsheet clone [${cfg.label}]', 20, () {
          sheet.clone();
        });
        // ignore: avoid_print
        print(result);
        expect(result.avgMicrosPerOp, lessThan(2000000));
      }
    });

    test('Canvas clone timing at various scales', () {
      final configs = [
        (elements: 100, label: '100 elements'),
        (elements: 1000, label: '1K elements'),
        (elements: 5000, label: '5K elements'),
        (elements: 10000, label: '10K elements'),
      ];

      for (final cfg in configs) {
        final canvas = buildCanvas(elementCount: cfg.elements);
        final result = benchmark('Canvas clone [${cfg.label}]', 20, () {
          canvas.clone();
        });
        // ignore: avoid_print
        print(result);
        expect(result.avgMicrosPerOp, lessThan(5000000));
      }
    });

    test('TreeNode clone timing at various depths', () {
      final configs = [
        (depth: 3, branch: 3, label: 'shallow (40 nodes)'),
        (depth: 5, branch: 3, label: 'medium (364 nodes)'),
        (depth: 4, branch: 5, label: 'wide (781 nodes)'),
        (depth: 6, branch: 3, label: 'deep (1093 nodes)'),
      ];

      for (final cfg in configs) {
        final tree = buildTree(depth: cfg.depth, branchFactor: cfg.branch);
        // ignore: avoid_print
        print(
            'Tree [${cfg.label}]: actual ${tree.totalNodes} nodes, depth ${tree.depth}');
        final result = benchmark('Tree clone [${cfg.label}]', 50, () {
          tree.clone();
        });
        // ignore: avoid_print
        print(result);
        expect(result.avgMicrosPerOp, lessThan(2000000));
      }
    });

    test('BinaryPayload clone timing at various sizes', () {
      final configs = [
        (size: 10000, label: '10KB'),
        (size: 100000, label: '100KB'),
        (size: 1000000, label: '1MB'),
        (size: 5000000, label: '5MB'),
      ];

      for (final cfg in configs) {
        final payload = buildBinaryPayload(sizeBytes: cfg.size);
        final result =
            benchmark('BinaryPayload clone [${cfg.label}]', 20, () {
          payload.clone();
        });
        // ignore: avoid_print
        print(result);
      }
    });
  });

  // =========================================================================
  // GROUP 3: Manager operation benchmarks (capture/undo/redo throughput)
  // =========================================================================
  group('Manager operation throughput', () {
    test('captureState throughput with Documents', () {
      final manager = UndoRedoManager<Document>();
      final doc = buildDocument(sections: 10, paragraphsPerSection: 20);
      manager.initialize(doc.clone());

      final result = benchmark('captureState (Document)', 500, () {
        manager.captureState(doc.clone());
      });
      // ignore: avoid_print
      print(result);
    });

    test('captureState throughput with Spreadsheets', () {
      final manager = UndoRedoManager<Spreadsheet>();
      final sheet = buildSpreadsheet(rows: 100, cols: 50);
      manager.initialize(sheet.clone());

      final result = benchmark('captureState (Spreadsheet)', 200, () {
        manager.captureState(sheet.clone());
      });
      // ignore: avoid_print
      print(result);
    });

    test('undo throughput with large history', () {
      final manager = UndoRedoManager<Document>();
      final doc = buildDocument(sections: 5, paragraphsPerSection: 10);

      // Build up a large history
      manager.initialize(doc.clone());
      for (var i = 0; i < 1000; i++) {
        manager.captureState(doc.clone());
      }

      final sw = Stopwatch()..start();
      int undoOps = 0;
      while (manager.canUndo()) {
        manager.undo();
        undoOps++;
      }
      sw.stop();
      // ignore: avoid_print
      print(BenchmarkResult('undo (1K Document history)', sw.elapsed, undoOps));
    });

    test('redo throughput after full undo', () {
      final manager = UndoRedoManager<Document>();
      final doc = buildDocument(sections: 5, paragraphsPerSection: 10);

      manager.initialize(doc.clone());
      for (var i = 0; i < 1000; i++) {
        manager.captureState(doc.clone());
      }
      // Undo everything
      while (manager.canUndo()) {
        manager.undo();
      }

      final sw = Stopwatch()..start();
      int redoOps = 0;
      while (manager.canRedo()) {
        manager.redo();
        redoOps++;
      }
      sw.stop();
      // ignore: avoid_print
      print(BenchmarkResult('redo (1K Document history)', sw.elapsed, redoOps));
    });

    test('rapid undo-redo cycling', () {
      final manager = UndoRedoManager<Spreadsheet>();
      final sheet = buildSpreadsheet(rows: 50, cols: 20);

      manager.initialize(sheet.clone());
      for (var i = 0; i < 100; i++) {
        manager.captureState(sheet.clone());
      }

      final sw = Stopwatch()..start();
      int cycles = 0;
      for (var i = 0; i < 5000; i++) {
        // Undo 10 steps, redo 10 steps
        for (var j = 0; j < 10 && manager.canUndo(); j++) {
          manager.undo();
        }
        for (var j = 0; j < 10 && manager.canRedo(); j++) {
          manager.redo();
        }
        cycles++;
      }
      sw.stop();
      // ignore: avoid_print
      print(BenchmarkResult(
          'undo-redo cycle (10+10 per cycle)', sw.elapsed, cycles));
    });
  });

  // =========================================================================
  // GROUP 4: maxMemory performance (removeAt(0) overhead)
  // =========================================================================
  group('maxMemory performance', () {
    test('captureState with maxMemory vs unlimited - removeAt(0) overhead', () {
      final doc = buildDocument(sections: 5, paragraphsPerSection: 10);
      const ops = 1000;

      // Unlimited
      final unlimitedManager = UndoRedoManager<Document>();
      unlimitedManager.initialize(doc.clone());
      final unlimitedResult =
          benchmark('captureState unlimited', ops, () {
        unlimitedManager.captureState(doc.clone());
      });
      // ignore: avoid_print
      print(unlimitedResult);

      // maxMemory = 50 (forces removeAt(0) after 50 states)
      final boundedManager = UndoRedoManager<Document>(maxMemory: 50);
      boundedManager.initialize(doc.clone());
      final boundedResult =
          benchmark('captureState maxMemory=50', ops, () {
        boundedManager.captureState(doc.clone());
      });
      // ignore: avoid_print
      print(boundedResult);

      // maxMemory = 10 (forces removeAt(0) very frequently)
      final tightManager = UndoRedoManager<Document>(maxMemory: 10);
      tightManager.initialize(doc.clone());
      final tightResult =
          benchmark('captureState maxMemory=10', ops, () {
        tightManager.captureState(doc.clone());
      });
      // ignore: avoid_print
      print(tightResult);

      // Bounded with large history should NOT be dramatically slower
      // because removeAt(0) is O(n) on bounded-size lists
      // ignore: avoid_print
      print(
          '\nOverhead ratio (bounded50/unlimited): '
          '${(boundedResult.avgMicrosPerOp / unlimitedResult.avgMicrosPerOp).toStringAsFixed(2)}x');
      // ignore: avoid_print
      print(
          'Overhead ratio (bounded10/unlimited): '
          '${(tightResult.avgMicrosPerOp / unlimitedResult.avgMicrosPerOp).toStringAsFixed(2)}x');
    });

    test('removeAt(0) scaling with growing unbounded stack', () {
      // This demonstrates the O(n) cost of removeAt(0) on List
      // by measuring how long captureState takes as the stack grows
      final doc = buildDocument(sections: 2, paragraphsPerSection: 5);
      final results = <String>[];

      for (final maxMem in [100, 500, 1000, 5000]) {
        final manager = UndoRedoManager<Document>(maxMemory: maxMem);
        manager.initialize(doc.clone());

        // Fill the stack to maxMemory
        for (var i = 0; i < maxMem; i++) {
          manager.captureState(doc.clone());
        }

        // Now every captureState triggers removeAt(0)
        final result = benchmark(
            'captureState (maxMemory=$maxMem, stack full)', 500, () {
          manager.captureState(doc.clone());
        });
        results.add(result.toString());
      }

      // ignore: avoid_print
      print('\nremoveAt(0) scaling:');
      for (final r in results) {
        // ignore: avoid_print
        print('  $r');
      }
    });
  });

  // =========================================================================
  // GROUP 5: Stress tests — push the limits
  // =========================================================================
  group('Stress tests', () {
    test('10K state captures with medium Document', () {
      final manager = UndoRedoManager<Document>();
      final doc = buildDocument(sections: 5, paragraphsPerSection: 10);
      manager.initialize(doc.clone());

      final sw = Stopwatch()..start();
      for (var i = 0; i < 10000; i++) {
        final d = doc.clone();
        d.sections[0].paragraphs[0] = Paragraph(
          text: 'Edit #$i',
          formatting: {'bold': i.isEven},
        );
        manager.captureState(d);
      }
      sw.stop();

      // ignore: avoid_print
      print('10K captures: ${sw.elapsedMilliseconds}ms');
      expect(manager.history().length, equals(10001)); // initial + 10K

      // Verify latest state
      final latest = manager.history().last;
      expect(latest.sections[0].paragraphs[0].text, equals('Edit #9999'));

      // Full undo
      final undoSw = Stopwatch()..start();
      while (manager.canUndo()) {
        manager.undo();
      }
      undoSw.stop();
      // ignore: avoid_print
      print('10K undos: ${undoSw.elapsedMilliseconds}ms');

      // Full redo
      final redoSw = Stopwatch()..start();
      while (manager.canRedo()) {
        manager.redo();
      }
      redoSw.stop();
      // ignore: avoid_print
      print('10K redos: ${redoSw.elapsedMilliseconds}ms');
    });

    test('50K state captures with primitives (baseline)', () {
      final manager = UndoRedoManager<int>();
      manager.initialize(0);

      final sw = Stopwatch()..start();
      for (var i = 1; i <= 50000; i++) {
        manager.captureState(i);
      }
      sw.stop();
      // ignore: avoid_print
      print('50K int captures: ${sw.elapsedMilliseconds}ms');

      final undoSw = Stopwatch()..start();
      while (manager.canUndo()) {
        manager.undo();
      }
      undoSw.stop();
      // ignore: avoid_print
      print('50K int undos: ${undoSw.elapsedMilliseconds}ms');
    });

    test('Spreadsheet with 50K cells, 500 state captures', () {
      final manager = UndoRedoManager<Spreadsheet>();
      final sheet = buildSpreadsheet(rows: 500, cols: 100);
      // ignore: avoid_print
      print('Spreadsheet: ${sheet.cellCount} cells');

      manager.initialize(sheet.clone());

      final sw = Stopwatch()..start();
      for (var i = 0; i < 500; i++) {
        final s = sheet.clone();
        s.rows[0][0] = Cell(value: 'Edit #$i', type: 'string', style: {});
        manager.captureState(s);
      }
      sw.stop();
      // ignore: avoid_print
      print('500 captures of 50K-cell sheet: ${sw.elapsedMilliseconds}ms');
      // ignore: avoid_print
      print(
          'Avg per capture: ${(sw.elapsedMilliseconds / 500).toStringAsFixed(1)}ms');
    });

    test('Canvas with 10K elements, 200 state captures', () {
      final manager = UndoRedoManager<Canvas>();
      final canvas = buildCanvas(elementCount: 10000);

      manager.initialize(canvas.clone());

      final sw = Stopwatch()..start();
      for (var i = 0; i < 200; i++) {
        final c = canvas.clone();
        c.elements.add(CanvasElement(
          type: 'circle',
          position: {'x': i.toDouble(), 'y': i.toDouble()},
          properties: {'fill': '#000'},
          pathData: [],
        ));
        manager.captureState(c);
      }
      sw.stop();
      // ignore: avoid_print
      print(
          '200 captures of 10K-element canvas: ${sw.elapsedMilliseconds}ms');
    });

    test('Deep tree (depth=7, branch=3) capture and undo', () {
      final tree = buildTree(depth: 7, branchFactor: 3);
      // ignore: avoid_print
      print('Tree: ${tree.totalNodes} nodes, depth ${tree.depth}');

      final manager = UndoRedoManager<TreeNode>();
      manager.initialize(tree.clone());

      final sw = Stopwatch()..start();
      for (var i = 0; i < 100; i++) {
        manager.captureState(tree.clone());
      }
      sw.stop();
      // ignore: avoid_print
      print('100 captures: ${sw.elapsedMilliseconds}ms');

      final undoSw = Stopwatch()..start();
      while (manager.canUndo()) {
        manager.undo();
      }
      undoSw.stop();
      // ignore: avoid_print
      print('100 undos: ${undoSw.elapsedMilliseconds}ms');
    });

    test('BinaryPayload 5MB, 50 state captures', () {
      final manager = UndoRedoManager<BinaryPayload>();
      final payload = buildBinaryPayload(sizeBytes: 5000000);

      manager.initialize(payload.clone());

      final sw = Stopwatch()..start();
      for (var i = 0; i < 50; i++) {
        final p = payload.clone();
        p.data[i] = 0; // small mutation
        manager.captureState(p);
      }
      sw.stop();
      // ignore: avoid_print
      print(
          '50 captures of 5MB payload: ${sw.elapsedMilliseconds}ms '
          '(~${(50 * 5).toStringAsFixed(0)}MB total in history)');
    });

    test('maxMemory stress: 10K captures with maxMemory=100', () {
      final manager = UndoRedoManager<Document>(maxMemory: 100);
      final doc = buildDocument(sections: 5, paragraphsPerSection: 10);
      manager.initialize(doc.clone());

      final sw = Stopwatch()..start();
      for (var i = 0; i < 10000; i++) {
        manager.captureState(doc.clone());
      }
      sw.stop();

      // ignore: avoid_print
      print(
          '10K captures with maxMemory=100: ${sw.elapsedMilliseconds}ms');
      expect(manager.history().length, equals(100));

      // Verify we can only undo 99 times (100 states - 1 current)
      int undoCount = 0;
      while (manager.canUndo()) {
        manager.undo();
        undoCount++;
      }
      expect(undoCount, equals(99));
    });
  });

  // =========================================================================
  // GROUP 6: Edge cases and mutation safety
  // =========================================================================
  group('Mutation safety and edge cases', () {
    test('history() returns mutable internal list — mutation risk', () {
      final manager = UndoRedoManager<int>();
      manager.initialize(0);
      manager.captureState(1);
      manager.captureState(2);

      final history = manager.history();
      expect(history.length, equals(3));

      // This mutates the internal undo stack!
      history.clear();

      // Manager state is now corrupted
      expect(manager.canUndo(), isFalse);
      expect(manager.history().length, equals(0));
      // This test documents the bug - history() should return
      // an unmodifiable view or a copy
    });

    test('clearHistory returns first state and resets', () {
      final manager = UndoRedoManager<Document>();
      final doc1 = buildDocument(sections: 1, paragraphsPerSection: 1);
      manager.initialize(doc1.clone());
      manager.captureState(
          buildDocument(sections: 2, paragraphsPerSection: 2).clone());

      final initial = manager.clearHistory()!;
      expect(initial.sections.length, equals(1));
      expect(manager.canUndo(), isFalse);
      expect(manager.canRedo(), isFalse);
    });

    test('dispose cleans up large history', () {
      final manager = UndoRedoManager<BinaryPayload>();
      final payload = buildBinaryPayload(sizeBytes: 1000000);

      manager.initialize(payload.clone());
      for (var i = 0; i < 100; i++) {
        manager.captureState(payload.clone());
      }

      manager.dispose();
      expect(manager.canUndo(), isFalse);
      expect(manager.canRedo(), isFalse);
      expect(manager.history().length, equals(0));
    });

    test('initialize resets existing state', () {
      final manager = UndoRedoManager<Document>();
      final doc1 = buildDocument(sections: 5, paragraphsPerSection: 5);
      manager.initialize(doc1.clone());
      for (var i = 0; i < 50; i++) {
        manager.captureState(doc1.clone());
      }

      // Re-initialize should clear everything
      final doc2 = buildDocument(sections: 1, paragraphsPerSection: 1);
      manager.initialize(doc2.clone());

      expect(manager.history().length, equals(1));
      expect(manager.canUndo(), isFalse);
      expect(manager.canRedo(), isFalse);
    });

    test('interleaved capture-undo-capture clears redo stack', () {
      final manager = UndoRedoManager<Spreadsheet>();
      final sheets = List.generate(
          5, (_) => buildSpreadsheet(rows: 10, cols: 10));

      manager.initialize(sheets[0].clone());
      manager.captureState(sheets[1].clone());
      manager.captureState(sheets[2].clone());
      manager.undo(); // redo has sheets[2]
      expect(manager.canRedo(), isTrue);

      manager.captureState(sheets[3].clone()); // should clear redo
      expect(manager.canRedo(), isFalse);
    });
  });

  // =========================================================================
  // GROUP 7: Scaling characteristics summary
  // =========================================================================
  group('Scaling summary', () {
    test('capture time scaling with object size', () {
      // ignore: avoid_print
      print('\n=== SCALING SUMMARY ===\n');

      // Increasing document sizes
      final sizes = [
        (sections: 1, paragraphs: 5, label: 'tiny'),
        (sections: 5, paragraphs: 20, label: 'small'),
        (sections: 20, paragraphs: 50, label: 'medium'),
        (sections: 50, paragraphs: 100, label: 'large'),
        (sections: 100, paragraphs: 200, label: 'huge'),
      ];

      // ignore: avoid_print
      print('Document capture (clone + captureState):');
      for (final size in sizes) {
        final doc = buildDocument(
            sections: size.sections,
            paragraphsPerSection: size.paragraphs);
        final manager = UndoRedoManager<Document>();
        manager.initialize(doc.clone());

        final result = benchmark(
            '  ${size.label} (~${doc.estimatedFieldCount} fields)', 100, () {
          manager.captureState(doc.clone());
        });
        // ignore: avoid_print
        print(result);
      }

      // Increasing history sizes
      // ignore: avoid_print
      print('\nUndo throughput by history depth:');
      final doc = buildDocument(sections: 5, paragraphsPerSection: 10);
      for (final historySize in [100, 500, 1000, 5000]) {
        final manager = UndoRedoManager<Document>();
        manager.initialize(doc.clone());
        for (var i = 0; i < historySize; i++) {
          manager.captureState(doc.clone());
        }

        final sw = Stopwatch()..start();
        while (manager.canUndo()) {
          manager.undo();
        }
        sw.stop();
        // ignore: avoid_print
        print(
            '  $historySize states: ${sw.elapsedMilliseconds}ms total, '
            '${(sw.elapsedMicroseconds / historySize).toStringAsFixed(1)}µs/undo');
      }
    });
  });
}
