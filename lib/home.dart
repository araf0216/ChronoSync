import 'package:clockify/bottom_nav.dart';
import 'package:clockify/time.dart';
import 'package:flutter/material.dart' as mat;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'calendar.dart' as cal;
// import 'package:sqflite/sqflite.dart';
import 'clockdb.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime start = DateTime.utc(2025, 1, 1);
  DateTime today = DateTime.now();
  List<DateTime> completes = [];

  bool updateTriggered = false;

  @override
  Widget build(BuildContext context) {
    return mat.Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Scaffold(
          headers: [
            AppBar(
              title: Text(
                "Select New Clock-In Date",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ).h2(),
              alignment: Alignment.center,
            ),
          ],
          child: Container(
            alignment: Alignment.topCenter,
            margin: EdgeInsets.only(top: 50),
            child: calendar(),
          ),
        ),
      ),
      floatingActionButton: mat.FloatingActionButton(
        onPressed: () async {
          final newComplete = await Navigator.push(
            context,
            MaterialPageRoute(
              // builder: (context) => TimeSelect(now: DateTime.now()),
              builder: (context) =>
                  TimeSelect(now: DateTime.now(), start: start, end: today),
            ),
          );

          // print(newComplete);

          if (newComplete != null) {
            completes.add(newComplete);
            print(completes);
          }
        },
        backgroundColor: Color(0xFF3C83F6),
        child: Icon(
          Icons.add,
          color: Colors.black,
          size: 40,
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }

  DateTime? _selectedDay;

  Widget dpDialog() {
    return DatePicker(
      value: _selectedDay,
      mode: PromptMode.dialog,
      dialogTitle: const Text('Select Date'),
      stateBuilder: (date) {
        if (date.isAfter(DateTime.now()) || date.isBefore(start)) {
          return DateState.disabled;
        }
        return DateState.enabled;
      },
      onChanged: (day) {
        setState(() {
          _selectedDay = day;
        });
      },
    );
  }

  Future<void> _updateCompletes() async {
    if (updateTriggered) return;
    List<ClockDate> clock = await dbOps("R");
    List<DateTime> newCompletes = clock.map((c) => c.date).toList();
    setState(() {
      completes = newCompletes;
      updateTriggered = true;
    });
  }

  cal.CalendarValue? _value;
  CalendarView _view = CalendarView.now();
  Widget calendar() {
    updateTriggered = true;
    ShadcnLocalizations localizations = ShadcnLocalizations.of(context);
    return Card(
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                OutlineButton(
                  density: ButtonDensity.icon,
                  onPressed: () {
                    setState(() {
                      _view = _view.previous;
                    });
                  },
                  child: const Icon(Icons.arrow_back).iconXSmall(),
                ),
                Text('${localizations.getMonth(_view.month)} ${_view.year}')
                    .small()
                    .medium()
                    .center()
                    .expanded(),
                OutlineButton(
                  density: ButtonDensity.icon,
                  onPressed: () {
                    setState(() {
                      _view = _view.next;
                    });
                  },
                  child: const Icon(Icons.arrow_forward).iconXSmall(),
                ),
              ],
            ),
            const Gap(16),
            cal.Calendar(
              value: _value,
              view: _view,
              onChanged: (value) {
                setState(() {
                  _value = value;
                  updateTriggered = false;
                });
                _updateCompletes();
              },
              selectionMode: CalendarSelectionMode.single,
              now: DateTime.now(),
              stateBuilder: (date) {
                if (completes.contains(date)) {
                  return cal.DateState.completed;
                }
                if (date.isAfter(DateTime.now()) || date.isBefore(start)) {
                  return cal.DateState.disabled;
                }
                return cal.DateState.enabled;
              },
            ),
          ],
        ),
      ),
    );
  }
}
