import 'package:flutter/material.dart';
import 'ui/pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Lists',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 42, 51, 146),
        ),
      ),
      home: const HomeScreen(title: 'Movie Lists'),
    );
  }
}
