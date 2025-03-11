import 'package:shadcn_flutter/shadcn_flutter.dart';

String timeStr(TimeOfDay time) {
  return "${(time.hour > 12 || time.hour == 0) ? (time.hour - 12).abs() : time.hour}:${(time.minute).toString().padLeft(2, '0')} ${time.hour >= 12 ? "PM" : "AM"}";
}

String dateStr(DateTime date) {
  return "${date.month}/${date.day}/${date.year % 100}";
}
