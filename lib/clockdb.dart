import 'dart:async';

// import 'package:flutter/material.dart' as mat;
import 'package:shadcn_flutter/shadcn_flutter.dart';
// import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class ClockDate {
  final int id;
  // pass in millisecondsSinceEpoch property <-> retrieve using .fromMillisecondsSinceEpoch method
  final DateTime date;
  // pass in hour and minute separately
  final TimeOfDay inTime;
  final TimeOfDay outTime;

  const ClockDate(
      {required this.id,
      required this.date,
      required this.inTime,
      required this.outTime});

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'inHour': inTime.hour,
      'inMin': inTime.minute,
      'outHour': outTime.hour,
      'outMin': outTime.minute
    };
  }

  @override
  String toString() {
    return 'Clock{id: $id, date: ${date.millisecondsSinceEpoch}, inHour: ${inTime.hour}, inMin: ${inTime.minute}, outHour: ${outTime.hour}, outMin: ${outTime.minute}}';
  }
}

Future<List<ClockDate>> dbOps(String op, [ClockDate? clock, DateTime? date]) async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = openDatabase(
    path.join(await getDatabasesPath(), 'clock_db.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE clocks(id INTEGER PRIMARY KEY, date INTEGER, inHour INTEGER, inMin INTEGER, outHour INTEGER, outMin INTEGER)',
      );
    },
    version: 1,
  );

  Future<void> insertClock(ClockDate clock) async {
    final db = await database;

    await db.insert(
      'clocks',
      clock.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ClockDate>> clocks() async {
    final db = await database;

    final List<Map<String, Object?>> clockMaps = await db.query('clocks');

    return [
      for (final {
            'id': id as int,
            'date': date as int,
            'inHour': inHour as int,
            'inMin': inMin as int,
            'outHour': outHour as int,
            'outMin': outMin as int
          } in clockMaps)
        ClockDate(
          id: id,
          date: DateTime.fromMillisecondsSinceEpoch(date),
          inTime: TimeOfDay(hour: inHour, minute: inMin),
          outTime: TimeOfDay(hour: outHour, minute: outMin),
        ),
    ];
  }

  Future<void> updateClock(ClockDate clock) async {
    final db = await database;

    await db.update(
      'clocks',
      clock.toMap(),
      where: 'date = ?',
      whereArgs: [clock.date.millisecondsSinceEpoch],
    );
  }

  Future<void> deleteClock(DateTime date) async {
    final db = await database;

    await db.delete(
      'clocks',
      where: 'date = ?',
      whereArgs: [date.millisecondsSinceEpoch],
    );
  }

  switch (op) {
    case "R":
      return clocks();
    case "C":
      if (clock != null) {
        insertClock(clock);
      }
      return Future.value([]);
    default:
      return Future.value([]);
  }
}
