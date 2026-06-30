import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../api_service.dart';
import '../../models/book_model.dart';

class AdminAddBookScreen extends StatefulWidget {
  const AdminAddBookScreen({super.key});

  @override
  State<AdminAddBookScreen> createState() =>
      _AdminAddBookScreenState();
}

class _AdminAddBookScreenState
    extends State<AdminAddBookScreen> {

  final _searchController = TextEditingController();

  List<dynamic> _googleBooksResult = [];

  bool _isLoadingSearch = false;
  bool _isLoadingSave = false;

  void _searchBook() async {
    String query = _searchController.text.trim();

    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ketik judul buku terlebih dahulu!"),
        ),
      );
      return;
    }

    setState(() {
      _isLoadingSearch = true;
      _googleBooksResult = [];
    });

    final results =
        await ApiService.searchGoogleBooks(query);

    if (!mounted) return;

    setState(() {
      _googleBooksResult = results;
      _isLoadingSearch = false;
    });
  }

    void _saveBook(Map<String, dynamic>? volumeInfo) async {
      if (volumeInfo == null) return;

      setState(() {
        _isLoadingSave = true;
      });

      // ===========================
      // Author
      // ===========================
      String author = "Unknown Author";

      if (volumeInfo["authors"] != null &&
          (volumeInfo["authors"] as List).isNotEmpty) {
        author = volumeInfo["authors"][0].toString();
      }

      // ===========================
      // Category
      // ===========================
      String category = "General";

      if (volumeInfo["categories"] != null &&
          (volumeInfo["categories"] as List).isNotEmpty) {
        category = volumeInfo["categories"][0].toString();
      }

      // ===========================
      // ISBN
      // ===========================
      String isbn = "";

      if (volumeInfo["industryIdentifiers"] != null) {
        List ids = volumeInfo["industryIdentifiers"];

        if (ids.isNotEmpty) {
          isbn = ids[0]["identifier"] ?? "";
        }
      }

      // ===========================
      // Cover
      // ===========================
      String cover =
          "https://via.placeholder.com/150x220.png?text=No+Cover";

      if (volumeInfo["imageLinks"] != null) {
        cover =
            volumeInfo["imageLinks"]["thumbnail"] ??
            volumeInfo["imageLinks"]["smallThumbnail"] ??
            cover;

        if (cover.startsWith("http://")) {
          cover = cover.replaceFirst("http://", "https://");
        }
      }

      // ===========================
      // Publisher
      // ===========================
      String publisher =
          volumeInfo["publisher"] ?? "";

      // ===========================
      // Year
      // ===========================
      String year = "";

      if (volumeInfo["publishedDate"] != null) {
        year = volumeInfo["publishedDate"]
            .toString()
            .split("-")[0];
      }

      // ===========================
      // Summary
      // ===========================
      String summary =
          volumeInfo["description"] ??
          "No description available.";

      // ===========================
      // Buat Object BookModel
      // ===========================
      BookModel book = BookModel(
        id: "",
        title: volumeInfo["title"] ?? "",
        author: author,
        category: category,
        coverUrl: cover,
        publisher: publisher,
        year: year,
        isbn: isbn,
        summary: summary,
        status: "Available",
      );

      final response =
          await ApiService.saveBookToLaragon(book);

      if (!mounted) return;

      setState(() {
        _isLoadingSave = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"]),
          backgroundColor:
              response["status"] == "success"
                  ? Colors.green
                  : Colors.red,
        ),
      );
    }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Buku Via API Library', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form Kolom Pencarian (Slide 10)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Ketik judul buku (misal: Laskar Pelangi)...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onSubmitted: (_) => _searchBook(), // Bisa cari lewat tombol enter keyboard HP
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoadingSearch ? null : _searchBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoadingSearch
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Tampilan Hasil List Menggunakan ListView.builder (Slide 9)
            Expanded(
              child: _isLoadingSearch
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text('Menghubungkan ke API Library...'),
                        ],
                      ),
                    )
                  : _googleBooksResult.isEmpty
                      ? const Center(child: Text('Belum ada hasil pencarian. Coba ketik judul buku.'))
                      : ListView.builder(
                          itemCount: _googleBooksResult.length,
                          itemBuilder: (context, index) {
                            var book = _googleBooksResult[index];
                            var volumeInfo = book['volumeInfo'];
                            
                            // Ambil data untuk UI dengan proteksi nilai null
                            String displayTitle = volumeInfo?['title'] ?? 'No Title';
                            
                            String displayAuthor = 'Unknown Author';
                            if (volumeInfo?['authors'] != null && (volumeInfo['authors'] as List).isNotEmpty) {
                              displayAuthor = volumeInfo['authors'][0].toString();
                            }

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: const Icon(Icons.book, color: AppColors.primaryBlue, size: 40),
                                title: Text(displayTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Penulis: $displayAuthor'),
                                trailing: ElevatedButton(
                                  onPressed: _isLoadingSave
                                      ? null
                                      : () {
                                          _saveBook(volumeInfo);
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: _isLoadingSave
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          "Simpan",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}