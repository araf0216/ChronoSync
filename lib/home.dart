import 'package:clockify/bottom_nav.dart';
import 'package:clockify/time.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          width: MediaQuery.of(context).size.width,
          child: page(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TimeSelect(now: DateTime.now()),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }

  DateTime today = DateTime.now();

  DateTime? _selectedDay;

  Widget page() {
    if (_selectedDay == null) {
      setState(() {
        _selectedDay = today;
      });
    }

    return TableCalendar(
      focusedDay: _selectedDay ?? today,
      firstDay: DateTime(2025, 1, 1),
      lastDay: today,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontFamily: "UbuntuMono",
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      calendarStyle: CalendarStyle(
        defaultTextStyle: GoogleFonts.ubuntuMono(
          textStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        defaultDecoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(fontWeight: FontWeight.bold),
        todayTextStyle:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        todayDecoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: Border.all(
              color: Colors.blue,
              width: 1,
              style: BorderStyle.solid,
              strokeAlign: BorderSide.strokeAlignCenter),
        ),
        disabledTextStyle: const TextStyle(color: Colors.white70),
        holidayTextStyle: const TextStyle(color: Colors.white60),
      ),
      selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          // _focusedDay = focusedDay; // update `_focusedDay` here as well
        });
      },
    );
  }
}
