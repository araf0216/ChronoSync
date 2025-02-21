import 'package:flutter/material.dart';


class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.blue)),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.fast_rewind_rounded), label: "Prior"),
          BottomNavigationBarItem(
              icon: Icon(Icons.expand_circle_down_outlined), label: "Current"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "User"),
        ],
      ),
    );
  }
}
