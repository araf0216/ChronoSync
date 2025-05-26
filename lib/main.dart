import 'package:chronosync/current.dart';
import 'package:chronosync/encryption.dart';
import 'package:chronosync/lifecycle.dart';
import 'package:chronosync/prior.dart';
import 'package:chronosync/user.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' as mat;
import 'package:shared_preferences/shared_preferences.dart';
import 'nav.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final LifeCycleManager _lifeCycleListener;

  void migrationCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? user_ = prefs.getString("user"), pass_ = prefs.getString("pass");

    // unencrypted data check + migration + legacy removal
    if (user_ != null || pass_ != null) {
      // complete presence -> migrate to encrypted
      if (user_ != null && pass_ != null) {
        // print("triggered migration");
        SecureDataCache.single.storeDevice(user_, pass_);
      }

      // delete unencrypted
      await prefs.remove("user");
      await prefs.remove("pass");
    }
  }

  void clearCache() async {
    SecureDataCache.single.pause();
  }

  @override
  void initState() {
    super.initState();
    migrationCheck();
    _lifeCycleListener = LifeCycleManager();
    _lifeCycleListener.onPause(clearCache);
  }

  int? _selectedIndex;
  static const List<Widget> screens = <Widget>[
    PriorScreen(),
    CurrentScreen(),
    UserScreen()
  ];

  @override
  void dispose() {
    _lifeCycleListener.dispose(pause: clearCache);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadcnApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorSchemes.darkBlue(),
        typography: Typography.geist(),
        radius: 0.5,
      ),
      home: mat.Scaffold(
        body: screens[_selectedIndex ?? 1],
        bottomNavigationBar: BottomNavBar(
          onSelect: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
