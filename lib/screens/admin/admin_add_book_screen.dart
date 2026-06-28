import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../api_service.dart';

class AdminAddBookScreen extends StatefulWidget {
  const AdminAddBookScreen({super.key});

  @override
  State<AdminAddBookScreen> createState() => _AdminAddBookScreenState();
}

class _AdminAddBookScreenState extends State<AdminAddBookScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _googleBooksResult = [];
  bool _isLoadingSearch = false;
  bool _isLoadingSave = false;

  // === 1. FUNGSI FETCH DATA GOOGLE BOOKS API (Sesuai Slide 8) ===
  void _searchBook() async {
    String query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ketik judul buku terlebih dahulu!')),
      );
      return;
    }

    setState(() {
      _isLoadingSearch = true;
      _googleBooksResult = [];
    });

    // Menembak Google Books API publik
    var results = await ApiService.searchGoogleBooks(query);

    setState(() {
      _googleBooksResult = results;
      _isLoadingSearch = false;
    });
  }

  // === 2. FUNGSI SIKLUS CRUD: CREATE KE LARAGON (Sesuai Slide 9) ===
  void _saveBook(Map<String, dynamic>? volumeInfo) async {
    if (volumeInfo == null) return;

    setState(() {
      _isLoadingSave = true;
    });

    // Validasi Null-Safety agar tidak Crash jika data Google kosong (Slide 8 & 10)
    String title = volumeInfo['title'] ?? 'Judul Tidak Diketahui';
    
    String author = 'Penulis Tidak Diketahui';
    if (volumeInfo['authors'] != null && (volumeInfo['authors'] as List).isNotEmpty) {
      author = volumeInfo['authors'][0].toString();
    }

    String isbn = 'Tanpa ISBN';
    if (volumeInfo['industryIdentifiers'] != null) {
      var identifiers = volumeInfo['industryIdentifiers'] as List;
      if (identifiers.isNotEmpty) {
        isbn = identifiers[0]['identifier'] ?? 'Tanpa ISBN';
      }
    }

    // Mengirim HTTP POST ke books.php di Laragon (Slide 9)
    var response = await ApiService.saveBookToLaragon(title, author, isbn);

    setState(() {
      _isLoadingSave = false;
    });

    // Menampilkan notifikasi SnackBar Berhasil/Gagal (Slide 10)
    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message']), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message']), backgroundColor: Colors.red),
      );
    }
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
        title: const Text('Tambah Buku Via Google API', style: TextStyle(color: Colors.white)),
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
                          Text('Menghubungkan ke Google Books API...'),
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
                                  onPressed: _isLoadingSave ? null : () => _saveBook(volumeInfo),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Simpan', style: TextStyle(color: Colors.white)),
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