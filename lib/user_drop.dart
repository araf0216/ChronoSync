import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:chronosync/clockdb.dart';

Future<void> deleteAll() async {
  await dbOps("DELETE");
}

Widget buildToast(BuildContext context, ToastOverlay overlay) {
  return SurfaceCard(
    child: Basic(
      subtitle: const Text('Link copied to clipboard'),
      subtitleAlignment: Alignment.center,
    ),
  );
}

Widget userDrop(BuildContext context, Function() logOut, bool signedIn,
    Function([String]) viewUpdate) {
  return DropdownMenu(
    children: [
      if (signedIn) MenuLabel(child: Text('My Account').sans()),
      if (signedIn) MenuDivider(),
      MenuButton(
        trailing: ImageIcon(
          AssetImage("lib/assets/lawL.png"),
          color: Colors.white,
        ),
        child: Text("Licenses").sans(),
        onPressed: (context) => viewUpdate("licenses"),
      ),
      MenuDivider(),
      MenuButton(
        trailing: Icon(BootstrapIcons.shieldLock),
        child: Text("Privacy Policy").sans(),
        onPressed: (context) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Center(
                    child: Text("Privacy Policy", textAlign: TextAlign.center)
                        .h3()
                        .sans()),
                content: Column(
                  children: [
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          showToast(
                            context: context,
                            builder: buildToast,
                            location: ToastLocation.bottomCenter,
                          );
                          await Clipboard.setData(ClipboardData(
                              text:
                                  "https://github.com/araf0216/Chronosync#privacy-policy"));
                        },
                        child: Text(
                          "https://github.com/araf0216/Chronosync#privacy-policy",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            fontSize: 16,
                          ),
                        ).sans(),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      MenuButton(
        trailing: Icon(BootstrapIcons.github),
        child: Text('GitHub').sans(),
        onPressed: (context) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Center(
                    child: Text("Source", textAlign: TextAlign.center)
                        .h3()
                        .sans()),
                content: Column(
                  children: [
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          showToast(
                            context: context,
                            builder: buildToast,
                            location: ToastLocation.bottomCenter,
                          );
                          await Clipboard.setData(ClipboardData(
                              text: "https://github.com/araf0216/Chronosync"));
                        },
                        child: Text(
                          "https://github.com/araf0216/Chronosync",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            fontSize: 16,
                          ),
                        ).sans(),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      MenuDivider(),
      MenuButton(
        trailing: Icon(BootstrapIcons.exclamationCircle, color: Colors.red),
        onPressed: (context) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Center(
                    child: Text(
                      "Confirm Delete",
                      style: TextStyle(fontSize: 24),
                    ).h2(pad: 0).sans(),
                  ),
                  content: Center(
                    child: Column(
                      children: [
                        Text(
                          "Delete all Check-In Events from device storage?",
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ).sans(),
                        Gap(16),
                        Text(
                          "Note: No information is stored outside of the device.",
                          textAlign: TextAlign.center,
                        ).sans(),
                        Gap(8),
                      ],
                    ),
                  ),
                  actions: [
                    SecondaryButton(
                      child: Text("Cancel").sans(),
                      onPressed: () => Navigator.pop(context),
                    ),
                    DestructiveButton(
                      child: Text(
                        "Delete All",
                        style: TextStyle(color: Colors.white),
                      ).sans(),
                      onPressed: () async {
                        await deleteAll();
                        viewUpdate();
                        Navigator.pop(context);
                      },
                    )
                  ],
                  actionsCenterAlign: true,
                );
              });
        },
        child: Text(
          'Delete All',
          style: TextStyle(color: Colors.red, fontSize: 20),
        ).sans(),
      ),
      if (signedIn)
        MenuButton(
          trailing: ImageIcon(
            AssetImage("lib/assets/log-out.png"),
            color: Colors.red,
          ),
          onPressed: (context) {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Center(
                      child: Text(
                        "Confirm Sign Out",
                        style: TextStyle(fontSize: 24),
                      ).h2(pad: 0).sans(),
                    ),
                    content: Center(
                      child: Column(
                        children: [
                          Text(
                            "You are about to log out.",
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ).sans(),
                          Gap(8),
                        ],
                      ),
                    ),
                    actions: [
                      SecondaryButton(
                        child: Text("Cancel").sans(),
                        onPressed: () => Navigator.pop(context),
                      ),
                      DestructiveButton(
                        child: Text("Log Out").sans(),
                        onPressed: () {
                          logOut();
                          Navigator.pop(context);
                        },
                      )
                    ],
                    actionsCenterAlign: true,
                  );
                });
          },
          child: Text(
            'Log Out',
            style: TextStyle(color: Colors.red, fontSize: 20),
          ).sans(),
        ),
      MenuDivider()
    ],
  );
}
