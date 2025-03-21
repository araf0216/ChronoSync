import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

String timeStr(TimeOfDay time) {
  return "${(time.hour > 12 || time.hour == 0) ? (time.hour - 12).abs() : time.hour}:${(time.minute).toString().padLeft(2, '0')} ${time.hour >= 12 ? "PM" : "AM"}";
}

String dateStr(DateTime date) {
  return "${date.month}/${date.day}/${date.year % 100}";
}

String dateStrPost(DateTime date) {
  return DateFormat("yyyy-MM-dd").format(date);
}

String timeStrPost(TimeOfDay time) {
  return "${time.hour.toString().padLeft(2, "0")}:${time.minute.toString().padLeft(2, "0")}:00";
}
