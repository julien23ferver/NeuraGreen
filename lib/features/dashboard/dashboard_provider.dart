import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../core/services/openai_service.dart';
import '../../data/models/ai_usage_log.dart';
import '../../core/app_constants.dart';
import '../../data/models/user_settings.dart';
import '../../core/services/notification_service.dart';
import '../../data/models/usage_point.dart';

// 1. Le modèle de données pour l'état du Dashboard
class DashboardState {
  final double totalCost;
  final double totalCO2;
  final double totalWater;
  final double? co2Budget;
  final double? waterBudget;
  final double? costBudget;
  final Map<String, double> co2PerModel;
  final Map<String, double> costPerModel;
  final List<UsagePoint> usageTimeline;
  final Map<String, int> tokensPerProvider;

  DashboardState({
    this.totalCost = 0.0,
    this.totalCO2 = 0.0,
    this.totalWater = 0.0,
    this.co2Budget,
    this.waterBudget,
    this.costBudget,
    this.co2PerModel = const {},
    this.costPerModel = const {},
    this.usageTimeline = const [],
    this.tokensPerProvider = const {},
  });
}

// 2. Le Notifier qui gère la logique
class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    return _calculateTotals();
  }

  DashboardState _calculateTotals() {
    final aiUsageBox = Hive.box<AiUsageLog>('ai_usage_logs');
    final userSettingsBox = Hive.box<UserSettings>('user_settings');
    final settings = userSettingsBox.get(0); // Assuming only one settings object

    double totalCost = 0;
    double totalCO2 = 0;
    double totalWater = 0;

    final Map<String, double> co2PerModelMap = {};
    final Map<String, double> costPerModelMap = {};
    final List<UsagePoint> usageTimelineList = [];
    final Map<String, int> tokensPerProviderMap = {};

    for (var log in aiUsageBox.values) {
      totalCost += log.costUsd ?? 0;

      final impact = modelImpacts[log.modelId] ?? modelImpacts['default']!;
      final totalTokens = log.promptTokens + log.completionTokens;

      final co2 = (totalTokens / 1000) * (impact.co2eGramsPer1000Tokens / 1000); // Convert grams to kg
      final water = (totalTokens / 1000) * impact.waterLitersPer1000Tokens;

      totalCO2 += co2;
      totalWater += water;

      co2PerModelMap.update(log.modelId, (value) => value + co2, ifAbsent: () => co2);
      costPerModelMap.update(log.modelId, (value) => value + (log.costUsd ?? 0), ifAbsent: () => (log.costUsd ?? 0));
      usageTimelineList.add(UsagePoint(log.timestamp, totalTokens));
      tokensPerProviderMap.update(log.provider, (value) => value + totalTokens, ifAbsent: () => totalTokens);
    }

    // Sort the timeline by timestamp
    usageTimelineList.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return DashboardState(
      totalCost: totalCost,
      totalCO2: totalCO2,
      totalWater: totalWater,
      co2Budget: settings?.co2Budget,
      waterBudget: settings?.waterBudget,
      costBudget: settings?.costBudget,
      co2PerModel: co2PerModelMap,
      costPerModel: costPerModelMap,
      usageTimeline: usageTimelineList,
      tokensPerProvider: tokensPerProviderMap,
    );
  }

  // Cette fonction sera appelée après avoir récupéré de nouvelles données
  void refresh() {
    state = _calculateTotals();
    _checkBudgetExceeded();
    _checkIntelligentAlerts();
  }

  void _checkBudgetExceeded() {
    final NotificationService notificationService = NotificationService();
    int notificationId = 0; // Unique ID for notifications

    if (state.co2Budget != null && state.totalCO2 > state.co2Budget!) {
      notificationService.showNotification(
        notificationId++,
        'CO2 Budget Exceeded!',
        'You have exceeded your CO2 budget of ${state.co2Budget!.toStringAsFixed(2)} kg by ${ (state.totalCO2 - state.co2Budget!).toStringAsFixed(2)} kg.',
      );
    }
    if (state.waterBudget != null && state.totalWater > state.waterBudget!) {
      notificationService.showNotification(
        notificationId++,
        'Water Budget Exceeded!',
        'You have exceeded your water budget of ${state.waterBudget!.toStringAsFixed(2)} L by ${ (state.totalWater - state.waterBudget!).toStringAsFixed(2)} L.',
      );
    }
    if (state.costBudget != null && state.totalCost > state.costBudget!) {
      notificationService.showNotification(
        notificationId++,
        'Cost Budget Exceeded!',
        'You have exceeded your cost budget of \$${state.costBudget!.toStringAsFixed(2)} by \$${ (state.totalCost - state.costBudget!).toStringAsFixed(2)}.',
      );
    }
  }

  void _checkIntelligentAlerts() {
    final NotificationService notificationService = NotificationService();
    int notificationId = 100; // Unique ID for intelligent alerts, distinct from budget alerts

    if (state.co2PerModel.isEmpty) return;

    // Find the model with the highest CO2
    final sortedCo2Models = state.co2PerModel.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final highestCo2ModelEntry = sortedCo2Models.first;
    final String highestCo2Model = highestCo2ModelEntry.key;
    final double highestCo2Value = highestCo2ModelEntry.value;

    // Find the model with the lowest CO2 (excluding the highest if it's the only one)
    final sortedImpactModels = modelImpacts.entries.toList()
      ..sort((a, b) => a.value.co2eGramsPer1000Tokens.compareTo(b.value.co2eGramsPer1000Tokens));
    
    // Filter out the 'default' entry if it's not a real model
    final List<MapEntry<String, ModelImpact>> realImpactModels = sortedImpactModels
        .where((entry) => entry.key != 'default' && entry.key != highestCo2Model)
        .toList();

    if (realImpactModels.isEmpty) return; // Not enough models to compare

    final lowestCo2ModelEntry = realImpactModels.first;
    final String lowestCo2Model = lowestCo2ModelEntry.key;
    
    // Only suggest if there's a significant difference and it's not the lowest already
    if (highestCo2Model != lowestCo2Model && highestCo2Value > 0) {
      notificationService.showNotification(
        notificationId++,
        'Eco-Efficiency Alert!',
        'You\'re using "$highestCo2Model" which has high CO2 emissions. Consider "$lowestCo2Model" for a more eco-friendly choice!',
      );
    }
  }

  Future<void> fetchAndSaveUsageData() async {
    final openAIService = OpenAIService();
    final usageLogs = await openAIService.getUsage();

    if (usageLogs != null) {
      final box = Hive.box<AiUsageLog>('ai_usage_logs');
      // We should avoid duplicates. For now, we clear the box before adding new data.
      // A better approach would be to check for existing logs based on a unique id.
      await box.clear();
      await box.addAll(usageLogs);
      refresh();
    }
  }
}

// 3. Le Provider global que l'UI va écouter
final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(DashboardNotifier.new);