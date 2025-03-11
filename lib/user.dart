import 'package:flutter/material.dart' as mat;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'history.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: Stack(
            children: [
              Text(
                "Welcome, User",
                style: TextStyle(fontSize: 24),
              ).h2().sans().center(),
              Container(
                alignment: Alignment.topRight,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.blue),
                    shape: BoxShape.circle
                  ),
                  child: Icon(BootstrapIcons.threeDots, color: Colors.blue, size: 18),
                ),
              ),
            ]
          ),
          alignment: Alignment.center,
        ),
      ],
      child: mat.Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(child: ClockTimeline()),
      ),
    );
  }
}
