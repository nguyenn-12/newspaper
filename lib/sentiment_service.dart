import 'dart:convert';
import 'package:http/http.dart' as http;

class SentimentService {
  final String _baseUrl = 'https://a333-34-80-34-48.ngrok-free.app';

  Future<Map<String, dynamic>> analyzeSentiment(String text) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/predict'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'text': text}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to analyze sentiment');
    }
  }
}
