import 'package:clockify/clockdb.dart';
import 'package:clockify/helpers.dart';
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

  @override
  void initState() {
    super.initState();
    getClocks();
  }

  void getClocks() async {
    List<ClockDate> clocks_ = await dbOps("R");

    if (clocks_.isEmpty) {
      print("no clocks LMAO");
    } else {
      print("clocks found!");
      setState(() {
        clocks = clocks_.toList();
      });
    }
  }

  void deleteClock(int id) async {
    await dbOps("D", id: id);
    getClocks();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                          onPressed: clocks[i].isUploaded
                              ? () {
                                  Widget buildToast(BuildContext context,
                                      ToastOverlay overlay) {
                                    return SurfaceCard(
                                      child: Basic(
                                        title: const Text('Event already uploaded').sans(),
                                        trailing: PrimaryButton(
                                          size: ButtonSize.small,
                                          onPressed: () {
                                            overlay.close();
                                          },
                                          child: const Text('Close').sans(),
                                        ),
                                        trailingAlignment: Alignment.center,
                                      ),
                                    );
                                  }
                                  showToast(
                                      context: context,
                                      builder: buildToast,
                                      location: ToastLocation.bottomCenter);
                                }
                              : () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Container(
                                        alignment: Alignment.center,
                                        width:
                                            MediaQuery.of(context).size.width *
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
                                              onPressed: () {
                                                APIService api = APIService();
                                                api.apiUpload(
                                                  date: clocks[i].date,
                                                  inTime: clocks[i].inTime,
                                                  outTime: clocks[i].outTime,
                                                );
                                                clocks[i].isUploaded = true;
                                                dbOps("U", clock: clocks[i]);
                                                Navigator.pop(context);
                                                Widget buildToast(
                                                    BuildContext context,
                                                    ToastOverlay overlay) {
                                                  return SurfaceCard(
                                                    child: Basic(
                                                      title: const Text('Clock-In Event has been uploaded').sans(),
                                                      trailing: PrimaryButton(
                                                        size:ButtonSize.small,
                                                        onPressed: () {
                                                          overlay.close();
                                                        },
                                                        child: const Text('Close').sans(),
                                                      ),
                                                      trailingAlignment: Alignment.center,
                                                    ),
                                                  );
                                                }
                                                showToast(
                                                  context: context,
                                                  builder: buildToast,
                                                  location: ToastLocation.bottomCenter,
                                                );
                                                setState(() {});
                                              },
                                            )
                                          ],
                                          actionsCenterAlign: true,
                                        ),
                                      );
                                    },
                                  );
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
                                                    .format(clocks[i].date),
                                                style: TextStyle(
                                                    color: Colors.white))
                                            .sans(),
                                        Text(
                                          "${timeStr(clocks[i].inTime)} - ${timeStr(clocks[i].outTime)}",
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
                                    DestructiveButton(
                                      child: Text("Delete").sans(),
                                      onPressed: () {
                                        deleteClock(clocks[i].id);
                                        Navigator.pop(context);
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
