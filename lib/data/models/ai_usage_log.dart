import 'package:hive/hive.dart';

part 'ai_usage_log.g.dart';

@HiveType(typeId: 0)
class AiUsageLog extends HiveObject {
  @HiveField(0)
  final String provider; // OpenAI, Gemini, etc.

  @HiveField(1)
  final String modelId; // gpt-4, mistral-large, etc.

  @HiveField(2)
  final int promptTokens;

  @HiveField(3)
  final int completionTokens;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final double? costUsd;

  AiUsageLog({
    required this.provider,
    required this.modelId,
    required this.promptTokens,
    required this.completionTokens,
    required this.timestamp,
    this.costUsd,
  });
}
