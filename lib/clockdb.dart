import 'dart:async';
// import 'dart:nativewrappers/_internal/vm/lib/ffi_patch.dart';
// import 'package:flutter/material.dart' as mat;
import 'package:shadcn_flutter/shadcn_flutter.dart';
// import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class ClockDate {
  int id;
  // pass in millisecondsSinceEpoch property <-> retrieve using .fromMillisecondsSinceEpoch method
  final DateTime date;
  // pass in hour and minute separately
  final TimeOfDay inTime;
  final TimeOfDay outTime;
  bool isUploaded;

  ClockDate({
    this.id = 0,
    required this.date,
    required this.inTime,
    required this.outTime,
    this.isUploaded = false,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'inHour': inTime.hour,
      'inMin': inTime.minute,
      'outHour': outTime.hour,
      'outMin': outTime.minute,
      'isUploaded': isUploaded ? 1 : 0,
    };
  }

  @override
  String toString() {
    return 'Clock{id: $id, date: ${date.millisecondsSinceEpoch}, inHour: ${inTime.hour}, inMin: ${inTime.minute}, outHour: ${outTime.hour}, outMin: ${outTime.minute}, isUploaded: $isUploaded}';
  }
}

Future<List<ClockDate>> dbOps(String op, {ClockDate? clock, int? id}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = openDatabase(
    path.join(await getDatabasesPath(), 'clock_db.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE clocks(id INTEGER PRIMARY KEY, date INTEGER, inHour INTEGER, inMin INTEGER, outHour INTEGER, outMin INTEGER, isUploaded INTEGER)',
      );
    },
    version: 2,
  );

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
            'outMin': outMin as int,
            'isUploaded': isUploaded as int,
          } in clockMaps)
        ClockDate(
          id: id,
          date: DateTime.fromMillisecondsSinceEpoch(date),
          inTime: TimeOfDay(hour: inHour, minute: inMin),
          outTime: TimeOfDay(hour: outHour, minute: outMin),
          isUploaded: isUploaded == 1,
        ),
    ];
  }

  Future<void> insertClock(ClockDate clock) async {
    final db = await database;

    await db.transaction((txn) async {
      int? maxId = Sqflite.firstIntValue(
          await txn.rawQuery('SELECT MAX(id) FROM clocks'));

      if (maxId != null) {
        clock.id = maxId + 1;
        print("Length and ID found: ${clock.id}");
      } else {
        clock.id = 1;
        print("No existing ID found - Creating first with ID: [1]");
      }

      await txn.insert(
        'clocks',
        clock.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> updateClock(ClockDate clock) async {
    final db = await database;

    await db.update(
      'clocks',
      clock.toMap(),
      where: 'date = ?',
      whereArgs: [clock.date.millisecondsSinceEpoch],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteClock(int id) async {
    final db = await database;

    await db.delete(
      'clocks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  switch (op) {
    case "D":
      if (id != null) {
        deleteClock(id);
      }
      return Future.value([]);
    case "U":
      if (clock != null) {
        updateClock(clock);
      }
      return Future.value([]);
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
