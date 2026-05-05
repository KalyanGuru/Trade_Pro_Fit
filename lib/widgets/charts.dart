import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// =====================================================
// CANDLE (LINE) CHART FOR LIVE DATA — DARK THEME
// =====================================================

const _kCyan = Color(0xFF00D2FF);

class CandleChart extends StatelessWidget {
  final List<double> prices;

  const CandleChart({super.key, required this.prices});

  @override
  Widget build(BuildContext context) {
    if (prices.isEmpty) {
      return SizedBox(
        height: 250,
        child: Center(
          child: Text(
            'Waiting for data…',
            style: GoogleFonts.inter(
              color: Colors.white24,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < prices.length; i++) {
      spots.add(FlSpot(i.toDouble(), prices[i]));
    }

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: _kCyan,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _kCyan.withValues(alpha: 0.18),
                    _kCyan.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(1),
                    style: GoogleFonts.inter(
                      color: Colors.white24,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _interval(prices),
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.white.withValues(alpha: 0.04),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF1E1E3A),
              tooltipRoundedRadius: 8,
              getTooltipItems: (spots) {
                return spots.map((s) {
                  return LineTooltipItem(
                    '₹${s.y.toStringAsFixed(2)}',
                    GoogleFonts.inter(
                      color: _kCyan,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
    );
  }

  double _interval(List<double> data) {
    if (data.isEmpty) return 1;
    final maxV = data.reduce((a, b) => a > b ? a : b);
    final minV = data.reduce((a, b) => a < b ? a : b);
    final range = maxV - minV;
    if (range <= 0) return 1;
    return range / 4;
  }
}

// =====================================================
// SIMPLE LINE CHART — DARK THEME
// =====================================================

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
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: LineChart(LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: _kCyan,
                barWidth: 2,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _kCyan.withValues(alpha: 0.15),
                      _kCyan.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ],
            titlesData: const FlTitlesData(show: false),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
          )),
        ),
      ],
    );
  }
}

// =====================================================
// PREDICTION VS ACTUAL CHART — DUAL LINE
// =====================================================

class PredictionVsActualChart extends StatelessWidget {
  final List<double> actualPrices;
  final List<double> predictedPrices;

  const PredictionVsActualChart({
    super.key,
    required this.actualPrices,
    required this.predictedPrices,
  });

  @override
  Widget build(BuildContext context) {
    if (actualPrices.isEmpty && predictedPrices.isEmpty) {
      return _emptyChart('Waiting for prediction data…');
    }

    final actualSpots = actualPrices.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    final predSpots = predictedPrices.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    final allPrices = [...actualPrices, ...predictedPrices];
    final interval = _calcInterval(allPrices);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _legendItem('Actual', _kCyan),
            const SizedBox(width: 16),
            _legendItem('Predicted', const Color(0xFF6C5CE7)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: interval,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white.withValues(alpha: 0.04),
                  strokeWidth: 1,
                ),
              ),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              clipData: const FlClipData.all(),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => const Color(0xFF1E1E3A),
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (spots) {
                    return spots.map((s) {
                      final isActual = s.barIndex == 0;
                      return LineTooltipItem(
                        '₹${s.y.toStringAsFixed(2)}',
                        GoogleFonts.inter(
                          color: isActual ? _kCyan : const Color(0xFF6C5CE7),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: actualSpots,
                  isCurved: true,
                  curveSmoothness: 0.2,
                  color: _kCyan,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _kCyan.withValues(alpha: 0.15),
                        _kCyan.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                LineChartBarData(
                  spots: predSpots,
                  isCurved: true,
                  curveSmoothness: 0.2,
                  color: const Color(0xFF6C5CE7),
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dashArray: [5, 5],
                  dotData: const FlDotData(show: false),
                ),
              ],
            ),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          ),
        ),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// =====================================================
// MAE CHART — ROLLING ERROR
// =====================================================

class MAEChart extends StatelessWidget {
  final List<double> history;

  const MAEChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return _emptyChart('No MAE data yet');

    final spots = history.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    const color = Color(0xFFFFD740);

    return _metricChart(spots, color, _calcInterval(history));
  }
}

// =====================================================
// RMSE CHART — ROLLING ERROR
// =====================================================

class RMSEChart extends StatelessWidget {
  final List<double> history;

  const RMSEChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return _emptyChart('No RMSE data yet');

    final spots = history.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    const color = Color(0xFFFF5252);

    return _metricChart(spots, color, _calcInterval(history));
  }
}

// =====================================================
// SHARED HELPERS
// =====================================================

Widget _metricChart(List<FlSpot> spots, Color color, double interval) {
  return SizedBox(
    height: 150,
    child: LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withValues(alpha: 0.04),
            strokeWidth: 1,
          ),
        ),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        clipData: const FlClipData.all(),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF1E1E3A),
            tooltipRoundedRadius: 8,
            getTooltipItems: (spots) {
              return spots.map((s) {
                return LineTooltipItem(
                  s.y.toStringAsFixed(4),
                  GoogleFonts.inter(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.1,
            color: color,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    ),
  );
}

Widget _emptyChart(String text) {
  return SizedBox(
    height: 150,
    child: Center(
      child: Text(
        text,
        style: GoogleFonts.inter(color: Colors.white24, fontSize: 13),
      ),
    ),
  );
}

double _calcInterval(List<double> data) {
  if (data.isEmpty) return 1;
  final maxV = data.reduce((a, b) => a > b ? a : b);
  final minV = data.reduce((a, b) => a < b ? a : b);
  final range = maxV - minV;
  if (range <= 0) return 1;
  return range / 4;
}
