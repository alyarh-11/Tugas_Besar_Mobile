import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../services/google_books_api.dart';
import '../../models/book_model.dart';
import '../../api_service.dart'; // <--- Hubungkan dengan ApiService Laragon kita

class GoogleBooksSearchScreen extends StatefulWidget {
  const GoogleBooksSearchScreen({super.key});

  @override
  State<GoogleBooksSearchScreen> createState() => _GoogleBooksSearchScreenState();
}

class _GoogleBooksSearchScreenState extends State<GoogleBooksSearchScreen> {
  final _searchController = TextEditingController();
  final _apiService = GoogleBooksApiService();
  List<BookModel> _searchResults = [];
  bool _isLoading = false;
  bool _isSaving = false; // <--- Indikator loading saat proses simpan ke MySQL

  void _executeSearch() async {
    if (_searchController.text.trim().isEmpty) return;
    
    setState(() => _isLoading = true);
    final results = await _apiService.searchBooks(_searchController.text);
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  // === FUNGSI ADAPTER: MENYIMPAN MODEL BUKU KE DATABASE LARAGON ===
  void _handleSaveBook(BookModel book) async {
    setState(() => _isSaving = true);

    // Kirim properti dari BookModel ke books.php di Laragon via HTTP POST
    // Jika di model kamu nama variabel ISBN berbeda, sesuaikan (misal: book.isbn)
    // Di sini kita asumsikan default parameter string jika field kosong
    String bookIsbn = 'No ISBN'; 

    var response = await ApiService.saveBookToLaragon(
      book.title,
      book.author,
      bookIsbn, // Mengirim data ke tabel books MySQL
    );

    setState(() => _isSaving = false);

    if (response['status'] == 'success') {
      // Jika database berhasil mencatat, tampilkan Dialog Sukses bawaan UI kamu
      _showSuccessDialog();
    } else {
      // Jika gagal (Laragon mati / IP berubah), infokan lewat SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Gagal menyimpan ke database lokal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth >= 1024 ? 4 : (screenWidth >= 768 ? 3 : 2);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Google Books API Search', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search books by title, author, isbn...',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    ),
                    onSubmitted: (_) => _executeSearch(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _executeSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Search', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue)))
                  : _searchResults.isEmpty
                      ? const Center(child: Text('No books found. Try another keyword.', style: TextStyle(color: AppColors.textSecondary)))
                      : GridView.builder(
                          itemCount: _searchResults.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.6,
                          ),
                          itemBuilder: (context, index) {
                            final book = _searchResults[index];
                            return _buildApiBookCard(book);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiBookCard(BookModel book) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(book.coverUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
                return const Center(child: Icon(Icons.broken_image, color: Colors.grey));
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(book.author, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // SEKARANG MANGGIL FUNGSI INTEGRASI LARAGON, BUKAN LANGSUNG DIALOG
                    onPressed: _isSaving ? null : () => _handleSaveBook(book),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: _isSaving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Add To Library', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Icon(Icons.check_circle, color: AppColors.successGreen, size: 48),
        content: const Text('Book Added Successfully', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.primaryBlue)),
          )
        ],
      ),
    );
  }
}