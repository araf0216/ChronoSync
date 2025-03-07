// // import 'package:flutter/foundation.dart';
// import 'package:shadcn_flutter/shadcn_flutter.dart';

// enum CalendarViewType {
//   date,
//   month,
//   year,
// }

// // enum DateState {
// //   disabled,
// //   enabled,
// // }

// typedef DateStateBuilder = DateState Function(DateTime date);

// abstract class CalendarValue {
//   CalendarValueLookup lookup(int year, [int? month = 1, int? day = 1]);
//   const CalendarValue();
//   static SingleCalendarValue single(DateTime date) {
//     return SingleCalendarValue(date);
//   }

//   // static RangeCalendarValue range(DateTime start, DateTime end) {
//   //   return RangeCalendarValue(start, end);
//   // }

//   // static MultiCalendarValue multi(List<DateTime> dates) {
//   //   return MultiCalendarValue(dates);
//   // }

//   SingleCalendarValue toSingle();
//   // RangeCalendarValue toRange();
//   // MultiCalendarValue toMulti();

//   CalendarView get view;
// }

// DateTime _convertNecessarry(DateTime from, int year, [int? month, int? date]) {
//   if (month == null) {
//     return DateTime(from.year);
//   }
//   if (date == null) {
//     return DateTime(from.year, from.month);
//   }
//   return DateTime(from.year, from.month, from.day);
// }

// class SingleCalendarValue extends CalendarValue {
//   final DateTime date;

//   SingleCalendarValue(this.date);

//   @override
//   CalendarValueLookup lookup(int year, [int? month, int? day]) {
//     DateTime current = _convertNecessarry(date, year, month, day);
//     if (current.isAtSameMomentAs(DateTime(year, month ?? 1, day ?? 1))) {
//       return CalendarValueLookup.selected;
//     }
//     return CalendarValueLookup.none;
//   }

//   @override
//   CalendarView get view => CalendarDateTime(date).toCalendarView();

//   @override
//   String toString() {
//     return 'SingleCalendarValue($date)';
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;

//     return other is SingleCalendarValue && other.date == date;
//   }

//   @override
//   int get hashCode => date.hashCode;

//   @override
//   SingleCalendarValue toSingle() {
//     return this;
//   }

//   // @override
//   // RangeCalendarValue toRange() {
//   //   return CalendarValue.range(date, date);
//   // }

//   // @override
//   // MultiCalendarValue toMulti() {
//   //   return CalendarValue.multi([date]);
//   // }
// }

// enum CalendarValueLookup { none, selected, start, end, inRange }

// class CalendarView {
//   final int year;
//   final int month;

//   CalendarView(this.year, this.month) {
//     assert(month >= 1 && month <= 12, 'Month must be between 1 and 12');
//   }
//   factory CalendarView.now() {
//     DateTime now = DateTime.now();
//     return CalendarView(now.year, now.month);
//   }
//   factory CalendarView.fromDateTime(DateTime dateTime) {
//     return CalendarView(dateTime.year, dateTime.month);
//   }

//   CalendarView get next {
//     if (month == 12) {
//       return CalendarView(year + 1, 1);
//     }
//     return CalendarView(year, month + 1);
//   }

//   CalendarView get previous {
//     if (month == 1) {
//       return CalendarView(year - 1, 12);
//     }
//     return CalendarView(year, month - 1);
//   }

//   CalendarView get nextYear {
//     return CalendarView(year + 1, month);
//   }

//   CalendarView get previousYear {
//     return CalendarView(year - 1, month);
//   }

//   @override
//   String toString() {
//     return 'CalendarView($year, $month)';
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;

//     return other is CalendarView && other.year == year && other.month == month;
//   }

//   @override
//   int get hashCode => year.hashCode ^ month.hashCode;

//   CalendarView copyWith({
//     int? year,
//     int? month,
//   }) {
//     return CalendarView(
//       year ?? this.year,
//       month ?? this.month,
//     );
//   }
// }

// extension CalendarDateTime on DateTime {
//   CalendarView toCalendarView() {
//     return CalendarView.fromDateTime(this);
//   }

//   CalendarValue toCalendarValue() {
//     return CalendarValue.single(this);
//   }
// }

// enum CalendarSelectionMode {
//   none,
//   single,
//   range,
//   multi,
// }

// class Calendar extends StatefulWidget {
//   final DateTime? now;
//   final CalendarValue? value;
//   final CalendarView view;
//   final CalendarSelectionMode selectionMode;
//   final ValueChanged<CalendarValue?>? onChanged;
//   final bool Function(DateTime date)? isDateEnabled;
//   final DateStateBuilder? stateBuilder;

//   const Calendar({
//     super.key,
//     this.now,
//     this.value,
//     required this.view,
//     required this.selectionMode,
//     this.onChanged,
//     this.isDateEnabled,
//     this.stateBuilder,
//   });

//   @override
//   State<Calendar> createState() => _CalendarState();
// }

// class _CalendarState extends State<Calendar> {
//   late CalendarGridData _gridData;

//   @override
//   void initState() {
//     super.initState();
//     _gridData =
//         CalendarGridData(month: widget.view.month, year: widget.view.year);
//   }

//   @override
//   void didUpdateWidget(covariant Calendar oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.view.year != widget.view.year ||
//         oldWidget.view.month != widget.view.month) {
//       _gridData =
//           CalendarGridData(month: widget.view.month, year: widget.view.year);
//     }
//   }

//   void _handleTap(DateTime date) {
//     var calendarValue = widget.value;
//     if (widget.selectionMode == CalendarSelectionMode.none) {
//       return;
//     }
//     if (widget.selectionMode == CalendarSelectionMode.single) {
//       if (calendarValue is SingleCalendarValue &&
//           date.isAtSameMomentAs(calendarValue.date)) {
//         widget.onChanged?.call(null);
//         return;
//       }
//       widget.onChanged?.call(CalendarValue.single(date));
//       return;
//     }
//     // if (widget.selectionMode == CalendarSelectionMode.multi) {
//     //   if (calendarValue == null) {
//     //     widget.onChanged?.call(CalendarValue.single(date));
//     //     return;
//     //   }
//     //   final lookup = calendarValue.lookup(date.year, date.month, date.day);
//     //   if (lookup == CalendarValueLookup.none) {
//     //     var multi = calendarValue.toMulti();
//     //     (multi).dates.add(date);
//     //     widget.onChanged?.call(multi);
//     //     return;
//     //   } else {
//     //     var multi = calendarValue.toMulti();
//     //     (multi).dates.remove(date);
//     //     if (multi.dates.isEmpty) {
//     //       widget.onChanged?.call(null);
//     //       return;
//     //     }
//     //     widget.onChanged?.call(multi);
//     //     return;
//     //   }
//     // }
//     // if (widget.selectionMode == CalendarSelectionMode.range) {
//     //   if (calendarValue == null) {
//     //     widget.onChanged?.call(CalendarValue.single(date));
//     //     return;
//     //   }
//     //   if (calendarValue is MultiCalendarValue) {
//     //     calendarValue = calendarValue.toRange();
//     //   }
//     //   if (calendarValue is SingleCalendarValue) {
//     //     DateTime selectedDate = calendarValue.date;
//     //     if (date.isAtSameMomentAs(selectedDate)) {
//     //       widget.onChanged?.call(null);
//     //       return;
//     //     }
//     //     widget.onChanged?.call(CalendarValue.range(selectedDate, date));
//     //     return;
//     //   }
//     //   if (calendarValue is RangeCalendarValue) {
//     //     DateTime start = calendarValue.start;
//     //     DateTime end = calendarValue.end;
//     //     if (date.isBefore(start)) {
//     //       widget.onChanged?.call(CalendarValue.range(date, end));
//     //       return;
//     //     }
//     //     if (date.isAfter(end)) {
//     //       widget.onChanged?.call(CalendarValue.range(start, date));
//     //       return;
//     //     }
//     //     if (date.isAtSameMomentAs(start)) {
//     //       widget.onChanged?.call(null);
//     //       return;
//     //     }
//     //     if (date.isAtSameMomentAs(end)) {
//     //       widget.onChanged?.call(CalendarValue.single(end));
//     //       return;
//     //     }
//     //     widget.onChanged?.call(CalendarValue.range(start, date));
//     //   }
//     // }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ShadcnLocalizations localizations =
//     //     Localizations.of(context, ShadcnLocalizations);
//     return CalendarGrid(
//       data: _gridData,
//       itemBuilder: (item) {
//         DateTime date = item.date;
//         CalendarValueLookup lookup =
//             widget.value?.lookup(date.year, date.month, date.day) ??
//                 CalendarValueLookup.none;
//         CalendarItemType type = CalendarItemType.none;
//         switch (lookup) {
//           case CalendarValueLookup.none:
//             if (widget.now != null && widget.now!.isAtSameMomentAs(date)) {
//               type = CalendarItemType.today;
//             }
//             break;
//           case CalendarValueLookup.selected:
//             type = CalendarItemType.selected;
//             break;
//           case CalendarValueLookup.start:
//             type = CalendarItemType.startRangeSelected;
//             break;
//           case CalendarValueLookup.end:
//             type = CalendarItemType.endRangeSelected;
//             break;
//           case CalendarValueLookup.inRange:
//             type = CalendarItemType.inRange;
//             break;
//         }
//         Widget calendarItem = CalendarItem(
//           type: type,
//           indexAtRow: item.indexInRow,
//           rowCount: 7,
//           onTap: () {
//             _handleTap(date);
//           },
//           state: widget.stateBuilder?.call(date) ?? DateState.enabled,
//           child: Text('${date.day}').sans(),
//         );
//         if (item.fromAnotherMonth) {
//           return Opacity(
//             opacity: 0.5,
//             child: calendarItem,
//           );
//         }
//         return calendarItem;
//       },
//     );
//   }
// }