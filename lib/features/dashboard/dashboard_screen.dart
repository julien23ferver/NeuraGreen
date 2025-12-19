import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart'; // Add this import
import '../../core/app_colors.dart';
import '../../data/models/usage_point.dart'; // Add this import
import '../../presentation/widgets/glass_card.dart';
import 'dashboard_provider.dart';
import '../../core/app_constants.dart'; // Add this import
import '../../core/extensions.dart';

class DashboardScreen extends ConsumerWidget { // Changement ici
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Changement ici
    final dashboardState = ref.watch(dashboardProvider); // On écoute les changements

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showPredictiveSimulationDialog(context, ref);
        },
        backgroundColor: AppColors.biolumCyan,
        child: const Icon(Icons.psychology_alt, color: Colors.black),
      ).animate().fade(delay: 1000.ms).scale(begin: const Offset(0.5, 0.5)),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildAmbientBlob(AppColors.biolumCyan, -80, -40, 300, 7.seconds),
          _buildAmbientBlob(AppColors.plasmaBlue, 200, -120, 450, 9.seconds),
          _buildAmbientBlob(AppColors.toxicLime, null, -100, 350, 11.seconds, bottom: -60),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader().animate().fade().slideX(),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: () {
                          ref.read(dashboardProvider.notifier).fetchAndSaveUsageData();
                        },
                      ).animate().fade(),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _buildMainCard(dashboardState), // On passe les données
                  const SizedBox(height: 20),
                  _buildSecondaryMetrics(dashboardState), // On passe les données
                  const SizedBox(height: 40),
                  _buildModelComparison(dashboardState), // Add this
                  const SizedBox(height: 40),
                  _buildUsageTimeline(dashboardState) // Add this
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientBlob(Color color, double? top, double? right, double size, Duration duration, {double? bottom}) {
    return Positioned(
      top: top, right: right, bottom: bottom,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color.withAlpha((255 * 0.12).round())),
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true))
       .moveY(begin: 0, end: 35, duration: duration, curve: Curves.easeInOutSine)
       .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: duration),
    );
  }

  Widget _buildMainCard(DashboardState state) {
    return GlassCard(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TOTAL FOOTPRINT', style: TextStyle(color: AppColors.textMediumEmphasis, fontSize: 10, letterSpacing: 2)),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(state.totalCO2.toStringAsFixed(2), style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
              const SizedBox(width: 8),
              const Text('kg CO2e', style: TextStyle(color: AppColors.biolumCyan, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text('≈ 0.5 tree absorbed this year', style: TextStyle(color: AppColors.textMediumEmphasis, fontSize: 12)),
        ],
      ),
    ).animate().fade(delay: 200.ms).moveY(begin: 30, end: 0);
  }

  Widget _buildSecondaryMetrics(DashboardState state) {
    return Row(
      children: [
        Expanded(child: GlassCard(child: _metric('WATER', state.totalWater.toStringAsFixed(1), 'L', AppColors.plasmaBlue))),
        const SizedBox(width: 16),
        Expanded(child: GlassCard(child: _metric('COST', r'$${state.totalCost.toStringAsFixed(2)}', 'USD', AppColors.toxicLime))),
      ],
    ).animate().fade(delay: 400.ms).moveY(begin: 30, end: 0);
  }

  Widget _metric(String label, String val, String unit, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 20, height: 2, color: color),
        const SizedBox(height: 16),
        Text(label, style: const TextStyle(color: AppColors.textMediumEmphasis, fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        Text(unit, style: TextStyle(color: color.withAlpha((255 * 0.7).round()), fontSize: 11)),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('SYSTEM OPTIMAL', style: TextStyle(color: AppColors.biolumCyan, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.5, fontFamily: 'SpaceGrotesk')),
        const SizedBox(height: 8),
        const Text('Eco-Impact\nAnalytics', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, height: 1.1, fontFamily: 'SpaceGrotesk')),
      ],
    );
  }

  Widget _buildModelComparison(DashboardState state) {
    if (state.co2PerModel.isEmpty && state.costPerModel.isEmpty) {
      return const SizedBox.shrink(); // Don't show if no data
    }

    // Prepare data for CO2 bar chart
    final co2BarGroups = state.co2PerModel.entries.mapIndexed((index, entry) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: AppColors.biolumCyan,
            width: 16,
            borderRadius: BorderRadius.zero,
          ),
        ],
      );
    }).toList();

    // Prepare data for Cost bar chart
    final costBarGroups = state.costPerModel.entries.mapIndexed((index, entry) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: AppColors.toxicLime,
            width: 16,
            borderRadius: BorderRadius.zero,
          ),
        ],
      );
    }).toList();

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MODEL COMPARISON', style: TextStyle(color: AppColors.textMediumEmphasis, fontSize: 10, letterSpacing: 2)),
          const SizedBox(height: 20),
          Text(
            'CO2 Emissions (kg)',
            style: TextStyle(color: AppColors.biolumCyan, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                barGroups: co2BarGroups,
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final modelName = state.co2PerModel.keys.elementAt(value.toInt());
                        return SideTitleWidget(
                          meta: meta,
                          angle: -0.7, // Rotate labels
                          child: Text(modelName, style: TextStyle(color: AppColors.textLowEmphasis, fontSize: 10)),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString(), style: TextStyle(color: AppColors.textLowEmphasis, fontSize: 10));
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(enabled: false),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Cost (USD)',
            style: TextStyle(color: AppColors.toxicLime, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                barGroups: costBarGroups,
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final modelName = state.costPerModel.keys.elementAt(value.toInt());
                        return SideTitleWidget(
                          meta: meta,
                          angle: -0.7, // Rotate labels
                          child: Text(modelName, style: TextStyle(color: AppColors.textLowEmphasis, fontSize: 10)),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString(), style: TextStyle(color: AppColors.textLowEmphasis, fontSize: 10));
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(enabled: false),
              ),
            ),
          ),
        ],
      ),
    ).animate().fade(delay: 600.ms).moveY(begin: 30, end: 0);
  }

  Widget _buildUsageTimeline(DashboardState state) {
    if (state.usageTimeline.isEmpty) {
      return const SizedBox.shrink();
    }

    // Determine min/max X values for the chart
    final double minX = state.usageTimeline.first.timestamp.millisecondsSinceEpoch.toDouble();
    final double maxX = state.usageTimeline.last.timestamp.millisecondsSinceEpoch.toDouble();

    // Convert UsagePoint to FlSpot
    final List<FlSpot> spots = state.usageTimeline.map((point) {
      return FlSpot(
        point.timestamp.millisecondsSinceEpoch.toDouble(),
        point.totalTokens.toDouble(),
      );
    }).toList();

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('USAGE TIMELINE', style: TextStyle(color: AppColors.textMediumEmphasis, fontSize: 10, letterSpacing: 2)),
          const SizedBox(height: 20),
          Text(
            'Tokens Used Over Time',
            style: TextStyle(color: AppColors.plasmaBlue, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minX: minX,
                maxX: maxX,
                minY: 0,
                maxY: state.usageTimeline.map((e) => e.totalTokens).reduce((a, b) => a > b ? a : b).toDouble() * 1.2, // 20% buffer
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString(), style: TextStyle(color: AppColors.textLowEmphasis, fontSize: 10));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return SideTitleWidget(
                          meta: meta,
                          angle: -0.7,
                          child: Text('${date.day}/${date.month}', style: TextStyle(color: AppColors.textLowEmphasis, fontSize: 10)),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.plasmaBlue,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.plasmaBlue.withOpacity(0.3),
                          AppColors.plasmaBlue.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fade(delay: 800.ms).moveY(begin: 30, end: 0);
  }

  void _showPredictiveSimulationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Predictive Simulation"),
          content: const Text("This feature is under development. Soon you'll be able to simulate your AI usage!"),
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}