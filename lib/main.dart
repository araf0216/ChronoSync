import 'package:clockify/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.blue,
        secondaryHeaderColor: Colors.white,
      ),
      // darkTheme: ThemeData.dark(),
    );
  }

  
}
