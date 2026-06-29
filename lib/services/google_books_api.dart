import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

class GoogleBooksApiService {
  Future<List<BookModel>> searchBooks(String query) async {
    if (query.trim().isEmpty) return [];

    final url = Uri.parse(
      "https://openlibrary.org/search.json?q=${Uri.encodeComponent(query)}",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        return [];
      }

      final data = jsonDecode(response.body);

      final List docs = data["docs"] ?? [];

      return docs.map((e) => BookModel.fromOpenLibrary(e)).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }
}