import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final fonts = {
    'SpaceGrotesk': 'https://fonts.google.com/download?family=Space%20Grotesk',
    'Inter': 'https://fonts.google.com/download?family=Inter',
  };

  for (var entry in fonts.entries) {
    print('Downloading ${entry.key}...');
    final response = await http.get(Uri.parse(entry.value));
    if (response.statusCode == 200) {
      final zipFile = File('assets/fonts/${entry.key}.zip');
      await zipFile.writeAsBytes(response.bodyBytes);
      print('Downloaded ${entry.key}.zip. Please unzip it in assets/fonts/ and update pubspec.yaml');
    } else {
      print('Failed to download ${entry.key}');
    }
  }
}
