import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartSimple extends StatelessWidget {
  final List<double> y;
  final String title;
  const LineChartSimple({super.key, required this.y, required this.title});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (var i = 0; i < y.length; i++) {
      spots.add(FlSpot(i.toDouble(), y[i]));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: LineChart(LineChartData(
            lineBarsData: [LineChartBarData(spots: spots, isCurved: true)],
            titlesData: const FlTitlesData(show: false),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: true),
          )),
        ),
      ],
    );
  }
}
