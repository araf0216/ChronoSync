import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';

class BottomNavBar extends StatefulWidget {
  final Function? onSelect;
  const BottomNavBar({super.key, this.onSelect});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      destinations: [
        NavigationDestination(
            icon: _selectedIndex == 0
              ? Container(
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.secondary,
                  borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                child: ImageIcon(
                  AssetImage("lib/assets/calendar.png"),
                  size: 28,
                  color: context.theme.colorScheme.secondaryForeground,
                ).withMargin(all: 10),
              )
              : ImageIcon(
                AssetImage("lib/assets/calendar.png"),
                size: 28,
                color: Colors.white,
              ),
            label: "Prior"),
        NavigationDestination(
            icon: _selectedIndex == 1
              ? Container(
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.secondary,
                  borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                child: ImageIcon(
                  AssetImage("lib/assets/on-time.png"),
                  size: 32,
                  color: context.theme.colorScheme.secondaryForeground
                ).withMargin(all: 8),
              )
              : ImageIcon(
                AssetImage("lib/assets/on-time.png"),
                size: 32,
                color: Colors.white,
              ),
            label: "Current"),
        NavigationDestination(
            icon: _selectedIndex == 2
              ? Container(
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.secondary,
                  borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                child: Icon(
                  shad.BootstrapIcons.personCircle,
                  size: 30,
                  color: context.theme.colorScheme.secondaryForeground
                ).withMargin(all: 8),
              )
              : Icon(
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
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      backgroundColor: Color(0xFF020817),
      indicatorColor: Color(0xFF020817),
      elevation: 20,
      selectedIndex: _selectedIndex,
      overlayColor: WidgetStateColor.fromMap({WidgetState.any: Colors.transparent}),
    );
  }
}
