import 'package:shadcn_flutter/shadcn_flutter.dart';

class BackGesture extends StatelessWidget {
  final Widget child;
  final Function() action;
  const BackGesture({super.key, required this.child, required this.action});

  @override
  Widget build(BuildContext context) {
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
}
