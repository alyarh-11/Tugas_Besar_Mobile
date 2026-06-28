import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';

class GoogleBooksApiService {
  // === FUNGSI AMBIL DATA ASLI DARI GOOGLE BOOKS API ===
  Future<List<BookModel>> searchBooks(String query) async {
    if (query.trim().isEmpty) return [];

    final url = "https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeComponent(query)}";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['items'] ?? [];

        List<BookModel> results = [];
        for (var item in items) {
          // 1. Mengambil ID Unik Buku (Wajib)
          String id = item['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();

          final volumeInfo = item['volumeInfo'];
          if (volumeInfo == null) continue;

          String title = volumeInfo['title'] ?? 'Untitled Book';
          
          String author = 'Unknown Author';
          if (volumeInfo['authors'] != null && (volumeInfo['authors'] as List).isNotEmpty) {
            author = volumeInfo['authors'][0].toString();
          }

          String category = 'General';
          if (volumeInfo['categories'] != null && (volumeInfo['categories'] as List).isNotEmpty) {
            category = volumeInfo['categories'][0].toString();
          }

          String coverUrl = 'https://via.placeholder.com/150x220.png?text=No+Cover';
          if (volumeInfo['imageLinks'] != null) {
            coverUrl = volumeInfo['imageLinks']['thumbnail'] ?? volumeInfo['imageLinks']['smallThumbnail'] ?? coverUrl;
            if (coverUrl.startsWith('http://')) {
              coverUrl = coverUrl.replaceFirst('http://', 'https://');
            }
          }

          // ========================================================
          // PARSING TAMBAHAN UNTUK MEMENUHI 5 PARAMETER WAJIB BARU
          // ========================================================

          // 2. Publisher (Wajib)
          String publisher = volumeInfo['publisher'] ?? 'No Publisher';

          // 3. Year (Wajib) - Diambil dari substring data publishedDate (Format: YYYY-MM-DD)
          String year = 'Unknown Year';
          if (volumeInfo['publishedDate'] != null) {
            year = volumeInfo['publishedDate'].toString().split('-')[0];
          }

          // 4. ISBN (Wajib) - Mencari tipe ISBN_13 atau ISBN_10 di dalam list industryIdentifiers
          String isbn = 'No ISBN';
          if (volumeInfo['industryIdentifiers'] != null) {
            var ids = volumeInfo['industryIdentifiers'] as List;
            if (ids.isNotEmpty) {
              isbn = ids[0]['identifier'] ?? 'No ISBN';
            }
          }

          // 5. Summary / Deskripsi Singkat Buku (Wajib)
          String summary = volumeInfo['description'] ?? 'No description available for this book.';

          // 6. Status Buku (Wajib) - Kita set default 'Available' karena ini buku baru yang dicari
          String status = 'Available';

          // === MEMASUKKAN SELURUH DATA KE MODEL TANPA ADA YANG KETINGGALAN ===
          results.add(BookModel(
            id: id,
            title: title,
            author: author,
            category: category,
            coverUrl: coverUrl,
            publisher: publisher, // <--- Ditambahkan sesuai log error
            year: year,           // <--- Ditambahkan sesuai log error
            isbn: isbn,           // <--- Ditambahkan sesuai log error
            summary: summary,     // <--- Ditambahkan sesuai log error
            status: status,       // <--- Ditambahkan sesuai log error
          ));
        }

        return results;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}