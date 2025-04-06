import 'package:chronosync/time_current.dart';
import 'package:flutter/material.dart' as mat;
import 'package:shadcn_flutter/shadcn_flutter.dart';

class CurrentScreen extends mat.StatefulWidget {
  const CurrentScreen({super.key});

  @override
  State<CurrentScreen> createState() => _CurrentScreenState();
}

class _CurrentScreenState extends State<CurrentScreen> {
  bool value = false;
  @override
  Widget build(BuildContext context) {
    return TimeScreen(
        now: DateTime.now(), start: DateTime(2025, 1, 1), end: DateTime.now());
  }
}
