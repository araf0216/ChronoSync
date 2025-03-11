
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class BottomNavBar extends StatefulWidget {
  final Function? onSelect;
  const BottomNavBar({super.key, this.onSelect});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: [
        NavigationDestination(
            icon: Image.asset(
              "lib/assets/calendar.png",
              width: 28,
              height: 28,
              color: Colors.white,
            ),
            label: "Prior"),
        NavigationDestination(
            icon: Image.asset(
              "lib/assets/on-time.png",
              width: 32,
              height: 32,
              color: Colors.white,
            ),
            label: "Current"),
        NavigationDestination(
            icon: Icon(
              shad.BootstrapIcons.personCircle,
              size: 30,
              color: Colors.white,
            ),
            label: "User"),
      ],
      onDestinationSelected: (value) {
        setState(() {
          _selectedIndex = value;
        });
        widget.onSelect?.call(value);
      },
      // showUnselectedLabels: false,
      // showSelectedLabels: false,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      backgroundColor: Color(0xFF020817),
      // backgroundColor: Colors.black,
      shadowColor: Colors.amber,
      elevation: 20,
      selectedIndex: _selectedIndex,
    );
  }
}
