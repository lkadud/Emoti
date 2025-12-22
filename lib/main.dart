import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widget_previews.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class EmotionType {
  final String emotion;
  final DateTime date;
  final String id;
  final Color color;

  EmotionType(this.emotion, this.date, this.id, this.color);
}

class MyAppState extends ChangeNotifier {
  final Set<String> baseEmotions = <String>{
    'Ecstasy',
    'Admiration',
    'Terror',
    'Amazement',
    'Grief',
    'Loathing',
    'Rage',
    'Vigilance',
  };

  final Map<String, Color> emotionColors = {
    'Ecstasy': Colors.yellowAccent,
    'Admiration': Colors.pinkAccent,
    'Terror': Colors.purpleAccent,
    'Amazement': Colors.greenAccent,
    'Grief': Colors.black,
    'Loathing': Colors.cyan,
    'Rage': Colors.redAccent,
    'Vigilance': Colors.blueAccent,
  };

  final Map<String, Set<String>> fineEmotion = {
    'Ecstasy': {},
    'Admiration': {},
    'Terror': {},
    'Amazement': {},
    'Grief': {},
    'Loathing': {},
    'Rage': {},
    'Vigilance': {},
  };
  var selectedIndex = 0;
  void _setSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  var emotions = <EmotionType>[];

  /*void _addEmotion() {
    emotions.add(Emotion("Happy", DateTime.now(), Uuid().v4()));
    notifyListeners();
  }*/

  void _addEmotion(EmotionType emotion) {
    emotions.add(emotion);
    notifyListeners();
  }

  void _deleteEmotion(Emotion) {
    emotions.remove(Emotion);
    notifyListeners();
  }

  double _getCountOfEmotion(String emotion) {
    double count = 0;
    for (var e in emotions) {
      if (e.emotion == emotion) count++;
    }
    return count;
  }
}

class _MyHomePageState extends State<MyHomePage> {
  void _showDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return EmotiDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    return Scaffold(
      body: Center(
        child: <Widget>[HomePage(), StatsPage()][appState.selectedIndex],
      ),
      bottomNavigationBar: EmotiBottomNavBar(theme: theme),
      floatingActionButton: FloatingActionButton(
        tooltip: "Create",
        onPressed: _showDialog,
        shape: CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> with TickerProviderStateMixin {
  late PageController _pageViewController;
  late TabController _tabController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          PageView(
            controller: _pageViewController,
            onPageChanged: _handlePageViewChanged,
            children: <Widget>[EmotiRadarChart(), EmotiPieChart()],
          ),
          PageIndicator(
            tabController: _tabController,
            currentPageIndex: _currentPageIndex,
            onUpdateCurrentPageIndex: _updateCurrentPageIndex,
            isOnDesktopAndWeb: _isOnDesktopAndWeb,
          ),
        ],
      ),
    );
  }

  void _handlePageViewChanged(int currentPageIndex) {
    if (!_isOnDesktopAndWeb) {
      return;
    }
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  bool get _isOnDesktopAndWeb =>
      kIsWeb ||
      switch (defaultTargetPlatform) {
        TargetPlatform.macOS ||
        TargetPlatform.linux ||
        TargetPlatform.windows => true,
        TargetPlatform.android ||
        TargetPlatform.iOS ||
        TargetPlatform.fuchsia => false,
      };
}

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.tabController,
    required this.currentPageIndex,
    required this.onUpdateCurrentPageIndex,
    required this.isOnDesktopAndWeb,
  });

  final int currentPageIndex;
  final TabController tabController;
  final void Function(int) onUpdateCurrentPageIndex;
  final bool isOnDesktopAndWeb;

  @override
  Widget build(BuildContext context) {
    if (!isOnDesktopAndWeb) {
      return const SizedBox.shrink();
    }
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            splashRadius: 16.0,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (currentPageIndex == 0) {
                return;
              }
              onUpdateCurrentPageIndex(currentPageIndex - 1);
            },
            icon: const Icon(Icons.arrow_left_rounded, size: 32.0),
          ),
          TabPageSelector(
            controller: tabController,
            color: colorScheme.surface,
            selectedColor: colorScheme.primary,
          ),
          IconButton(
            splashRadius: 16.0,
            padding: EdgeInsets.zero,
            onPressed: () {
              if (currentPageIndex == 2) {
                return;
              }
              onUpdateCurrentPageIndex(currentPageIndex + 1);
            },
            icon: const Icon(Icons.arrow_right_rounded, size: 32.0),
          ),
        ],
      ),
    );
  }
}

class EmotiPieChart extends StatefulWidget {
  const EmotiPieChart({super.key});

  @override
  State<EmotiPieChart> createState() => _EmotiPieChartState();
}

class _EmotiPieChartState extends State<EmotiPieChart> {
  DateTime _today = DateTime.now();

  List<PieChartSectionData> _getSectionData(List<EmotionType> emotions) {
    List<EmotionType> selectedEmotions = [];
    for (var emotion in emotions) {
      if (emotion.date.month == _today.month) {
        selectedEmotions.add(emotion);
      }
    }

    List<PieChartSectionData> sectionData = [];
    for (
      int day = 0;
      day < DateTime(_today.year, _today.month + 1, 0).day;
      day++
    ) {
      double count = 0;
      var color = Colors.transparent;
      for (var emotion in selectedEmotions) {
        if (emotion.date.day == day) {
          count++;
          // main emotion
          color = emotion.color;
        }
      }
      sectionData.add(
        PieChartSectionData(
          color: color,
          value: 1,
          title: "${day + 1}",
          radius: 60 * count,
        ),
      );
    }

    return sectionData;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: InputDatePickerFormField(
            firstDate: DateTime(2010),
            lastDate: DateTime(2030),
            initialDate: _today,

            onDateSubmitted: (date) {
              setState(() {
                _today = date;
              });
            },
          ),
        ),
        AspectRatio(
          aspectRatio: 1,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 100,
              sections: _getSectionData(appState.emotions),
              startDegreeOffset: -90,
            ),
          ),
        ),
      ],
    );
  }
}

class EmotiRadarChart extends StatelessWidget {
  const EmotiRadarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    return AspectRatio(
      aspectRatio: 1,
      child: RadarChart(
        RadarChartData(
          radarBorderData: const BorderSide(color: Colors.transparent),
          getTitle: (index, angle) {
            RadarChartTitle makeTick(index) {
              return RadarChartTitle(
                text: appState.baseEmotions.toList()[index],
                angle: angle,
              );
            }

            return makeTick(index);
            //return switch (index) {
            //  0 => RadarChartTitle(text: 'Ecstasy', angle: angle),
            //  1 => RadarChartTitle(text: 'Admiration', angle: angle),
            //  2 => RadarChartTitle(text: 'Terror', angle: angle),
            //  3 => RadarChartTitle(text: 'Amazement', angle: angle),
            //  4 => RadarChartTitle(text: 'Grief', angle: angle),
            //  5 => RadarChartTitle(text: 'Loathing', angle: angle),
            //  6 => RadarChartTitle(text: 'Rage', angle: angle),
            //  7 => RadarChartTitle(text: 'Vigilance', angle: angle),
            //  _ => const RadarChartTitle(text: '', angle: 0),
            //};
          },
          tickCount: 5,
          titlePositionPercentageOffset: 0.1,
          dataSets: <RadarDataSet>[
            RadarDataSet(
              fillColor: theme.colorScheme.primary.withAlpha(128),
              borderColor: theme.colorScheme.primary,
              entryRadius: 5,
              borderWidth: 5,
              dataEntries: <RadarEntry>[
                for (var baseEmotion in appState.baseEmotions)
                  RadarEntry(value: appState._getCountOfEmotion(baseEmotion)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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



class EmotiCard extends StatelessWidget {
  const EmotiCard({super.key, required this.emotion});

  final EmotionType emotion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    var appState = context.watch<MyAppState>();
    return Center(
      child: Card(
        //elevation: 1.0,
        //color: theme.colorScheme.primary,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.emoji_emotions_outlined),
              title: Text(DateFormat('kk:mm').format(emotion.date)),
              subtitle: Text(emotion.emotion),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton.icon(
                  onPressed: () {
                    appState._deleteEmotion(emotion);
                  },
                  icon: Icon(Icons.delete, color: theme.colorScheme.error),
                  label: Text("Delete"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EmotiBottomNavBar extends StatefulWidget {
  const EmotiBottomNavBar({super.key, required this.theme});

  final ThemeData theme;

  @override
  State<EmotiBottomNavBar> createState() => _EmotiBottomNavBarState();
}

class _EmotiBottomNavBarState extends State<EmotiBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    final theme = Theme.of(context);
    return BottomNavigationBar(
      currentIndex: appState.selectedIndex,
      selectedItemColor: theme.colorScheme.error,
      onTap: appState._setSelectedIndex,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Stats'),
      ],
    );
  }
}

class EmotiDialog extends StatefulWidget {
  const EmotiDialog({super.key});

  @override
  State<EmotiDialog> createState() => _EmotiDialogState();
}

class _EmotiDialogState extends State<EmotiDialog> {
  String _selection = "Admiration";
  DateTime _date = DateTime.now();
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return SimpleDialog(
      title: Text("How do you feel?"),
      children: [
        SegmentedButton(
          segments: <ButtonSegment<String>>[
            for (var baseEmotion in appState.baseEmotions)
              ButtonSegment<String>(
                value: baseEmotion,
                icon: Icon(Icons.emoji_emotions),
                label: Text(baseEmotion),
              ),
          ],
          selected: <String>{_selection},
          onSelectionChanged: (Set<String> newSelection) {
            setState(() {
              _selection = newSelection.first;
            });
          },
        ),

        Padding(
          padding: const EdgeInsets.all(20.0),
          child: InputDatePickerFormField(
            firstDate: DateTime(2010),
            lastDate: DateTime(2030),
            initialDate: _date,
            onDateSaved: (date) {
              setState(() {
                _date = date;
              });
            },
            onDateSubmitted: (date) {
              setState(() {
                _date = date;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              label: Text("Cancel"),
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                appState._addEmotion(
                  EmotionType(
                    _selection,
                    _date,
                    Uuid().v4(),
                    (appState.emotionColors[_selection] ?? Colors.transparent),
                  ),
                );
                Navigator.of(context, rootNavigator: true).pop();
              },
              label: Text("Submit"),
              icon: Icon(Icons.check, color: Colors.green),
            ),
          ],
        ),
      ],
    );
  }
}
