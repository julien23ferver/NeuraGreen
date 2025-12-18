import 'dart:ui';
import 'package:flutter/material.dart';

class AppColors {
  // Fond : Un noir "Abyssal" (légèrement bleuté/chaud) pour éviter le coté "écran éteint"
  static const Color background = Color(0xFF050507);
  
  // Les Accents "Data" (Gradients implicites)
  static const Color biolumCyan = Color(0xFF00F0FF); // Cyberpunk Cyan
  static const Color plasmaBlue = Color(0xFF4D8DFF); // Deep Blue
  static const Color toxicLime = Color(0xFFCCFF00); // Eco Energy
  static const Color alertOrange = Color(0xFFFF5E00); // High CO2 warning

  // Textes
  static const Color textHighEmphasis = Color(0xFFEEEEEE);
  static const Color textMediumEmphasis = Color(0xFFAAAAAA); // Plus lisible que le gris standard
  
  // Verre (Nuances techniques)
  // Utilisé pour les bordures qui accrochent la lumière
  static const Color glassBorderLight = Color(0x33FFFFFF); 
  static const Color glassBorderDark = Color(0x00FFFFFF); 
}