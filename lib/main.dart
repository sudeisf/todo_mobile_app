import 'package:flutter/material.dart';
import 'screens/todo_screen.dart'; // Import your To-Do screen file

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized before running
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "To-Do App",
      theme: ThemeData(
        primarySwatch: Colors.blue, // Theme color
      ),
      home: TodoScreen(), // Load the main To-Do screen
    );
  }
}
