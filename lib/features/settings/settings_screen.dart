import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert'; // Added for JSON encoding
import 'dart:io'; // Added for file operations
import 'package:csv/csv.dart'; // Added for CSV export
import 'package:path_provider/path_provider.dart'; // Added for path_provider
import 'package:url_launcher/url_launcher.dart'; // Added for url_launcher
import 'package:hive/hive.dart';
import '../../core/app_colors.dart';
import '../../data/models/user_settings.dart';
import '../../presentation/widgets/glass_card.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/ai_usage_log.dart'; // Add this for AiUsageLog

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _openaiController = TextEditingController();
  final _geminiController = TextEditingController();
  final _mistralController = TextEditingController();

  // Budget controllers
  final _co2Controller = TextEditingController();
  final _waterController = TextEditingController();
  final _costController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load API Keys
    final openAiKey = await StorageService.getKey('openai');
    final geminiKey = await StorageService.getKey('gemini');
    final mistralKey = await StorageService.getKey('mistral');

    // Load Budget Settings
    final settingsBox = Hive.box<UserSettings>('user_settings');
    final settings = settingsBox.get(0);

    if (mounted) {
      setState(() {
        _openaiController.text = openAiKey ?? '';
        _geminiController.text = geminiKey ?? '';
        _mistralController.text = mistralKey ?? '';
        if (settings != null) {
          _co2Controller.text = settings.co2Budget?.toString() ?? '';
          _waterController.text = settings.waterBudget?.toString() ?? '';
          _costController.text = settings.costBudget?.toString() ?? '';
        }
      });
    }
  }

  Future<void> _saveAll() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Save API Keys
    await StorageService.saveKey('openai', _openaiController.text);
    await StorageService.saveKey('gemini', _geminiController.text);
    await StorageService.saveKey('mistral', _mistralController.text);

    // Save Budget Settings
    final settingsBox = Hive.box<UserSettings>('user_settings');
    final settings = settingsBox.get(0) ?? UserSettings();

    settings.co2Budget = double.tryParse(_co2Controller.text);
    settings.waterBudget = double.tryParse(_waterController.text);
    settings.costBudget = double.tryParse(_costController.text);
    
    await settingsBox.put(0, settings);

    if (mounted) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          backgroundColor: AppColors.biolumCyan.withAlpha((255 * 0.2).round()),
          content: const Text('Settings saved successfully.', style: TextStyle(color: AppColors.biolumCyan)),
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
                  color: AppColors.plasmaBlue.withAlpha((255 * 0.1).round()),
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

                  // Eco-Budget Section
                  const Text(
                    'Eco-Budget',
                    style: TextStyle(
                      color: AppColors.textHighEmphasis,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SpaceGrotesk',
                    ),
                  ).animate().fade().slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Set monthly limits for your environmental impact.',
                    style: TextStyle(color: AppColors.textMediumEmphasis, fontSize: 14),
                  ).animate().fade(delay: 100.ms),
                  const SizedBox(height: 32),

                  _buildSettingsSection(
                    'CO2 Budget (kg)',
                    'e.g., 5.0',
                    AppColors.biolumCyan,
                    _co2Controller,
                    obscureText: false,
                    inputType: TextInputType.number,
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 20),
                  _buildSettingsSection(
                    'Water Budget (L)',
                    'e.g., 20.0',
                    AppColors.plasmaBlue,
                    _waterController,
                    obscureText: false,
                    inputType: TextInputType.number,
                  ).animate().fade(delay: 300.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 20),
                  _buildSettingsSection(
                    'Cost Budget (USD)',
                    'e.g., 10.00',
                    AppColors.toxicLime,
                    _costController,
                    obscureText: false,
                    inputType: TextInputType.number,
                  ).animate().fade(delay: 400.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 40),

                  // Export Section
                  const Text(
                    'Export Data',
                    style: TextStyle(
                      color: AppColors.textHighEmphasis,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SpaceGrotesk',
                    ),
                  ).animate().fade().slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Export your usage history to CSV or JSON.',
                    style: TextStyle(color: AppColors.textMediumEmphasis, fontSize: 14),
                  ).animate().fade(delay: 100.ms),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () => _showExportDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.plasmaBlue.withAlpha((255 * 0.1).round()),
                        foregroundColor: AppColors.plasmaBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: AppColors.plasmaBlue.withAlpha((255 * 0.5).round())),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'EXPORT HISTORY',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontFamily: 'SpaceGrotesk',
                        ),
                      ),
                    ),
                  ).animate().fade(delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        await _saveAll();
                        // On attend un peu avant de quitter pour montrer la confirmation
                        await Future.delayed(const Duration(milliseconds: 500));
                        if (mounted) navigator.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.biolumCyan.withAlpha((255 * 0.1).round()),
                        foregroundColor: AppColors.biolumCyan,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: AppColors.biolumCyan.withAlpha((255 * 0.5).round())),
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

  Widget _buildSettingsSection(String label, String hint, Color accent, TextEditingController controller, {bool obscureText = true, TextInputType? inputType}) {
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
            obscureText: obscureText, // Use the parameter
            keyboardType: inputType, // Use the parameter
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

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text('Export History', style: TextStyle(color: AppColors.textHighEmphasis)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.description, color: AppColors.biolumCyan),
                title: const Text('Export to CSV', style: TextStyle(color: AppColors.textHighEmphasis)),
                onTap: () {
                  Navigator.pop(context);
                  _exportToCsv(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.data_object, color: AppColors.toxicLime),
                title: const Text('Export to JSON', style: TextStyle(color: AppColors.textHighEmphasis)),
                onTap: () {
                  Navigator.pop(context);
                  _exportToJson(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMediumEmphasis)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportToCsv(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final box = Hive.box<AiUsageLog>('ai_usage_logs');
      if (box.isEmpty) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            backgroundColor: AppColors.plasmaBlue.withAlpha((255 * 0.2).round()),
            content: const Text('No data to export.', style: TextStyle(color: AppColors.plasmaBlue)),
          ),
        );
        return;
      }

      List<List<dynamic>> rows = [];
      // Add headers
      rows.add(['Timestamp', 'Provider', 'Model ID', 'Prompt Tokens', 'Completion Tokens', 'Cost (USD)']);
      
      for (var log in box.values) {
        rows.add([
          log.timestamp.toIso8601String(),
          log.provider,
          log.modelId,
          log.promptTokens,
          log.completionTokens,
          log.costUsd ?? 0.0,
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/ai_usage_history.csv';
      final file = File(path);
      await file.writeAsString(csv);

      scaffoldMessenger.showSnackBar(
        SnackBar(
          backgroundColor: AppColors.biolumCyan.withAlpha((255 * 0.2).round()),
          content: Text('History exported to $path', style: const TextStyle(color: AppColors.biolumCyan)),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () => _openFileLocation(path),
            textColor: AppColors.biolumCyan,
          ),
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          backgroundColor: AppColors.toxicLime.withAlpha((255 * 0.2).round()),
          content: Text('Failed to export CSV: $e', style: const TextStyle(color: AppColors.toxicLime)),
        ),
      );
    }
  }

  Future<void> _exportToJson(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final box = Hive.box<AiUsageLog>('ai_usage_logs');
      if (box.isEmpty) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            backgroundColor: AppColors.plasmaBlue.withAlpha((255 * 0.2).round()),
            content: const Text('No data to export.', style: TextStyle(color: AppColors.plasmaBlue)),
          ),
        );
        return;
      }

      List<Map<String, dynamic>> jsonData = box.values.map((log) => {
        'timestamp': log.timestamp.toIso8601String(),
        'provider': log.provider,
        'modelId': log.modelId,
        'promptTokens': log.promptTokens,
        'completionTokens': log.completionTokens,
        'costUsd': log.costUsd ?? 0.0,
      }).toList();

      String jsonString = jsonEncode(jsonData);
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/ai_usage_history.json';
      final file = File(path);
      await file.writeAsString(jsonString);

      scaffoldMessenger.showSnackBar(
        SnackBar(
          backgroundColor: AppColors.biolumCyan.withAlpha((255 * 0.2).round()),
          content: Text('History exported to $path', style: const TextStyle(color: AppColors.biolumCyan)),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () => _openFileLocation(path),
            textColor: AppColors.biolumCyan,
          ),
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          backgroundColor: AppColors.toxicLime.withAlpha((255 * 0.2).round()),
          content: Text('Failed to export JSON: $e', style: const TextStyle(color: AppColors.toxicLime)),
        ),
      );
    }
  }

  Future<void> _openFileLocation(String filePath) async {
    final uri = Uri.file(filePath);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Handle the case where the file cannot be opened (e.g., no default app)
      print('Could not launch $filePath');
    }
  }
}