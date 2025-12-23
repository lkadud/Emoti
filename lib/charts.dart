
import 'package:fl_chart/fl_chart.dart';
import 'package:emoti/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


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
                  RadarEntry(value: appState.getCountOfEmotion(baseEmotion)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
