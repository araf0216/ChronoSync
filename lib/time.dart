import 'package:flutter/material.dart' as mat;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'clockdb.dart';

class TimeSelect extends mat.StatefulWidget {
  final DateTime now;
  final DateTime start;
  final DateTime end;

  const TimeSelect(
      {super.key, required this.now, required this.start, required this.end});

  @override
  State<TimeSelect> createState() => _TimeSelect();
}

class _TimeSelect extends State<TimeSelect> {
  int id = 0;
  TimeOfDay inTime = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay outTime = TimeOfDay(hour: 0, minute: 0);

  void setTime(String io, TimeOfDay time) {
    if (io == "In") {
      setState(() {
        inTime = time;
      });
    } else if (io == "Out") {
      setState(() {
        outTime = time;
      });
    }
  }

  void setClock() {
    DateTime date = mat.DateUtils.dateOnly(widget.now);
    setState(() async {
      int id = (await dbOps("R")).length;
      await dbOps("C", ClockDate(id: id, date: date, inTime: inTime, outTime: outTime));
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return mat.Scaffold(
      floatingActionButton: mat.FloatingActionButton.extended(
        backgroundColor: Colors.transparent,
        onPressed: null,
        label: PrimaryButton(
          onPressed: () => setClock(),
          trailing: Icon(Icons.check_circle_outline_rounded),
          child: Text(
            "Submit",
            style: TextStyle(fontSize: 18),
          ).h4(),
        ),
      ),
      floatingActionButtonLocation:
          mat.FloatingActionButtonLocation.centerFloat,
      body: Scaffold(
        headers: [
          AppBar(
            leading: [
              IconButton.secondary(
                onPressed: () => Navigator.pop(context),
                size: ButtonSize(0.8),
                icon: Icon(Icons.arrow_back_ios_new),
              ),
            ],
            height: 35,
          ),
        ],
        child: Container(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Text(
                "Select Clock-In/Out Times",
                style: TextStyle(fontSize: 20),
              ).h2(),
              const Gap(50),
              IntrinsicWidth(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 20,
                      children: [
                        Text("Check-In: ").h4(),
                        TimeDial(io: "In", setTime: setTime),
                      ],
                    ),
                    const Gap(16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 20,
                      children: [
                        Text("Check-Out: ").h4(),
                        TimeDial(io: "Out", setTime: setTime),
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

// class TimeDialog extends StatefulWidget {
//   final String io;

//   const TimeDialog({required this.io, super.key});

//   @override
//   State<TimeDialog> createState() => _TimeDialog();
// }

// class _TimeDialog extends State<TimeDialog> {
//   TimeOfDay? time;

//   @override
//   Widget build(BuildContext context) {
//     time ??= TimeOfDay.now();

//     return TimePicker(
//       value: time,
//       mode: PromptMode.dialog,
//       use24HourFormat: false,
//       dialogTitle: Text(
//         "Select Clock-${widget.io} Time",
//         style: TextStyle(fontSize: 20),
//       ).h2(),
//       onChanged: (value) {
//         setState(() {
//           time = value ?? TimeOfDay.now();
//         });
//       },
//     );
//   }
// }

class TimeDial extends StatefulWidget {
  final String io;
  final Function(String, TimeOfDay) setTime;

  const TimeDial({required this.io, required this.setTime, super.key});

  @override
  State<TimeDial> createState() => _TimeDial();
}

class _TimeDial extends State<TimeDial> {
  TimeOfDay? time;
  bool pressed = true;
  bool init = true;

  @override
  Widget build(BuildContext context) {
    TimeOfDay time_ = time ?? TimeOfDay.now();
    int hour = (time_.hour == 0 || time_.hour > 12)
        ? (time_.hour - 12).abs()
        : time_.hour;
    int minute = time_.minute;
    String period = time_.hour < 12 ? "AM" : "PM";

    Widget actionB() {
      return TimePicker(
        placeholder: Text("Select..."),
        value: (init && hour != 12) ? time_ : time,
        mode: PromptMode.dialog,
        use24HourFormat: false,
        dialogTitle: Text(
          "Select Clock-${widget.io} Time",
          style: TextStyle(fontSize: 20),
        ).h2(),
        onChanged: (value) {
          setState(() {
            pressed = false;
            time = value;
          });
          widget.setTime(widget.io, time!);
        },
      );
    }

    Widget displayB() {
      return OutlineButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Delete Selected Time?"),
                actions: [
                  SecondaryButton(
                    child: Text("Cancel"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  PrimaryButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        init = false;
                        pressed = true;
                        time = null;
                      });
                    },
                  ),
                ],
              );
            },
          );
        },
        child: mat.Row(
          mainAxisSize: mat.MainAxisSize.min,
          spacing: 10,
          children: [
            Text(
              "${hour.toString().padLeft(2, "0")}:${minute.toString().padLeft(2, "0")} $period",
              style: TextStyle(color: Colors.white),
            ),
            Icon(Icons.access_time, size: 20)
          ],
        ),
      );
    }

    return pressed ? actionB() : displayB();
  }
}
