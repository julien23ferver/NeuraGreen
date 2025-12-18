import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_colors.dart';
import '../../presentation/widgets/glass_card.dart';
import 'dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget { // Changement ici
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Changement ici
    final dashboardState = ref.watch(dashboardProvider); // On écoute les changements

    return Scaffold(
      backgroundColor: AppColors.background,
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
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildMainCard(dashboardState), // On passe les données
                  const SizedBox(height: 20),
                  _buildSecondaryMetrics(dashboardState), // On passe les données
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
          decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.12)),
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
        Text(unit, style: TextStyle(color: color.withOpacity(0.7), fontSize: 11)),
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
    ).animate().fade().slideX();
  }
}
