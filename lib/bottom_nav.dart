import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      showUnselectedLabels: false,
      showSelectedLabels: false,
      backgroundColor: Color(0xFF020817),
      elevation: 20,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.white,
      items: [
        BottomNavigationBarItem(
            icon: Image.asset("lib/assets/calendar.png", width: 28, height: 28, color: Colors.white,), label: "Prior"),
        BottomNavigationBarItem(
            icon: Image.asset("lib/assets/on-time.png", width: 32, height: 32, color: Colors.white,), label: "Current"),
        BottomNavigationBarItem(icon: Icon(shad.BootstrapIcons.personCircle, size: 30,), label: "User"),
      ],
    );
  }
}
