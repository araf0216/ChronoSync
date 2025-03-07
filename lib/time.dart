import 'package:flutter/material.dart' as mat;
import 'package:shadcn_flutter/shadcn_flutter.dart';
// import 'clockdb.dart';

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
  TimeOfDay inTime = TimeOfDay.now();
  TimeOfDay outTime = TimeOfDay.now();

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

    // dbOps("R").then((clocks) {
    //   setState(() {
    //     id = clocks.length;
    //   });
    // });
    print("New Clock-In on $date from $inTime to $outTime");

    Navigator.pop(context);

    // Actual working database insert of new ClockDate object
    // dbOps("C", ClockDate(id: id, date: date, inTime: inTime, outTime: outTime))
    //     .then((v) {
    //   setState(() {
    //     // complete here
    //     // print("v");
    //   });
    // });
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
          ).h4().sans(),
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
              ).h2().sans(),
              const Gap(50),
              IntrinsicWidth(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 20,
                      children: [
                        Text("Clock-In: ").h4().sans(),
                        TimeDial(io: "In", setTime: setTime),
                      ],
                    ),
                    const Gap(16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 20,
                      children: [
                        Text("Clock-Out: ").h4().sans(),
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
    Widget actionB() {
      return TimePicker(
        value: time ?? TimeOfDay.now(),
        mode: PromptMode.dialog,
        use24HourFormat: false,
        dialogTitle: Text(
          "Select Clock-${widget.io} Time",
          style: TextStyle(fontSize: 20),
        ).h2().sans(),
        onChanged: (value) {
          setState(() {
            pressed = false;
            time = value;
          });
          widget.setTime(widget.io, time!);
        },
      );
    }

    return actionB();
  }
}
