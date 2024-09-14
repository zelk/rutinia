import 'package:flutter/material.dart';
import 'main_page.dart';

// TODO: Add support for integrating REST APIs somehow, maybe using Swagger?
// TOOD: Integrate email and a few other things that can be used easily

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rutinia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

// Remove InstancePage class if it's not being used in this file
