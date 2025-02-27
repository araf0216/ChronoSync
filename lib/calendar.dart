import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'clockdb.dart';

enum CalendarValueLookup {
  none,
  selected,
  completed,
  selectComplete,
  start,
  end,
  inRange
}

enum DateState { disabled, enabled, completed }

typedef DateStateBuilder = DateState Function(DateTime date);

abstract class CalendarValue {
  CalendarValueLookup lookup(int year, [int? month = 1, int? day = 1]);
  const CalendarValue();
  static SingleCalendarValue single(DateTime date) {
    return SingleCalendarValue(date);
  }

  static RangeCalendarValue range(DateTime start, DateTime end) {
    return RangeCalendarValue(start, end);
  }

  static MultiCalendarValue multi(List<DateTime> dates) {
    return MultiCalendarValue(dates);
  }

  SingleCalendarValue toSingle();
  RangeCalendarValue toRange();
  MultiCalendarValue toMulti();

  CalendarView get view;
}

DateTime _convertNecessarry(DateTime from, int year, [int? month, int? date]) {
  if (month == null) {
    return DateTime(from.year);
  }
  if (date == null) {
    return DateTime(from.year, from.month);
  }
  return DateTime(from.year, from.month, from.day);
}

class SingleCalendarValue extends CalendarValue {
  final DateTime date;

  SingleCalendarValue(this.date);

  @override
  CalendarValueLookup lookup(int year, [int? month, int? day]) {
    String selectComplete = "";
    DateTime current = _convertNecessarry(date, year, month, day);
    if (current.isAtSameMomentAs(DateTime(year, month ?? 1, day ?? 1))) {
      selectComplete = "select";
    }
    dateComplete(current).then((res) {
      selectComplete = "${selectComplete}complete";
    });
    switch (selectComplete) {
      case "select":
        return CalendarValueLookup.selected;
      case "complete":
        return CalendarValueLookup.completed;
      case "selectcomplete":
        return CalendarValueLookup.selectComplete;
      default:
        print("None matched yet, so exiting with none.");
        return CalendarValueLookup.none;
    }
  }

  Future<bool> dateComplete(DateTime cur) async {
    List<ClockDate> clocks = await dbOps("R");
    bool clockComplete = false;
    void checkMatch(ClockDate clock) {
      if (clock.date == cur) {
        clockComplete = true;
      }
    }

    clocks.forEach(checkMatch);
    return clockComplete;
  }

  @override
  CalendarView get view => date.toCalendarView();

  @override
  String toString() {
    return 'SingleCalendarValue($date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SingleCalendarValue && other.date == date;
  }

  @override
  int get hashCode => date.hashCode;

  @override
  SingleCalendarValue toSingle() {
    return this;
  }

  @override
  RangeCalendarValue toRange() {
    return CalendarValue.range(date, date);
  }

  @override
  MultiCalendarValue toMulti() {
    return CalendarValue.multi([date]);
  }
}

// @override
// CalendarValueLookup lookup(DateTime date, int year, [int? month, int? day]) {
//   DateTime current = _convertNecessarry(date, year, month, day);
//   if (current.isAtSameMomentAs(DateTime(year, month ?? 1, day ?? 1))) {
//     return CalendarValueLookup.selected;
//   }
//   return CalendarValueLookup.none;
// }

enum CalendarItemType {
  none,
  today,
  selected,
  selectComplete,
  completed,
  // when its the date in the range
  inRange,
  startRange, // same as startRangeSelected, but used for other months
  endRange, // same as endRangeSelected, but used for other months
  startRangeSelected,
  endRangeSelected,
  startRangeSelectedShort,
  endRangeSelectedShort, // usually when the range are just 2 days
  inRangeSelectedShort,
}

class CalendarItem extends StatelessWidget {
  final Widget child;
  final CalendarItemType type;
  final VoidCallback? onTap;
  final int indexAtRow;
  final int rowCount;
  final double? width;
  final double? height;
  final DateState state;

  const CalendarItem({
    super.key,
    required this.child,
    required this.type,
    required this.indexAtRow,
    required this.rowCount,
    this.onTap,
    this.width,
    this.height,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var type = this.type;
    if ((indexAtRow == 0 || indexAtRow == rowCount - 1) &&
        (type == CalendarItemType.startRangeSelected ||
            type == CalendarItemType.endRangeSelected ||
            type == CalendarItemType.startRangeSelectedShort ||
            type == CalendarItemType.endRangeSelectedShort)) {
      type = CalendarItemType.selected;
    }
    switch (type) {
      case CalendarItemType.none:
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SizedBox(
              width: width ?? theme.scaling * 32,
              height: height ?? theme.scaling * 32,
              child: GhostButton(
                density: ButtonDensity.compact,
                alignment: Alignment.center,
                enabled: state == DateState.enabled,
                onPressed: onTap,
                child: child,
              ),
            ),
          ],
        );
      case CalendarItemType.today:
        return SizedBox(
          width: width ?? theme.scaling * 32,
          height: height ?? theme.scaling * 32,
          child: SecondaryButton(
            density: ButtonDensity.compact,
            alignment: Alignment.center,
            enabled: state == DateState.enabled,
            onPressed: onTap,
            child: child,
          ),
        );
      case CalendarItemType.selected:
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SizedBox(
              width: width ?? theme.scaling * 32,
              height: height ?? theme.scaling * 32,
              child: PrimaryButton(
                density: ButtonDensity.compact,
                alignment: Alignment.center,
                enabled: state == DateState.enabled,
                onPressed: onTap,
                child: child,
              ),
            ),
          ],
        );
      case CalendarItemType.completed:
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SizedBox(
              width: width ?? theme.scaling * 32,
              height: height ?? theme.scaling * 32,
              child: SecondaryButton(
                density: ButtonDensity.compact,
                alignment: Alignment.center,
                enabled: state == DateState.enabled,
                onPressed: onTap,
                child: child,
              ),
            ),
            Icon(
              Icons.check,
              size: 12,
              color: Colors.blue,
            ),
          ],
        );
      case CalendarItemType.selectComplete:
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SizedBox(
              width: width ?? theme.scaling * 32,
              height: height ?? theme.scaling * 32,
              child: PrimaryButton(
                density: ButtonDensity.compact,
                alignment: Alignment.center,
                enabled: state == DateState.enabled,
                onPressed: onTap,
                child: child,
              ),
            ),
            Icon(
              Icons.check,
              size: 12,
              color: Colors.black,
            ),
          ],
        );
      case CalendarItemType.inRange:
        return SizedBox(
          width: width ?? theme.scaling * 32,
          height: height ?? theme.scaling * 32,
          child: Button(
            alignment: Alignment.center,
            onPressed: onTap,
            enabled: state == DateState.enabled,
            style: const ButtonStyle(
              variance: ButtonVariance.secondary,
              density: ButtonDensity.compact,
            ).copyWith(
              decoration: (context, states, value) {
                return (value as BoxDecoration).copyWith(
                  borderRadius: indexAtRow == 0
                      ? BorderRadius.only(
                          topLeft: Radius.circular(theme.radiusMd),
                          bottomLeft: Radius.circular(theme.radiusMd),
                        )
                      : indexAtRow == rowCount - 1
                          ? BorderRadius.only(
                              topRight: Radius.circular(theme.radiusMd),
                              bottomRight: Radius.circular(theme.radiusMd),
                            )
                          : BorderRadius.zero,
                );
              },
            ),
            child: child,
          ),
        );
      case CalendarItemType.startRange:
        return SizedBox(
          width: width ?? theme.scaling * 32,
          height: height ?? theme.scaling * 32,
          child: Button(
            alignment: Alignment.center,
            onPressed: onTap,
            enabled: state == DateState.enabled,
            style: const ButtonStyle(
              variance: ButtonVariance.secondary,
              density: ButtonDensity.compact,
            ).copyWith(
              decoration: (context, states, value) {
                return (value as BoxDecoration).copyWith(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(theme.radiusMd),
                    bottomLeft: Radius.circular(theme.radiusMd),
                  ),
                );
              },
            ),
            child: child,
          ),
        );
      case CalendarItemType.endRange:
        return SizedBox(
          width: width ?? theme.scaling * 32,
          height: height ?? theme.scaling * 32,
          child: Button(
            alignment: Alignment.center,
            onPressed: onTap,
            enabled: state == DateState.enabled,
            style: const ButtonStyle(
              variance: ButtonVariance.secondary,
              density: ButtonDensity.compact,
            ).copyWith(
              decoration: (context, states, value) {
                return (value as BoxDecoration).copyWith(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(theme.radiusMd),
                    bottomRight: Radius.circular(theme.radiusMd),
                  ),
                );
              },
            ),
            child: child,
          ),
        );
      case CalendarItemType.startRangeSelected:
        return SizedBox(
          width: width ?? theme.scaling * 32,
          height: height ?? theme.scaling * 32,
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Container(
                width: width ?? theme.scaling * 32,
                height: height ?? theme.scaling * 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(theme.radiusMd),
                    bottomLeft: Radius.circular(theme.radiusMd),
                  ),
                ),
              ),
              PrimaryButton(
                density: ButtonDensity.compact,
                alignment: Alignment.center,
                enabled: state == DateState.enabled,
                onPressed: onTap,
                child: child,
              ),
            ],
          ),
        );
      case CalendarItemType.endRangeSelected:
        return SizedBox(
          width: width ?? theme.scaling * 32,
          height: height ?? theme.scaling * 32,
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Container(
                width: width ?? theme.scaling * 32,
                height: height ?? theme.scaling * 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(theme.radiusMd),
                    bottomRight: Radius.circular(theme.radiusMd),
                  ),
                ),
              ),
              PrimaryButton(
                density: ButtonDensity.compact,
                alignment: Alignment.center,
                enabled: state == DateState.enabled,
                onPressed: onTap,
                child: child,
              ),
            ],
          ),
        );
      case CalendarItemType.startRangeSelectedShort:
        return SizedBox(
          width: width ?? theme.scaling * 32,
          height: height ?? theme.scaling * 32,
          child: Button(
            alignment: Alignment.center,
            onPressed: onTap,
            enabled: state == DateState.enabled,
            style: const ButtonStyle(
              variance: ButtonVariance.primary,
              density: ButtonDensity.compact,
            ).copyWith(
              decoration: (context, states, value) {
                return (value as BoxDecoration).copyWith(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(theme.radiusMd),
                    bottomLeft: Radius.circular(theme.radiusMd),
                  ),
                );
              },
            ),
            child: child,
          ),
        );
      case CalendarItemType.endRangeSelectedShort:
        return SizedBox(
          width: width ?? theme.scaling * 32,
          height: height ?? theme.scaling * 32,
          child: Button(
            alignment: Alignment.center,
            onPressed: onTap,
            enabled: state == DateState.enabled,
            style: const ButtonStyle(
              variance: ButtonVariance.primary,
              density: ButtonDensity.compact,
            ).copyWith(
              decoration: (context, states, value) {
                return (value as BoxDecoration).copyWith(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(theme.radiusMd),
                    bottomRight: Radius.circular(theme.radiusMd),
                  ),
                );
              },
            ),
            child: child,
          ),
        );
      case CalendarItemType.inRangeSelectedShort:
        return SizedBox(
          width: width ?? theme.scaling * 32,
          height: height ?? theme.scaling * 32,
          child: Button(
            alignment: Alignment.center,
            enabled: state == DateState.enabled,
            onPressed: onTap,
            style: const ButtonStyle(
              variance: ButtonVariance.primary,
              density: ButtonDensity.compact,
            ).copyWith(
              decoration: (context, states, value) {
                return (value as BoxDecoration).copyWith(
                  borderRadius: BorderRadius.zero,
                );
              },
            ),
            child: child,
          ),
        );
    }
  }
}

class Calendar extends StatelessWidget {
  final DateTime? now;
  final CalendarValue? value;
  final CalendarView view;
  final CalendarSelectionMode selectionMode;
  final ValueChanged<CalendarValue?>? onChanged;
  final bool Function(DateTime date)? isDateEnabled;
  final DateStateBuilder? stateBuilder;

  const Calendar({
    super.key,
    this.now,
    this.value,
    required this.view,
    required this.selectionMode,
    this.onChanged,
    this.isDateEnabled,
    this.stateBuilder,
  });

  void _handleTap(DateTime date) {
    var calendarValue = value;
    if (selectionMode == CalendarSelectionMode.none) {
      return;
    }
    if (selectionMode == CalendarSelectionMode.single) {
      if (calendarValue is SingleCalendarValue &&
          date.isAtSameMomentAs(calendarValue.date)) {
        onChanged?.call(null);
        return;
      }
      onChanged?.call(CalendarValue.single(date));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // since the calendar grid starts from sunday
    // theres a lot of stuff that needs to be tweaked
    // since dart DateTime starts from monday
    final calendarValue = value;
    int weekDayStart = (DateTime(view.year, view.month).weekday + 1);
    int daysInMonth = DateTime(view.year, view.month + 1, 0).day;
    ShadcnLocalizations localizations =
        Localizations.of(context, ShadcnLocalizations);
    List<Widget> rows = [];
    // Weekdays Row
    List<Widget> weekDays = [];
    for (int i = 0; i < 7; i++) {
      int weekday = ((i - 1) % 7) + 1;
      weekDays.add(
        Container(
          width: theme.scaling * 32,
          height: theme.scaling * 32,
          alignment: Alignment.center,
          child: Text(localizations.getAbbreviatedWeekday(weekday))
              .muted()
              .xSmall(),
        ),
      );
    }
    rows.add(Row(
      mainAxisSize: MainAxisSize.min,
      children: weekDays,
    ));
    // Days
    List<Widget> days = [];
    // reduce the amount of unnecessary rows
    while (weekDayStart > 7) {
      weekDayStart -= 7;
    }
    // start from the first day of the week
    for (int i = 1; i < weekDayStart; i++) {
      int previousMonthDay = daysInMonth - (weekDayStart - i);
      var dateTime = DateTime(view.year, view.month - 1, previousMonthDay);
      int indexAtRow = i - 1;
      CalendarItemType type = CalendarItemType.none;
      if (calendarValue != null) {
        final lookup =
            calendarValue.lookup(dateTime.year, dateTime.month, dateTime.day);
        switch (lookup) {
          case CalendarValueLookup.none:
            if (now != null && now!.isAtSameMomentAs(dateTime)) {
              type = CalendarItemType.today;
            }
            break;
          case CalendarValueLookup.selected:
            type = CalendarItemType.selected;
            break;
          case CalendarValueLookup.completed:
            type = CalendarItemType.completed;
            break;
          case CalendarValueLookup.selectComplete:
            type = CalendarItemType.selectComplete;
            break;
          case CalendarValueLookup.start:
            type = CalendarItemType.startRange;
            break;
          case CalendarValueLookup.end:
            type = CalendarItemType.endRange;
            break;
          case CalendarValueLookup.inRange:
            type = CalendarItemType.inRange;
            break;
        }
      } else {
        if (now != null && now!.isAtSameMomentAs(dateTime)) {
          type = CalendarItemType.today;
        }
      }
      days.add(Opacity(
        opacity: 0.5,
        child: CalendarItem(
          key: ValueKey(dateTime),
          type: type,
          indexAtRow: indexAtRow,
          rowCount: 7,
          onTap: () {
            _handleTap(dateTime);
          },
          state: stateBuilder?.call(dateTime) ?? DateState.enabled,
          child: Text('$previousMonthDay'),
        ),
      ));
    }
    // then the days of the month
    for (int i = 1; i <= daysInMonth; i++) {
      DateTime date = DateTime(view.year, view.month, i);
      CalendarItemType type = CalendarItemType.none;
      int indexAtRow = (weekDayStart + i - 2) % 7;
      if (calendarValue != null) {
        final lookup = calendarValue.lookup(date.year, date.month, date.day);
        switch (lookup) {
          case CalendarValueLookup.none:
            if (now != null && now!.isAtSameMomentAs(date)) {
              type = CalendarItemType.today;
            }
            break;
          case CalendarValueLookup.selected:
            type = CalendarItemType.selected;
            break;
          case CalendarValueLookup.completed:
            type = CalendarItemType.completed;
            break;
          case CalendarValueLookup.selectComplete:
            type = CalendarItemType.selectComplete;
            break;
          case CalendarValueLookup.start:
            type = CalendarItemType.startRangeSelected;
            break;
          case CalendarValueLookup.end:
            type = CalendarItemType.endRangeSelected;
            break;
          case CalendarValueLookup.inRange:
            type = CalendarItemType.inRange;
            break;
        }
      } else {
        if (now != null && now!.isAtSameMomentAs(date)) {
          type = CalendarItemType.today;
        }
      }
      var state = stateBuilder?.call(date) ?? DateState.enabled;
      days.add(CalendarItem(
        key: ValueKey(date),
        type: type,
        indexAtRow: indexAtRow,
        rowCount: 7,
        onTap: () {
          _handleTap(date);
        },
        state: state,
        // child: Column(
        //   children: [
        //     Text('$i'),
        //     Icon(Icons.check, size: 12, color: Colors.blue,)
        //   ],
        // ),
        child: Text('$i'),
      ));
    }
    // actual needed rows
    int neededRows = (days.length / 7).ceil();
    // then fill the rest of the row with the next month
    int totalDaysGrid = 7 * neededRows; // 42
    var length = days.length;
    for (int i = length; i < totalDaysGrid; i++) {
      int nextMonthDay = i - length + 1;
      var dateTime = DateTime(view.year, view.month + 1, nextMonthDay);
      int indexAtRow = i % 7;
      CalendarItemType type = CalendarItemType.none;
      if (calendarValue != null) {
        final lookup =
            calendarValue.lookup(dateTime.year, dateTime.month, dateTime.day);
        switch (lookup) {
          case CalendarValueLookup.none:
            if (now != null && now!.isAtSameMomentAs(dateTime)) {
              type = CalendarItemType.today;
            }
            break;
          case CalendarValueLookup.selected:
            type = CalendarItemType.selected;
            break;
          case CalendarValueLookup.completed:
            type = CalendarItemType.completed;
            break;
          case CalendarValueLookup.selectComplete:
            type = CalendarItemType.selectComplete;
            break;
          case CalendarValueLookup.start:
            type = CalendarItemType.startRange;
            break;
          case CalendarValueLookup.end:
            type = CalendarItemType.endRange;
            break;
          case CalendarValueLookup.inRange:
            type = CalendarItemType.inRange;
            break;
        }
      } else {
        if (now != null && now!.isAtSameMomentAs(dateTime)) {
          type = CalendarItemType.today;
        }
      }
      days.add(Opacity(
        opacity: 0.5,
        child: CalendarItem(
          type: type,
          indexAtRow: indexAtRow,
          rowCount: 7,
          onTap: () {
            _handleTap(dateTime);
          },
          state: stateBuilder?.call(dateTime) ?? DateState.enabled,
          child: Text('$nextMonthDay'),
        ),
      ));
    }
    // split the days into rows
    for (int i = 0; i < days.length; i += 7) {
      // there won't be any array out of bounds error
      // because we made sure that the total days is 42
      rows.add(Gap(theme.scaling * 8));
      rows.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: days.sublist(i, i + 7),
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );
  }
}
