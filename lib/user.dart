import 'package:clockify/card.dart';
import 'package:clockify/user_drop.dart';
import 'package:flutter/material.dart' as mat;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'history.dart';
import 'package:intl/intl.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool userSet = false;
  String user = "User";
  String pass = "";
  Future? loading;

  @override
  void initState() {
    super.initState();
    loading = isUserSet();
  }

  Future<bool> isUserSet() async {
    print("running isUserSet");

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? user_ = prefs.getString("user"), pass_ = prefs.getString("pass");

    if (user_ == null || pass_ == null) {
      print("no user vars found on device");
      return false;
    }

    if (user_ == "User" || user_ == "" || pass_ == "") {
      print("found default user vars - not signed in");
      return false;
    }

    print("Found User: $user_ & Pass: $pass_!");

    setState(() {
      user = user_;
      pass = pass_;
      userSet = true;
    });

    return true;
  }

  Future<void> setUser(String user_, String pass_) async {
    print("running setUser from user.dart");
    print("received $user_ - $pass_");

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (user_ == "User" || user_ == "" || pass_ == "") {
      await prefs.remove("user");
      await prefs.remove("pass");
      return;
    }

    print(
        "setting the given strings to sharedprefs: User - [$user_] & Pass - [$pass_]");

    await prefs.setString("user", user_);
    await prefs.setString("pass", pass_);

    setState(() {
      user = user_;
      pass = pass_;
      userSet = true;
    });
  }

  Future<void> logoutUser() async {
    print("logging out the following user:");

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String user_ = prefs.getString("user") ?? "User",
        pass_ = prefs.getString("pass") ?? "";

    print("User: [$user_] - Pass: [$pass_]");

    await prefs.remove("user");
    await prefs.remove("pass");

    setState(() {
      user = "User";
      pass = "";
      userSet = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: Stack(children: [
            Text(
              "Welcome, ${toBeginningOfSentenceCase(user.split(".")[0])}",
              style: TextStyle(fontSize: 24),
            ).h2().sans().center(),
            Container(
              alignment: Alignment.topRight,
              child: IconButton(
                // size: ButtonSize(1 / 3),
                variance: ButtonVariance.fixed,
                onPressed: () {
                  showPopover(
                    alignment: Alignment.center,
                    context: context,
                    builder: (context) {
                      return userDrop(context, logoutUser, userSet);
                    },
                  );
                },
                icon: Icon(
                  // BootstrapIcons.threeDots,
                  BootstrapIcons.sliders,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ]),
          alignment: Alignment.center,
        ),
      ],
      child: mat.Container(
        alignment: Alignment.center,
        child: FutureBuilder(
          future: loading,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return CircularProgressIndicator();
            }

            return SingleChildScrollView(
              child: !userSet ? loginCard(context, setUser) : ClockTimeline(),
            );
          },
        ),
      ),
    );
  }
}
