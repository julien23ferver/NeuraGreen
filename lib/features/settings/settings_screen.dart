import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_colors.dart';
import '../../presentation/widgets/glass_card.dart';
import '../../core/services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _openaiController = TextEditingController();
  final _geminiController = TextEditingController();
  final _mistralController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  Future<void> _loadKeys() async {
    final openAiKey = await StorageService.getKey('openai');
    final geminiKey = await StorageService.getKey('gemini');
    final mistralKey = await StorageService.getKey('mistral');
    
    if (mounted) {
      setState(() {
        _openaiController.text = openAiKey ?? '';
        _geminiController.text = geminiKey ?? '';
        _mistralController.text = mistralKey ?? '';
      });
    }
  }

  Future<void> _saveAllKeys() async {
    await StorageService.saveKey('openai', _openaiController.text);
    await StorageService.saveKey('gemini', _geminiController.text);
    await StorageService.saveKey('mistral', _mistralController.text);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.biolumCyan.withOpacity(0.2),
          content: const Text('Keys secured and saved.', style: TextStyle(color: AppColors.biolumCyan)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'CONFIGURATION',
          style: TextStyle(
            color: AppColors.biolumCyan,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            fontFamily: 'SpaceGrotesk',
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: -100,
            left: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.plasmaBlue.withOpacity(0.1),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'API Credentials',
                    style: TextStyle(
                      color: AppColors.textHighEmphasis,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SpaceGrotesk',
                    ),
                  ).animate().fade().slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 8),
                  Text(
                    'Stored with hardware encryption.',
                    style: TextStyle(color: AppColors.textMediumEmphasis, fontSize: 14),
                  ).animate().fade(delay: 100.ms),
                  
                  const SizedBox(height: 32),
                  
                  _buildSettingsSection(
                    'OPENAI',
                    'sk-....',
                    AppColors.biolumCyan,
                    _openaiController,
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 20),
                  
                  _buildSettingsSection(
                    'GOOGLE GEMINI',
                    'AIza....',
                    AppColors.plasmaBlue,
                    _geminiController,
                  ).animate().fade(delay: 300.ms).slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 20),
                  
                  _buildSettingsSection(
                    'MISTRAL AI',
                    'API Key',
                    AppColors.toxicLime,
                    _mistralController,
                  ).animate().fade(delay: 400.ms).slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _saveAllKeys();
                        // On attend un peu avant de quitter pour montrer la confirmation
                        await Future.delayed(const Duration(milliseconds: 500));
                        if (mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.biolumCyan.withOpacity(0.1),
                        foregroundColor: AppColors.biolumCyan,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: AppColors.biolumCyan.withOpacity(0.5)),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'SAVE & INITIALIZE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontFamily: 'SpaceGrotesk',
                        ),
                      ),
                    ),
                  ).animate().fade(delay: 500.ms).scale(begin: const Offset(0.95, 0.95)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String label, String hint, Color accent, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: accent,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontFamily: 'SpaceGrotesk',
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: EdgeInsets.zero,
          child: TextField(
            controller: controller,
            obscureText: true, // Pour cacher les clés
            style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.textDim),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}