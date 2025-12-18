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
    return ClipRRect(
      borderRadius: BorderRadius.circular(30), // Arrondi plus prononcé style Apple
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25), // Blur intense
        child: Stack(
          children: [
            // 1. Fond semi-transparent
            Container(
              width: width,
              height: height,
              padding: padding,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08), // Base très légère
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15), // Reflet haut gauche
                    Colors.white.withOpacity(0.02), // Quasi transparent bas droite
                  ],
                ),
              ),
              child: child,
            ),
            
            // 2. Bordure dégradée (Simulée)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1), // Bordure fine uniforme
                    width: 1,
                  ),
                  // Le gradient de "reflet" est déjà sur le fond, pas besoin de complexifier la bordure pour l'instant
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
