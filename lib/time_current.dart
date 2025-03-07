import 'dart:async';

import 'package:flutter/material.dart' as mat;
import 'package:shadcn_flutter/shadcn_flutter.dart';
// import 'clockdb.dart';

class TimeScreen extends mat.StatefulWidget {
  final DateTime now;
  final DateTime start;
  final DateTime end;

  const TimeScreen(
      {super.key, required this.now, required this.start, required this.end});

  @override
  State<TimeScreen> createState() => _TimeScreen();
}

class _TimeScreen extends State<TimeScreen> {
  // int id = 0;
  TimeOfDay? inTime;
  TimeOfDay? outTime;
  // this clockstate needs to be saved and retrieved from shared preferences
  // if not found in shared preferences, simply default to Out state
  String clockState = "Out";
  TimeOfDay stateTime = TimeOfDay.now();

  void setTime(String io, TimeOfDay time) {
    if (io == "In") {
      setState(() {
        inTime = time;
        print("Clock In Time Set: $time");
      });
    } else if (io == "Out") {
      setState(() {
        outTime = time;
        print("Clock Out Time Set: $time");
      });
    }
  }

  void updateStateTime(TimeOfDay time) {
    setState(() {
      stateTime = time;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(stateTime);
    return mat.Scaffold(
      floatingActionButton: mat.FloatingActionButton.extended(
        backgroundColor: Colors.transparent,
        onPressed: null,
        label: Switch(
          value: clockState == "In",
          onChanged: (value) {
            // dialog for confirmation - TO DO

            // actual toggleState function call
            setState(() {
              clockState = value ? "In" : "Out";
            });
            // save the statetime that is currently set in the time picker in the state pre-toggle
            // the value in statetime must continuously update and sync with the value of the actual time picker
            setTime(clockState, stateTime);
          },
          scale: 2,
        ),
      ),
      floatingActionButtonLocation:
          mat.FloatingActionButtonLocation.centerFloat,
      body: Scaffold(
        child: Container(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Text(
                "You Are Currently Clocked $clockState",
                style: TextStyle(fontSize: 20),
              ).h2().sans(),
              const Gap(50),
              IntrinsicWidth(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 20,
                      children: [
                        Text("Clock-${clockState == "In" ? "Out" : "In"}: ")
                            .h4()
                            .sans(),
                        TimeDial(
                            io: clockState,
                            setTime: setTime,
                            updateStateTime: updateStateTime),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimeDial extends StatefulWidget {
  final String io;
  final Function(String, TimeOfDay) setTime;
  final Function(TimeOfDay) updateStateTime;

  const TimeDial(
      {required this.io,
      required this.setTime,
      required this.updateStateTime,
      super.key});

  @override
  State<TimeDial> createState() => _TimeDial();
}

class _TimeDial extends State<TimeDial> {
  TimeOfDay? time;
  bool pressed = false;
  bool init = true;

  @override
  Widget build(BuildContext context) {
    time = TimeOfDay.now();
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      TimeOfDay now = TimeOfDay.now();
      if (!pressed && (time!.hour != now.hour || time!.minute != now.minute)) {
        // print("Time to update state minute");
        // print(time);
        // print(now);
        setState(() {
          time = now;
        });
        widget.updateStateTime(time ?? now);
        widget.setTime(widget.io, time ?? now);
      }
    });

    Widget actionB() {
      return TimePicker(
        value: time,
        mode: PromptMode.dialog,
        use24HourFormat: false,
        dialogTitle: Text(
          "Select Clock-${widget.io} Time",
          style: TextStyle(fontSize: 20),
        ).h2().sans(),
        onChanged: (value) {
          setState(() {
            pressed = true;
            time = value;
          });
          widget.updateStateTime(time ?? TimeOfDay.now());
          widget.setTime(widget.io, time ?? TimeOfDay.now());
        },
      );
    }

    return actionB();
  }
}
