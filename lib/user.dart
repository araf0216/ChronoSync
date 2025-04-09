import 'package:chronosync/back_gesture.dart';
import 'package:chronosync/card.dart';
import 'package:chronosync/licenses.dart';
import 'package:chronosync/user_drop.dart';
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
  bool viewLicenses = false;
  bool viewClocks = false;
  bool refreshToggle = false;

  @override
  void initState() {
    super.initState();
    loading = isUserSet();
  }

  Future<bool> isUserSet() async {
    // print("running isUserSet");

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? user_ = prefs.getString("user"), pass_ = prefs.getString("pass");

    if (user_ == null || pass_ == null) {
      // print("no user vars found on device");
      return false;
    }

    if (user_ == "User" || user_ == "" || pass_ == "") {
      // print("found default user vars - not signed in");
      return false;
    }

    // print("Found User: [$user_]!");

    await setUser(user_, pass_);

    return true;
  }

  Future<void> setUser(String user_, String pass_) async {
    // print("storing user to device storage");

    if (user_ == "User" || user_ == "" || pass_ == "") {
      return;
    }

    // storing non-null user info to device storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("user", user_);
    await prefs.setString("pass", pass_);

    setState(() {
      user = user_;
      pass = pass_;
      userSet = true;
    });
  }

  Future<void> logoutUser() async {
    // print("logging out current user");

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? user_ = prefs.getString("user"), pass_ = prefs.getString("pass");

    if (user_ != null) await prefs.remove("user");
    if (pass_ != null) await prefs.remove("pass");

    setState(() {
      user = "User";
      pass = "";
      userSet = false;
    });
  }

  void getPage([String page = ""]) {
    setState(() {
      viewLicenses = page == "licenses";
      viewClocks = page == "clocks";
      refreshToggle = page == "" ? !refreshToggle : refreshToggle;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        if (!viewLicenses)
          AppBar(
            title: Stack(children: [
              mat.Column(
                children: [
                  Text(
                    "Welcome, ${toBeginningOfSentenceCase(user.split(".")[0])}",
                    style: TextStyle(fontSize: 24),
                  ).h2().sans().center(),
                ],
              ),
              Container(
                alignment: Alignment.topRight,
                child: IconButton(
                  variance: ButtonVariance.fixed,
                  onPressed: () {
                    showPopover(
                      alignment: Alignment.center,
                      context: context,
                      builder: (context) {
                        return userDrop(context, logoutUser, userSet, getPage);
                      },
                    );
                  },
                  icon: Icon(
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
      child: viewLicenses
          ? BackGesture(
              action: getPage,
              child: LicensesPage(
                exit: getPage,
              ),
            )
          : mat.Container(
              alignment: Alignment.center,
              child: FutureBuilder(
                future: loading,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return CircularProgressIndicator(size: 32);
                  }

                  return SingleChildScrollView(
                    child: !userSet && !viewClocks
                        ? loginCard(context, setUser, getPage)
                        : Data.inherit(
                            data: refreshToggle,
                            child: ClockTimeline(),
                          ),
                  );
                },
              ),
            ),
    );
  }
}
