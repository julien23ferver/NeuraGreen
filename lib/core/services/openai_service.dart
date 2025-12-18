import 'package:dio/dio.dart';
import 'storage_service.dart';

class OpenAIService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'https://api.openai.com/v1';

  Future<Map<String, dynamic>?> getUsage() async {
    final apiKey = await StorageService.getKey('openai');
    if (apiKey == null || apiKey.isEmpty) {
      print('OpenAI API key not found.');
      return null;
    }

    try {
      // 1. Get the list of invoices
      final invoicesResponse = await _dio.get(
        '$_baseUrl/invoices',
        options: Options(
          headers: { 'Authorization': 'Bearer $apiKey' },
        ),
      );

      if (invoicesResponse.statusCode == 200 && invoicesResponse.data['data'].isNotEmpty) {
        // 2. Get the latest invoice
        final latestInvoice = invoicesResponse.data['data'].last;
        final invoiceId = latestInvoice['id'];

        // 3. Fetch the details of the latest invoice (line items)
        final lineItemsResponse = await _dio.get(
          '$_baseUrl/invoices/$invoiceId/line_items',
          options: Options(
            headers: { 'Authorization': 'Bearer $apiKey' },
          ),
        );
        
        if (lineItemsResponse.statusCode == 200) {
          print('--- REAL OPENAI USAGE DATA (from latest invoice) ---');
          print(lineItemsResponse.data);
          // We can return the line items directly, or process them here.
          // For now, let's just return the raw line items data.
          return lineItemsResponse.data;
        }
      }
      print('Failed to fetch OpenAI invoices or no invoices found.');
      return null;

    } catch (e) {
      if (e is DioException) {
        print('Error fetching OpenAI usage: ${e.response?.data}');
      } else {
        print('Error fetching OpenAI usage: $e');
      }
      return null;
    }
  }
}
