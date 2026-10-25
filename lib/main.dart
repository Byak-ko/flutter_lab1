import 'package:flutter/material.dart';

import 'pages/button_page.dart';
import 'pages/checkbox_page.dart';
import 'pages/lists_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String homeRoute = '/';
  static const String secondRoute = '/second';
  static const String listsRoute = '/lab2';
  static const String checkboxRoute = '/lab3';
  static const String buttonRoute = '/lab4';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter labs',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      initialRoute: homeRoute,
      routes: {
        homeRoute: (context) => const MyHomePage(title: 'Flutter labs'),
        secondRoute: (context) => const SecondPage(),
        listsRoute: (context) => const ListsPage(),
        checkboxRoute: (context) => const CheckboxPage(),
        buttonRoute: (context) => const ButtonPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: const LabsDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, MyApp.secondRoute);
              },
              child: const Text('Next'),
            ),
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

class LabsDrawer extends StatelessWidget {
  const LabsDrawer({super.key});

  void _open(BuildContext context, String route) {
    Navigator.pop(context);
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Лабораторні',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Списки'),
              subtitle: const Text('Лаба 2'),
              onTap: () => _open(context, MyApp.listsRoute),
            ),
            ListTile(
              leading: const Icon(Icons.check_box_outlined),
              title: const Text('Чекбокси'),
              subtitle: const Text('Лаба 3'),
              onTap: () => _open(context, MyApp.checkboxRoute),
            ),
            ListTile(
              leading: const Icon(Icons.smart_button),
              title: const Text('Кнопки'),
              subtitle: const Text('Лаба 4'),
              onTap: () => _open(context, MyApp.buttonRoute),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Back'),
        ),
      ),
    );
  }
}
