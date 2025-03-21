import 'package:shadcn_flutter/shadcn_flutter.dart';

Widget userDrop(BuildContext context, Function() logOut, bool signedIn) {
  return DropdownMenu(
    children: [
      if (signedIn) MenuLabel(child: Text('My Account').sans()),
      if (signedIn) MenuDivider(),
      MenuButton(
        trailing: Icon(BootstrapIcons.sliders),
        child: Text('Settings').sans(),
      ),
      MenuDivider(),
      MenuButton(
        trailing: Icon(BootstrapIcons.github),
        child: Text('GitHub').sans(),
      ),
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
