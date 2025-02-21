import 'package:flutter/material.dart';

class TimeSelect extends StatefulWidget {
  // const TimeSelect({super.key});
  final DateTime now;

  const TimeSelect({super.key, required this.now});

  @override
  State<TimeSelect> createState() => _TimeSelect();
}

class _TimeSelect extends State<TimeSelect> {
  @override
  Widget build(BuildContext context) {
    DateTime now = widget.now;
    // final int timeHour = now.hour > 12 ? now.hour - 12 : now.hour;
    // final int timeMin = now.minute;
    // final String timeAP = now.hour > 12 ? "PM" : "AM";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
      ),
      body: Center(
        child: Column(
          children: [
            // Text(
            //   "$timeHour:$timeMin $timeAP",
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontSize: 20,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            
            TimePickerTheme(
              data: TimePickerThemeData(
                backgroundColor: const Color(0xFF101010),
                dialTextColor: Colors.white,
                dayPeriodTextColor: Colors.white,
                hourMinuteTextColor: Colors.white,
                entryModeIconColor: Colors.white,
                dialHandColor: Colors.blue,
                dialBackgroundColor: Colors.black,
                dayPeriodColor: Colors.lightBlue,
                timeSelectorSeparatorColor: WidgetStatePropertyAll(Colors.white),
                hourMinuteColor: WidgetStateColor.fromMap({WidgetState.selected: Colors.blue, WidgetState.any: Colors.black}),
                helpTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                confirmButtonStyle: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(Colors.blue),
                  textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 18)),
                ),
                cancelButtonStyle: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(Colors.blue),
                  textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 18)),
                ),
                // elevation: 10,
              ),
              child: TimePickerDialog(
                initialTime: TimeOfDay(hour: now.hour, minute: now.minute),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
