import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  final String _apiKey = '4666294ef0534d51999cac4039a42f2f';
  final String _baseUrl = 'https://newsapi.org/v2';

  Future<List<dynamic>> fetchNews({int page = 1}) async {
    final response = await http.get(Uri.parse(
        '$_baseUrl/top-headlines?country=us&page=$page&apiKey=$_apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['articles'];
    } else {
      throw Exception('Failed to fetch news');
    }
  }
}
