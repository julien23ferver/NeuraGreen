import 'package:dio/dio.dart';
import 'package:eco_ai_tracker/data/models/ai_usage_log.dart';
import 'package:eco_ai_tracker/data/models/openai_invoice_item.dart';
import 'storage_service.dart';

class OpenAIService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'https://api.openai.com/v1';

  Future<List<AiUsageLog>?> getUsage() async {
    final apiKey = await StorageService.getKey('openai');
    if (apiKey == null || apiKey.isEmpty) {
      // It's better to throw an exception or handle this in the UI layer
      return null;
    }

    try {
      final invoicesResponse = await _dio.get(
        '$_baseUrl/invoices',
        options: Options(
          headers: {'Authorization': 'Bearer $apiKey'},
        ),
      );

      if (invoicesResponse.statusCode == 200 &&
          invoicesResponse.data['data'].isNotEmpty) {
        final latestInvoice = invoicesResponse.data['data'].last;
        final invoiceId = latestInvoice['id'];

        final lineItemsResponse = await _dio.get(
          '$_baseUrl/invoices/$invoiceId/line_items',
          options: Options(
            headers: {'Authorization': 'Bearer $apiKey'},
          ),
        );

        if (lineItemsResponse.statusCode == 200) {
          final List<dynamic> items = lineItemsResponse.data['data'];
          final List<OpenAIInvoiceItem> invoiceItems = items
              .map((item) => OpenAIInvoiceItem.fromJson(item))
              .toList();

          final List<AiUsageLog> usageLogs = invoiceItems.map((item) {
            // This is a simplification. The 'name' field can be complex.
            // e.g., "GPT-4 usage", "DALL-E 2 usage", etc.
            final modelId = _extractModelId(item.name);
            
            // The invoice does not provide prompt and completion tokens separately.
            // We will store the total tokens in the prompt_tokens field.
            return AiUsageLog(
              provider: 'OpenAI',
              modelId: modelId,
              promptTokens: item.quantity,
              completionTokens: 0,
              timestamp: DateTime.now(), // Invoice date would be better
              costUsd: item.cost,
            );
          }).toList();
          
          return usageLogs;
        }
      }
      return null;
    } on DioException {
      // Log the error, and let the caller handle it
      return null;
    } catch (_) {
      return null;
    }
  }

  String _extractModelId(String name) {
    if (name.toLowerCase().contains('gpt-4')) {
      return 'gpt-4';
    }
    if (name.toLowerCase().contains('dall-e')) {
      return 'dall-e';
    }
    // Add more model extraction rules here
    return 'unknown';
  }
}