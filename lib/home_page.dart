import 'package:emoti/main.dart';
import 'package:emoti/emoti_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  var emotionsToday = <EmotionType>[];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    List<EmotionType> _getEventsForDay(DateTime day) {
      var emotionsOnDay = <EmotionType>[];
      for (var emotion in appState.emotions) {
        if (isSameDay(emotion.date, day)) {
          emotionsOnDay.add(emotion);
        }
      }
      return emotionsOnDay;
    }

    return ListView(
      children: [
        TableCalendar(
          firstDay: DateTime(2000, 1, 1),
          lastDay: DateTime(2040, 1, 1),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          currentDay: DateTime.now(),
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                emotionsToday = _getEventsForDay(_selectedDay);
              });
            }
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          eventLoader: (day) {
            return _getEventsForDay(day);
          },
        ),

        for (var emotion in _getEventsForDay(_selectedDay))
          EmotiCard(emotion: emotion),
      ],
    );
  }
}
