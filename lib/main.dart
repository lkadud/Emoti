import 'dart:collection';

import 'package:emoti/home_page.dart';
import 'package:emoti/stats_page.dart';
import 'package:emoti/emoti_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:table_calendar/table_calendar.dart';
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
  void setSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  var emotions = <EmotionType>[];

  /*void _addEmotion() {
    emotions.add(Emotion("Happy", DateTime.now(), Uuid().v4()));
    notifyListeners();
  }*/

  void addEmotion(EmotionType emotion) {
    emotions.add(emotion);
    notifyListeners();
  }

  void deleteEmotion(Emotion) {
    emotions.remove(Emotion);
    notifyListeners();
  }

  double getCountOfEmotion(String emotion) {
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


