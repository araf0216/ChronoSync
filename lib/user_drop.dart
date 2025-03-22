import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

Widget userDrop(BuildContext context, Function() logOut, bool signedIn) {
  return DropdownMenu(
    children: [
      if (signedIn) MenuLabel(child: Text('My Account').sans()),
      if (signedIn) MenuDivider(),
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
                          Widget buildToast(BuildContext context, ToastOverlay overlay) {
                            return SurfaceCard(
                              child: Basic(
                                subtitle: const Text('Link copied to clipboard'),
                                subtitleAlignment: Alignment.center,
                              ),
                            );
                          }
                          showToast(
                            context: context,
                            builder: buildToast,
                            location: ToastLocation.bottomCenter,
                          );
                          await Clipboard.setData(ClipboardData(
                              text: "https://github.com/araf0216/Clockify"));
                        },
                        child: Text(
                          "https://github.com/araf0216/Clockify",
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
      if (signedIn) MenuDivider(),
      if (signedIn)
        MenuButton(
          trailing: Icon(BootstrapIcons.exclamationCircle, color: Colors.red),
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
                            textAlign: TextAlign.center,
                          ).sans().semiBold(),
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
          ).sans().semiBold(),
        ),
    ],
  );
}
