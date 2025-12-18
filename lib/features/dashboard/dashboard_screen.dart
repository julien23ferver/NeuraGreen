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
      backgroundColor: AppColors.background, // Noir Abyssal
      body: Stack(
        children: [
          // --- COUCHE 1 : AMBIENT LIGHT (Blobs animés) ---
          
          // Blob Cyan (Haut Droite)
          Positioned(
            top: -100,
            right: -50,
            child: _buildAmbientBlob(AppColors.biolumCyan, 300)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: 40, duration: 6.seconds, curve: Curves.easeInOutSine)
                .scaleXY(begin: 1.0, end: 1.1, duration: 8.seconds),
          ),
          
          // Blob Bleu (Milieu Gauche)
          Positioned(
            top: 300,
            left: -100,
            child: _buildAmbientBlob(AppColors.plasmaBlue, 400)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: -30, duration: 7.seconds, curve: Curves.easeInOutQuad)
                .fade(begin: 0.5, end: 0.8, duration: 5.seconds),
          ),

          // Blob Vert (Bas Droite)
          Positioned(
            bottom: -50,
            right: -100,
            child: _buildAmbientBlob(AppColors.toxicLime, 350)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 0.8, end: 1.0, duration: 10.seconds),
          ),

          // --- COUCHE 2 : CONTENU SCROLLABLE ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              // FIX : SingleChildScrollView ajouté ici pour éviter l'overflow
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    
                    // En-tête "Technique"
                    Text(
                      'SYSTEM OPTIMAL',
                      style: GoogleFonts.spaceGrotesk(
                        color: AppColors.biolumCyan,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ).animate().fade().slideX(),

                    const SizedBox(height: 8),
                    Text(
                      'Eco-Impact\nAnalytics',
                      style: GoogleFonts.spaceGrotesk(
                        color: AppColors.textHighEmphasis,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ).animate().fade(delay: 100.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 40),

                    // La "Hero" Card (CO2)
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
                                style: TextStyle(
                                  color: AppColors.textMediumEmphasis,
                                  fontSize: 10, 
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                              _PulsingDot(),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '1.24',
                                style: TextStyle(
                                  color: AppColors.textHighEmphasis,
                                  fontSize: 64, 
                                  fontWeight: FontWeight.bold, 
                                  fontFamily: 'monospace',
                                  letterSpacing: -3
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'kg CO2e',
                                style: TextStyle(
                                  color: AppColors.biolumCyan, 
                                  fontSize: 16, 
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            '≈ 0.5 tree absorbed this year',
                            style: TextStyle(color: AppColors.textMediumEmphasis, fontSize: 12),
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 200.ms).moveY(begin: 20, end: 0),

                    const SizedBox(height: 20),

                    // Les petites cartes
                    Row(
                      children: [
                        Expanded(
                          child: GlassCard(
                            child: _buildMetricItem(
                              'WATER USAGE', 
                              '4.2', 
                              'Liters', 
                              AppColors.plasmaBlue
                            ),
                          ),
                        ).animate().fade(delay: 300.ms).moveY(begin: 20, end: 0),
                        
                        const SizedBox(width: 16),
                        
                        Expanded(
                          child: GlassCard(
                            child: _buildMetricItem(
                              'EST. COST', 
                              r'$12.4',
                              'USD', 
                              AppColors.toxicLime
                            ),
                          ),
                        ).animate().fade(delay: 400.ms).moveY(begin: 20, end: 0),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper pour les blobs flous
  Widget _buildAmbientBlob(Color color, double size) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.15),
        ),
      ),
    );
  }

  // Helper pour le contenu des petites cartes
  Widget _buildMetricItem(String label, String value, String unit, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24, height: 3,
          decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 16),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMediumEmphasis, 
            fontSize: 9, 
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textHighEmphasis,
            fontSize: 28, 
            fontWeight: FontWeight.bold, 
            fontFamily: 'monospace'
          ),
        ),
        Text(
          unit,
          style: TextStyle(color: accent.withOpacity(0.8), fontSize: 11),
        ),
      ],
    );
  }
}

// Le petit point qui clignote "Live"
class _PulsingDot extends StatelessWidget {
  const _PulsingDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6, height: 6,
      decoration: const BoxDecoration(
        color: AppColors.toxicLime,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: AppColors.toxicLime, blurRadius: 6, spreadRadius: 1)
        ],
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
     .fade(begin: 0.4, end: 1.0, duration: 1.seconds);
  }
}
