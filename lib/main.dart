import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ciao Mondo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('App di Test'),
        ),
        body: const Center(
          child: Text(
            'Ciao Mondo',
            style: TextStyle(fontSize: 32),
          ),
        ),
      ),
    );
  }
}