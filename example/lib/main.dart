import 'package:example/examples/int_example.dart';
import 'package:example/examples/list_example.dart';
import 'package:example/examples/object_example.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: Menu(),
    );
  }
}

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("demo examples"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMenuButton(context, 'view int example', const IntExample()),
          _buildMenuButton(context, 'view list example', const ListExample()),
          _buildMenuButton(
              context, 'view object example', const ObjectExample()),
        ],
      ),
    );
  }

  _buildMenuButton(
    BuildContext context,
    String text,
    Widget page,
  ) {
    return Center(
      child: TextButton(
        child: Text(text),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => page,
          ),
        ),
      ),
    );
  }
}
