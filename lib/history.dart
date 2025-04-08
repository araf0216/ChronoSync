import 'package:chronosync/clockdb.dart';
import 'package:chronosync/helpers.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:intl/intl.dart';
import 'api.dart';

class ClockTimeline extends StatefulWidget {
  const ClockTimeline({super.key});

  @override
  State<ClockTimeline> createState() => ClockTimelineState();
}

class ClockTimelineState extends State<ClockTimeline> {
  List<ClockDate> clocks = [];
  String user = "User";
  String pass = "";
  bool toggleRefresh = false;

  @override
  void initState() {
    super.initState();
    getClocks();
  }

  Future<void> getClocks() async {
    List<ClockDate> clocks_ = await dbOps("R");

    if (clocks_.isEmpty) {
      // print("no clocks LMAO");
    } else {
      // print("clocks found!");
      setState(() {
        clocks = clocks_.toList();
      });
    }
  }

  Future<void> deleteClock(int id) async {
    await dbOps("D", id: id);
    setState(() {
      clocks = [];
    });
    getClocks();
  }

  @override
  Widget build(BuildContext context) {
    bool? toggleData = Data.maybeOf(context);
    if (toggleData != null && toggleRefresh != toggleData) {
      setState(() {
        toggleRefresh = toggleData;
        clocks = [];
      });
      getClocks();
    }

    return clocks.isEmpty
        ? Text(
            "Your Clock-In Events Will Appear Here.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ).sans().withPadding(horizontal: 20)
        : Container(
            padding: EdgeInsets.only(left: 32, right: 32),
            child: Timeline(
              altTimeLocation: true,
              data: [
                for (var i = clocks.length - 1; i >= 0; i--)
                  TimelineData(
                    time: Text(dateStr(clocks[i].date)).sans(),
                    title: Text(dateStr(clocks[i].date)).sans(),
                    content: SurfaceCard(
                      child: Basic(
                        title: const Text('Check-In Event Created',
                                style: TextStyle(height: 1.15))
                            .sans(),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat("EEE, MMM dd, yyyy")
                                    .format(clocks[i].date))
                                .sans(),
                            Text(
                              "${timeStr(clocks[i].inTime)} - ${timeStr(clocks[i].outTime)}",
                              style: TextStyle(color: Colors.white),
                            ).small().sans(),
                          ],
                        ),
                        trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  clocks[i].isUploaded
                                      ? BootstrapIcons.cloudCheck
                                      : BootstrapIcons.cloudUpload,
                                  size: 20,
                                  color: clocks[i].isUploaded
                                      ? Colors.green[400]
                                      : Colors.blue,
                                ),
                                size: ButtonSize.xSmall,
                                variance: ButtonVariance.card,
                                onPressed: () {
                                  if (clocks[i].isUploaded) {
                                    showToast(
                                      context: context,
                                      builder: buildToast('Event already uploaded.', true),
                                      location: ToastLocation.bottomCenter,
                                    );
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Container(
                                          alignment: Alignment.center,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          child: AlertDialog(
                                            title: Center(
                                              child: Text(
                                                "Confirm Check-In",
                                                style: TextStyle(fontSize: 24),
                                              ).h2(pad: 0).sans(),
                                            ),
                                            content: Center(
                                              child: Column(
                                                children: [
                                                  Gap(4),
                                                  Text("Confirm Time Selections")
                                                      .sans(),
                                                  Gap(4),
                                                  Text(
                                                    DateFormat("MM/dd/yyyy")
                                                        .format(clocks[i].date),
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ).sans(),
                                                  Text(
                                                    "${timeStr(clocks[i].inTime)} - ${timeStr(clocks[i].outTime)}",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ).base().sans(),
                                                  Gap(4),
                                                  Text("No Further Changes")
                                                      .sans()
                                                      .semiBold(),
                                                  Text("Beyond This Point")
                                                      .sans()
                                                      .semiBold(),
                                                  Gap(4),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              SecondaryButton(
                                                child: Text("Cancel").sans(),
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                              ),
                                              PrimaryButton(
                                                child: Text("OK").sans(),
                                                onPressed: () async {
                                                  Navigator.pop(context);
                                                  context = Navigator.of(context).context;

                                                  APIService api = APIService();
                                                  await api.apiUpload(
                                                    date: clocks[i].date,
                                                    inTime: clocks[i].inTime,
                                                    outTime: clocks[i].outTime,
                                                  );

                                                  clocks[i].isUploaded = true;
                                                  await dbOps("U",
                                                      clock: clocks[i]);

                                                  await getClocks();

                                                  if (!context.mounted) return;
                                                  showToast(
                                                    context: context,
                                                    builder: buildToast('Clock-In Event has been uploaded.', true),
                                                    location: ToastLocation.bottomCenter,
                                                  );
                                                },
                                              )
                                            ],
                                            actionsCenterAlign: true,
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                              Gap(20),
                              IconButton(
                                icon: Icon(BootstrapIcons.trash,
                                    size: 20, color: Colors.red),
                                size: ButtonSize.xSmall,
                                variance: ButtonVariance.card,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Center(
                                          child: Text(
                                            "Delete Check-In",
                                            style: TextStyle(fontSize: 24),
                                          ).h2(pad: 0).sans(),
                                        ),
                                        content: Center(
                                          child: Column(
                                            children: [
                                              Text("Confirm Selected Time Deletion")
                                                  .sans(),
                                              Gap(4),
                                              Text(
                                                      DateFormat("MM/dd/yyyy")
                                                          .format(
                                                              clocks[i].date),
                                                      style: TextStyle(
                                                          color: Colors.white))
                                                  .sans(),
                                              Text(
                                                "${timeStr(clocks[i].inTime)} - ${timeStr(clocks[i].outTime)}",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ).base().sans(),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          SecondaryButton(
                                            child: Text("Cancel").sans(),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                          DestructiveButton(
                                            child: Text("Delete").sans(),
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              context = Navigator.of(context).context;

                                              await deleteClock(clocks[i].id);

                                              if (!context.mounted) return;
                                              showToast(
                                                context: context,
                                                builder: buildToast('Clock-In Event Has Been Deleted.', true),
                                                location: ToastLocation.bottomCenter,
                                              );
                                            },
                                          )
                                        ],
                                        actionsCenterAlign: true,
                                      );
                                    },
                                  );
                                },
                              ),
                            ]),
                      ),
                    ),
                  ),
              ],
            ),
          );
  }
}
