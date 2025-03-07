import 'package:flutter/material.dart' as mat;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'example.dart';

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
          title: Text(
            "Welcome, User",
            style: TextStyle(fontSize: 24),
          ).h2().sans().center(),
          alignment: Alignment.center,
        ),
      ],
      child: Container(
        alignment: Alignment.topCenter,
        margin: EdgeInsets.only(top: 50),
        child: DataExample2(),
      ),
    );
  }
}
