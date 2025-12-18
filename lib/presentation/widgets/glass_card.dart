import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    // BorderRadius constant pour harmoniser
    final borderRadius = BorderRadius.circular(24);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Flou "Frosted"
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            // 1. Le fond du verre (très subtil)
            color: Colors.white.withOpacity(0.03),
            // 2. Un gradient de surface (reflet global)
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.01),
              ],
            ),
          ),
          child: Stack(
            children: [
              // 3. La Bordure "Lumière" (Rim Lighting)
              // On utilise un Container interne avec un gradient de bordure
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    border: Border.all(color: Colors.transparent), // Hack structurel
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.0, 0.4, 1.0],
                      colors: [
                        Colors.white.withOpacity(0.3), // Lumière vive coin haut gauche
                        Colors.white.withOpacity(0.05), // Transition
                        Colors.white.withOpacity(0.0),  // Ombre totale coin bas droite
                      ],
                    ),
                  ),
                ),
              ),
              // 4. Le contenu réel
              Padding(
                padding: padding,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
