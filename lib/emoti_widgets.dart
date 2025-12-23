import 'package:flutter/material.dart';
import 'package:emoti/main.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';



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
                    appState.deleteEmotion(emotion);
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
      onTap: appState.setSelectedIndex,
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
                appState.addEmotion(
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
