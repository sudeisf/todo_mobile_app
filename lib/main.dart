import "dart:ui_web";

import "package:flutter/material.dart";


void main () => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "To-Do App",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TodoScreen(),
    );
  }
}


class TodoScreen extends StatelessWidget {
  @override
    // TODO: implement build
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text("To-Do App"),),
        body: Center(child: Text("Welcome to To-Do App!"))
      ) ;
    }
  }

