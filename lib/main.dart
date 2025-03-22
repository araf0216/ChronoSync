import 'package:clockify/current.dart';
import 'package:clockify/home.dart';
import 'package:clockify/user.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' as mat;
import 'nav.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int? _selectedIndex;
  static const List<Widget> screens = <Widget>[
    HomeScreen(),
    CurrentScreen(),
    UserScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return ShadcnApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorSchemes.darkBlue(),
        typography: Typography.geist(),
        radius: 0.5,
      ),
      home: mat.Scaffold(
        body: screens[_selectedIndex ?? 0],
        bottomNavigationBar: BottomNavBar(
          onSelect: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
