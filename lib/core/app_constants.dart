
class ModelImpact {
  final double co2eGramsPer1000Tokens;
  final double waterLitersPer1000Tokens;

  ModelImpact({
    required this.co2eGramsPer1000Tokens,
    required this.waterLitersPer1000Tokens,
  });
}

/// Data on the environmental impact of different AI models.
/// The values are estimates and should be refined as more data becomes available.
///
/// Sources:
/// - Gemini: Google claims 0.03g of CO2e and 0.26ml of water per median prompt.
///   We assume a median prompt is 1000 tokens.
///   https://google.com/search?q=co2+emissions+for+different+llm+models
///
/// For other models, the data is not as clear, so we use a more conservative
/// estimate. The impact heavily depends on the data center's energy mix.
final Map<String, ModelImpact> modelImpacts = {
  'gemini-pro': ModelImpact(
    co2eGramsPer1000Tokens: 0.03,
    waterLitersPer1000Tokens: 0.00026,
  ),
  'gpt-4': ModelImpact(
    co2eGramsPer1000Tokens: 10, // Placeholder, to be refined
    waterLitersPer1000Tokens: 0.1,  // Placeholder, to be refined
  ),
  'mistral-large': ModelImpact(
    co2eGramsPer1000Tokens: 8, // Placeholder, to be refined
    waterLitersPer1000Tokens: 0.08, // Placeholder, to be refined
  ),
  'default': ModelImpact(
    co2eGramsPer1000Tokens: 10,
    waterLitersPer1000Tokens: 0.1,
  ),
};

/// Estimated cost per 1000 tokens for different AI models in USD.
/// These are simplified examples and actual costs vary.
final Map<String, double> modelCosts = {
  'gemini-pro': 0.0002 / 1000, // example cost per 1000 tokens in USD
  'gpt-4': 0.03 / 1000, // example cost per 1000 tokens in USD
  'mistral-large': 0.008 / 1000, // example cost per 1000 tokens in USD
  'default': 0.001 / 1000, // example cost per 1000 tokens in USD
};
