import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_colors.dart';
import '../../data/models/openai_invoice_item.dart';
import '../../presentation/widgets/glass_card.dart';
import '../settings/settings_screen.dart';
import '../../core/services/openai_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final OpenAIService _openAIService = OpenAIService();
  List<OpenAIInvoiceItem> _invoiceItems = [];
  bool _isLoading = true;

  // Calculated values
  double get _totalCost => _invoiceItems.fold(0, (sum, item) => sum + item.cost);
  int get _totalTokens => _invoiceItems.fold(0, (sum, item) => sum + item.quantity);
  double get _totalCO2Kg => (_totalTokens / 1000) * 0.15; // Placeholder conversion
  double get _totalWaterL => (_totalTokens / 1000) * 0.5; // Placeholder conversion

  @override
  void initState() {
    super.initState();
    _fetchUsage();
  }

  Future<void> _fetchUsage() async {
    setState(() => _isLoading = true);
    final data = await _openAIService.getUsage();
    if (data != null && data['data'] is List) {
      final items = (data['data'] as List)
          .map((item) => OpenAIInvoiceItem.fromJson(item))
          .toList();
      setState(() {
        _invoiceItems = items;
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Blobs etc.
          _buildAnimatedBlob(AppColors.biolumCyan, -100, -50, 300, 6.seconds),
          _buildAnimatedBlob(AppColors.plasmaBlue, 250, -100, 400, 8.seconds),
          _buildAnimatedBlob(AppColors.toxicLime, null, -100, 350, 10.seconds, bottom: -50),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: _fetchUsage,
              backgroundColor: AppColors.biolumCyan,
              color: AppColors.background,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SYSTEM ' + (_isLoading ? 'LOADING...' : 'OPTIMAL'),
                              style: GoogleFonts.spaceGrotesk(
                                color: AppColors.biolumCyan,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.tune_rounded, color: AppColors.textMediumEmphasis),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Eco-Impact\nAnalytics', style: GoogleFonts.spaceGrotesk(color: AppColors.textHighEmphasis, fontSize: 32, fontWeight: FontWeight.w600, height: 1.1)),
                    
                    const SizedBox(height: 40),

                    // CO2 Card
                    GlassCard(
                      width: double.infinity,
                      child: _isLoading 
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('TOTAL FOOTPRINT', style: TextStyle(color: AppColors.textMediumEmphasis, fontSize: 10, letterSpacing: 1.5)), _PulsingDot()]),
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(_totalCO2Kg.toStringAsFixed(2), style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: -3)),
                              const SizedBox(width: 8),
                              const Text('kg CO2e', style: TextStyle(color: AppColors.biolumCyan, fontSize: 16, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 200.ms).moveY(begin: 20, end: 0),
                    
                    const SizedBox(height: 20),

                    // Water & Cost Cards
                    Row(
                      children: [
                        Expanded(
                          child: GlassCard(
                            child: _isLoading 
                                ? const Center(child: CircularProgressIndicator())
                                : _buildMetric('WATER', _totalWaterL.toStringAsFixed(1), 'Liters', AppColors.plasmaBlue),
                          ),
                        ).animate().fade(delay: 300.ms).moveY(begin: 20, end: 0),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GlassCard(
                            child: _isLoading 
                                ? const Center(child: CircularProgressIndicator())
                                : _buildMetric('COST', '\$${_totalCost.toStringAsFixed(2)}', 'USD', AppColors.toxicLime),
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

  Widget _buildAnimatedBlob(Color color, double? top, double? right, double size, Duration duration, {double? left, double? bottom}) {
    return Positioned(
      top: top, right: right, left: left, bottom: bottom,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.12))),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 0, end: 30, duration: duration, curve: Curves.easeInOutSine).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: duration),
    );
  }

  Widget _buildMetric(String label, String value, String unit, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 20, height: 2, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        Text(label, style: const TextStyle(color: AppColors.textMediumEmphasis, fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        Text(unit, style: TextStyle(color: color.withOpacity(0.8), fontSize: 11)),
      ],
    );
  }
}

class _PulsingDot extends StatelessWidget {
  const _PulsingDot();
  @override
  Widget build(BuildContext context) {
    return Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.toxicLime, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.toxicLime, blurRadius: 4)])).animate(onPlay: (c) => c.repeat(reverse: true)).fade(begin: 0.3, end: 1.0, duration: 1.seconds);
  }
}
