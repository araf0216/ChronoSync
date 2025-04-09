import 'package:shadcn_flutter/shadcn_flutter.dart';

Widget backGesture({required BuildContext context, required Widget child, required Function() action}) {
  double swipeStart = 500;

  return GestureDetector(
    child: child,
    onHorizontalDragStart: (details) {
      swipeStart = details.localPosition.dx;
    },
    onHorizontalDragEnd: (details) {
      double swipeEnd = details.localPosition.dx;
      if (swipeStart < 16 && swipeEnd > 100) action();
      swipeStart = 500;
    },
  );
}
