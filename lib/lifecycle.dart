// ignore_for_file: unused_field

import 'package:shadcn_flutter/shadcn_flutter.dart';

class LifeCycleManager {
  static final LifeCycleManager _instance = LifeCycleManager._internal();

  factory LifeCycleManager() {
    return _instance;
  }

  final Set<Function> _onResume = {};
  final Set<Function> _onPause = {};

  late final AppLifecycleListener _listener;

  void onResume(Function action) {
    _instance._onResume.add(action);
  }

  void onPause(Function action) {
    _instance._onPause.add(action);
  }

  void dispose({Function? resume, Function? pause}) {
    if (resume != null) _instance._onResume.remove(resume);
    if (pause != null) _instance._onPause.remove(pause);
  }

  LifeCycleManager._internal() {
    _listener = AppLifecycleListener(
      onResume: () {
        for (final action in _onResume) {
          action();
        }
      },
      onPause: () {
        for (final action in _onPause) {
          action();
        }
      }
    );
  }
}
