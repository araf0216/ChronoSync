import 'package:chronosync/clockdb.dart';
import 'package:chronosync/helpers.dart';
import 'package:flutter/material.dart' as mat;
import 'package:shadcn_flutter/shadcn_flutter.dart';

class TimeSelect extends mat.StatefulWidget {
  final DateTime now;
  final DateTime start;
  final DateTime end;
  final Function() unselect;

  const TimeSelect(
      {super.key,
      required this.now,
      required this.start,
      required this.end,
      required this.unselect});

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

  void setClock(BuildContext context) {
    DateTime date = mat.DateUtils.dateOnly(widget.now);

    if (inTime >= outTime) {
      showToast(
          context: context,
          builder: buildToast("Clock-In Must Occur Before Clock-Out.", true));
      return;
    }

    String inTimeStr = timeStr(inTime), outTimeStr = timeStr(outTime);

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
                    style: TextStyle(color: Colors.white),
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
                  widget.unselect();

                  // Actual working database insert of new ClockDate object
                  dbOps("C", clock: ClockDate(date: date, inTime: inTime, outTime: outTime))
                      .then((v) {
                    // print("New Clock-In on $date from $inTime to $outTime");
                    if (!context.mounted) return;
                    showToast(
                        context: context,
                        builder: buildToast("Clock-In Saved to Device.", true));
                  });
                },
              ),
            ],
            actionsCenterAlign: true,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return mat.Scaffold(
      floatingActionButton: mat.FloatingActionButton.extended(
        backgroundColor: Colors.transparent,
        onPressed: null,
        label: PrimaryButton(
          onPressed: () => setClock(context),
          trailing: ImageIcon(
            AssetImage("lib/assets/download.png"),
            size: 22,
            color: Colors.black,
          ),
          child: Text(
            "Save Clock-In",
            style: TextStyle(fontSize: 18),
          ).sans().semiBold(),
        ),
      ),
      floatingActionButtonLocation:
          mat.FloatingActionButtonLocation.centerFloat,
      body: Scaffold(
        headers: [
          mat.AppBar(
            leading: Container(
              alignment: Alignment.center,
              child: IconButton.ghost(
                onPressed: () => widget.unselect(),
                alignment: Alignment.center,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                density: ButtonDensity.iconDense,
              ),
            ),
            title: Text(dateStr(widget.now),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white))
                .h4()
                .sans(),
            centerTitle: true,
          )
        ],
        child: Container(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Text(
                "Select Clock-In/Out Times",
                style: TextStyle(fontSize: 24),
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
        ).h2(pad: 0).sans(),
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
