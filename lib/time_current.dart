import 'dart:async';
import 'package:chronosync/clockdb.dart';
import 'package:flutter/material.dart' as mat;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers.dart';

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
  int buildCount = 0;
  TimeOfDay? inTime;
  TimeOfDay? outTime;
  // this clockstate needs to be saved and retrieved from shared preferences
  // perform fetch from shared preferences on initState
  // if not found in shared preferences, simply default to Out state
  String clockState = "Out";
  TimeOfDay stateTime = TimeOfDay.now();
  String inTimeStr = "def";
  String outTimeStr = "def";

  @override
  void initState() {
    super.initState();
    getState();
  }

  void getState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? inHour = prefs.getInt("inHour");
    final int? inMinute = prefs.getInt("inMinute");

    if (inHour != null && inMinute != null) {
      setState(() {
        clockState = "In";
        inTime = TimeOfDay(hour: inHour, minute: inMinute);
        inTimeStr = timeStr(inTime!);
      });
    }
  }

  void setTime(String io) {
    if (io == "In") {
      setState(() {
        inTime = stateTime;
        inTimeStr = timeStr(inTime!);
        // print("Clock In Time Set: $inTime");
      });
    } else if (io == "Out") {
      setState(() {
        outTime = stateTime;
        outTimeStr = timeStr(outTime!);
        // print("Clock Out Time Set: $outTime");
      });
    }
  }

  void updateStateTime(TimeOfDay time) {
    setState(() {
      stateTime = time;
    });
  }

  void setClockState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (clockState == "In" && inTime != null) {
      int inHour = inTime!.hour;
      int inMinute = inTime!.minute;
      await prefs.setInt("inHour", inHour);
      await prefs.setInt("inMinute", inMinute);
      // print("Clock State Saved: Hour -> $inHour, Minute -> $inMinute");
    } else if (clockState == "Out") {
      final int? inHour = prefs.getInt("inHour");
      final int? inMinute = prefs.getInt("inMinute");

      inTime ??= TimeOfDay(hour: inHour!, minute: inMinute!);

      // print("Clock State Removed: Hour -> $inHour, Minute -> $inMinute");
      await prefs.remove("inHour");
      await prefs.remove("inMinute");
    }
  }

  // Actual working database insert of new ClockDate object
  void setClock() {
    if (inTime == null || outTime == null) {
      // print("inTime is ${inTime == null} | outTime is ${outTime == null}");
      return;
    }

    DateTime date = DateTime(widget.now.year, widget.now.month, widget.now.day);

    // print("Shits here and shits fine");

    TimeOfDay intime = inTime!, outtime = outTime!;

    dbOps("C", clock: ClockDate(date: date, inTime: intime, outTime: outtime))
        .then((v) {
      // print("New Clock-In on $date from $intime to $outtime");
    });
  }

  @override
  Widget build(BuildContext context) {
    buildCount++;

    return mat.Scaffold(
      floatingActionButton: mat.FloatingActionButton.extended(
        elevation: 0,
        backgroundColor: context.theme.colorScheme.background,
        onPressed: null,
        label: Switch(
          value: clockState == "In",
          onChanged: (value) {
            updateStateTime(stateTime);
            setTime(clockState == "In" ? "Out" : "In");
            if (clockState == "In") {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Center(
                      child: Text(
                        "Confirm Check-In",
                        style: TextStyle(fontSize: 24),
                      ).h2(pad: 0).sans(),
                    ),
                    content: Center(
                      child: mat.Column(
                        children: [
                          Text("Confirm Clock-In Time:").sans(),
                          Text(
                            "$inTimeStr - $outTimeStr",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ).base().sans(),
                        ],
                      ),
                    ),
                    actions: [
                      SecondaryButton(
                        child: Text("Cancel").sans(),
                        onPressed: () => Navigator.pop(context),
                      ),
                      PrimaryButton(
                        child: Text("OK").sans(),
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            clockState = value ? "In" : "Out";
                          });
                          // upload to database or straight to api call
                          setClockState();
                          setClock();
                          // print("New clock from $inTimeStr - $outTimeStr uploaded and synced to database");
                          setState(() {
                            inTime = null;
                            outTime = null;
                          });
                        },
                      ),
                    ],
                    actionsCenterAlign: true,
                  );
                },
              );
            } else {
              setState(() {
                clockState = value ? "In" : "Out";
              });
              setClockState();
            }
          },
          scale: 2,
        ),
      ),
      floatingActionButtonLocation:
          mat.FloatingActionButtonLocation.centerFloat,
      body: Scaffold(
        headers: [
          AppBar(
            alignment: Alignment.center,
            child: Text(
              "ChronoSync",
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ).sans().h2().center(),
          ),
        ],
        child: Container(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Gap(20),
              Text(
                "Current Status",
                // "Current Build Count: $buildCount\nCurrent State Time: ${timeStr(stateTime)}",
                textAlign: TextAlign.center,
              ).sans().h4(),
              Gap(50),
              (clockState == "Out")
                  ? Card(
                      borderColor: Colors.blue,
                      child: Text(
                        "Clocked $clockState",
                        style: TextStyle(fontSize: 20),
                      ).h2(pad: 0).sans(),
                    )
                  : Card(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: Offset(0, 0),
                        ),
                      ],
                      borderColor: Colors.blue,
                      child: Text(
                        "Clocked $clockState",
                        style: TextStyle(fontSize: 20),
                      ).h2(pad: 0).sans(),
                    ),
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
                            io: clockState == "In" ? "Out" : "In",
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
  final Function(String) setTime;
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
  Timer? timer;
  TimeOfDay? time;
  bool pressed = false;
  bool init = true;
  int tdBuildCount = 0;

  @override
  void initState() {
    super.initState();
    if (!pressed) {
      timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
        TimeOfDay now = TimeOfDay.now();
        if ((time!.hour != now.hour || time!.minute != now.minute)) {
          setState(() {
            time = now;
            widget.updateStateTime(time ?? now);
          });
        }
      });
    } else {
      timer?.cancel();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    time = time ?? TimeOfDay.now();
    tdBuildCount++;

    Widget actionB() {
      return TimePicker(
        value: time,
        mode: PromptMode.dialog,
        use24HourFormat: false,
        dialogTitle: Text(
          "Select Clock-${widget.io} Time",
          style: TextStyle(fontSize: 20),
        ).h2(pad: 0).sans(),
        onChanged: (value) {
          widget.updateStateTime(value ?? TimeOfDay.now());
          widget.setTime(widget.io);
          setState(() {
            time = value;
            pressed = true;
            timer?.cancel();
          });
        },
      );
    }

    return actionB();
  }
}
