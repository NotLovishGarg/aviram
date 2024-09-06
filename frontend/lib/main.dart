import 'package:flutter/material.dart';
import 'pages/home.dart'; // Make sure this import path is correct

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'aviram',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:
          MyHome(), // Make sure MyHome is the correct name of your home widget
      debugShowCheckedModeBanner: false,
    );
  }
}
