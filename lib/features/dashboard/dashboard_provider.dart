import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../data/models/ai_usage_log.dart';

// 1. Le modèle de données pour l'état du Dashboard
class DashboardState {
  final double totalCost;
  final double totalCO2;
  final double totalWater;

  DashboardState({
    this.totalCost = 0.0,
    this.totalCO2 = 0.0,
    this.totalWater = 0.0,
  });
}

// 2. Le Notifier qui gère la logique
class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(DashboardState()) {
    _calculateTotals();
  }

  void _calculateTotals() {
    final box = Hive.box<AiUsageLog>('ai_usage_logs');
    
    double cost = 0;
    int tokens = 0;
    
    for (var log in box.values) {
      cost += log.costUsd ?? 0;
      tokens += log.promptTokens + log.completionTokens;
    }

    // Coefficients de calcul (à affiner plus tard)
    final co2Per1000Tokens = 0.15; // kg CO2e
    final waterPer1000Tokens = 0.5; // Liters

    final totalCO2 = (tokens / 1000) * co2Per1000Tokens;
    final totalWater = (tokens / 1000) * waterPer1000Tokens;

    state = DashboardState(
      totalCost: cost,
      totalCO2: totalCO2,
      totalWater: totalWater,
    );
  }

  // Cette fonction sera appelée après avoir récupéré de nouvelles données
  void refresh() {
    _calculateTotals();
  }
}

// 3. Le Provider global que l'UI va écouter
final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});
