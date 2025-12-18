import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_colors.dart';
import '../../presentation/widgets/glass_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Fond noir profond
          Container(color: AppColors.background),
          
          // 2. "Blobs" de couleur pour révéler le verre (Ambient Light)
          Positioned(
            top: -100,
            right: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF64FFDA).withOpacity(0.15), // Cyan
                ),
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF80D8FF).withOpacity(0.1), // Bleu
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF69F0AE).withOpacity(0.05), // Vert
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  // Header
                  Text(
                    'SYSTEM OPTIMAL',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.accentCyan,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.5,
                    ),
                  ).animate().fade(duration: 600.ms).slideX(begin: -0.1, end: 0),
                  
                  const SizedBox(height: 8),
                  Text(
                    'Eco-Impact\nAnalytics',
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.textMain,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ).animate().fade(duration: 800.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 40),
                  
                  // Main Metric (CO2)
                  const GlassCard(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL FOOTPRINT',
                              style: TextStyle(color: AppColors.textDim, fontSize: 10, letterSpacing: 1.5),
                            ),
                            // Indicateur visuel abstrait (Point pulsant)
                            _PulsingDot(),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '1,240',
                              style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: -2),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'g CO2e',
                              style: TextStyle(color: AppColors.accentCyan, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Equivalent to 0.5 tree/year',
                          style: TextStyle(color: AppColors.textDim, fontSize: 12),
                        ),
                      ],
                    ),
                  ).animate().fade(duration: 800.ms, delay: 200.ms).moveY(begin: 20, end: 0, curve: Curves.easeOutQuad),
                  
                  const SizedBox(height: 20),
                  
                  // Secondary Metrics Row
                  Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          child: _buildSmallMetric(
                            'WATER',
                            '4.2',
                            'Liters',
                            AppColors.accentBlue,
                          ),
                        ),
                      ).animate().fade(duration: 800.ms, delay: 300.ms).moveY(begin: 20, end: 0, curve: Curves.easeOutQuad),
                      
                      const SizedBox(width: 16),
                      
                      Expanded(
                        child: GlassCard(
                          child: _buildSmallMetric(
                            'COST',
                            '12.45',
                            'USD',
                            const Color(0xFF69F0AE), // Soft Green
                          ),
                        ),
                      ).animate().fade(duration: 800.ms, delay: 400.ms).moveY(begin: 20, end: 0, curve: Curves.easeOutQuad),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallMetric(String label, String value, String unit, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ligne décorative minimaliste au lieu d'une icône
        Container(
          width: 20,
          height: 2,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          label,
          style: const TextStyle(color: AppColors.textDim, fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
        ),
        Text(
          unit,
          style: TextStyle(color: accentColor.withOpacity(0.8), fontSize: 11),
        ),
      ],
    );
  }
}

class _PulsingDot extends StatelessWidget {
  const _PulsingDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.accentCyan,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.accentCyan.withOpacity(0.5),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
    .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 1500.ms, curve: Curves.easeInOut);
  }
}
