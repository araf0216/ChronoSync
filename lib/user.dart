import 'package:chronosync/back_gesture.dart';
import 'package:chronosync/login.dart';
import 'package:chronosync/encryption.dart';
import 'package:chronosync/licenses.dart';
import 'package:chronosync/lifecycle.dart';
import 'package:chronosync/user_drop.dart';
import 'package:flutter/material.dart' as mat;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'history.dart';
import 'package:intl/intl.dart';
// import 'package:local_auth/local_auth.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool userSaved = false;
  bool? authComplete;
  bool paused = false;
  late final LifeCycleManager _lifeCycleListener;

  String user = SecureDataCache.single.user ?? "";
  String pass = "";

  Future? loading;

  bool viewLicenses = false;

  // wip
  bool viewClocks = false;
  bool refreshToggle = false;

  @override
  void initState() {
    super.initState();
    _lifeCycleListener = LifeCycleManager();
    _lifeCycleListener.onResume(resumeBuild);
    _lifeCycleListener.onPause(clearBuild);
    loading = userSetStatus();
  }

  void resumeBuild() async {
    if (!mounted || !userSaved || authComplete != null) return;
    // found userSaved -> reauthenticate on resume after pause
    if (paused) {
      setState(() {
        paused = false;
      });
      loading = userSetStatus();
    }
  }

  void clearBuild() {
    // print("pausing");
    if (mounted && userSaved) {
      setState(() {
        authComplete = null;
        paused = true;
      });
    }
  }

  Future<bool> unlockUser() async {
    bool loadSuccess = await SecureDataCache.single.loadMemory();

    if (mounted) {
      setState(() {
        authComplete = loadSuccess;
      });
    }

    return loadSuccess;
  }

  @override
  void dispose() {
    _lifeCycleListener.dispose(resume: resumeBuild, pause: clearBuild);
    super.dispose();
  }

  Future<bool> userSetStatus() async {
    // print("running userSetStatus");

    // encrypted user existence check
    bool userSaved_ = await SecureDataCache.single.userSaved();

    // no pre-existing -> exit default userSaved
    if (!userSaved_) {
      // print("no user found saved");
      return true;
    }

    // line reached -> confirmed userSaved = true
    setState(() {
      userSaved = true;
    });

    bool isCached;

    // user not cached to memory -> decrypt with auth + load to memory
    if (!SecureDataCache.single.userCached()) {
      // print("not cached");
      isCached = false;
    }

    // unlocked user exists in cache -> setUser() without unlockUser()
    else {
      // print("Found User: [${SecureDataCache.single.user}]!");
      if (SecureDataCache.single.pass == "cancelled") {
        setState(() {
          authComplete = false;
        });

        return true;
      }
      isCached = true;
    }

    // line reached -> auth + load successful
    await setUser(SecureDataCache.single.user, SecureDataCache.single.pass, isLocked: !isCached);

    return true;
  }

  Future<void> setUser(String? user_, String? pass_, {bool isLocked = true}) async {
    // print("setUser triggered");

    // user on disk, not cache -> unlock user - resume
    if (isLocked) {
      bool authSuccess = await unlockUser();
      if (authSuccess) {
        user_ = SecureDataCache.single.user;
        pass_ = SecureDataCache.single.pass;
      } else {
        setState(() {
          authComplete = false;
        });

        return;
      }
    }

    // null check
    if (user_ == null || pass_ == null) return;

    // empty check
    if (user_.isEmpty || pass_.isEmpty) {
      return;
    }

    // no user on disk -> encrypt + store user to disk - initial login
    if (!userSaved) {
      bool storeSuccess = await SecureDataCache.single.storeDevice(user_, pass_);

      if (!storeSuccess) return;
      // fail toast can go here
    }

    if (mounted) {
      // print("confirming/setting user to present state");
      setState(() {
        user = user_!;
        pass = pass_!;
        userSaved = true;
        authComplete = true;
      });
    }
  }

  Future<void> logoutUser() async {
    // print("logging out current user");

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? user_ = prefs.getString("user"), pass_ = prefs.getString("pass");

    if (user_ != null || pass_ != null) {
      // print("removing unsecure user data found in sharedprefs");
      await prefs.remove("user");
      await prefs.remove("pass");
    }

    SecureDataCache.single.clear(removeKey: true);
    await prefs.remove("secureUser");

    setState(() {
      user = "";
      pass = "";
      userSaved = false;
      authComplete = false;
    });
  }

  void getPage([String page = ""]) {
    setState(() {
      // ToDo - replace with switch case
      viewLicenses = page == "licenses";
      viewClocks = page == "clocks";
      refreshToggle = page == "" ? !refreshToggle : refreshToggle;
    });
  }

  @override
  Widget build(BuildContext context) {
    String name = (user.isEmpty || user == "failed") ? "User" : toBeginningOfSentenceCase(user.split(".")[0]);

    return Scaffold(
      headers: [
        if (!viewLicenses)
          AppBar(
            title: Stack(children: [
              mat.Column(
                children: [
                  Text(
                    "Welcome, $name",
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
                        return userDrop(context, logoutUser, userSaved, getPage);
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

                  bool onlyAuth = userSaved && authComplete == false;
                  Function loginFunc = onlyAuth ? unlockUser : setUser;

                  return Scrollbar(
                    child: SingleChildScrollView(
                      child: userSaved && authComplete == true
                          ? Data.inherit(
                              data: refreshToggle,
                              child: ClockTimeline(),
                            )
                          : loginCard(context, onlyAuth, loginFunc, getPage),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
