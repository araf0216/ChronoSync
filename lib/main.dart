import 'package:clockify/home.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
// import 'clockdb.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return ShadcnApp(
      theme: ThemeData(
        colorScheme: ColorSchemes.darkBlue(),
        typography: Typography.geist(),
        radius: 0.5,
      ),
      home: HomeScreen(),
    );
  }
}
