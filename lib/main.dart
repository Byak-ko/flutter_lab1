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
      title: 'Flutter Lab 1',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      initialRoute: homeRoute,
      routes: {
        homeRoute: (context) => const MyHomePage(title: 'Flutter Lab 1 — Home'),
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
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, MyApp.listsRoute),
              icon: const Icon(Icons.list),
              label: const Text('Лаба 2: Списки'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, MyApp.checkboxRoute),
              icon: const Icon(Icons.check_box_outlined),
              label: const Text('Лаба 3: CheckBox'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, MyApp.buttonRoute),
              icon: const Icon(Icons.smart_button),
              label: const Text('Лаба 4: Button'),
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
