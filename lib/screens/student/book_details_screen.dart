import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'borrow_success_screen.dart'; // Import halaman sukses agar bisa berpindah halaman
import '../../models/book_model.dart';
import '../../api_service.dart';

class BookDetailsScreen extends StatelessWidget {

  final BookModel book;

  const BookDetailsScreen({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Latar belakang abu-abu sangat terang sesuai gambar
      
      // --- APP BAR (Tombol Kembali & Judul) ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman katalog sebelumnya
          },
        ),
        title: const Text(
          'Book Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      body: SafeArea(
        child: Column(
          children: [
            // Konten atas dibungkus Expanded + SingleChildScrollView agar aman dari overflow di layar kecil
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- SAMPUL BUKU ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        book.coverUrl,
                        width: 160,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 160,
                            height: 220,
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.menu_book,
                              size: 60,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- JUDUL BUKU ---
                    Text(
                      book.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),

                    // --- NAMA PENULIS ---
                    Text(
                      book.author,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                      Text(
                        "${book.publisher} • ${book.year}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "ISBN : ${book.isbn}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    const SizedBox(height: 16),

                    // --- CHIPS ROW (Kategori & Status) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Chip Kategori (Finance & Business)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EFFF), // Biru sangat muda pudar
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: 
                          Text(
                            book.category,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF5B86FF), // Menggunakan warna senada sampul
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        
                        // Chip Status Ketersediaan (Available)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: book.status.toLowerCase() == "available"
                                ? const Color(0xFFE8F5E9)
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              CircleAvatar(
                                radius: 3,
                                backgroundColor:
                                    book.status.toLowerCase() == "available"
                                        ? const Color(0xFF2EC4B6)
                                        : Colors.red,
                              ),

                              const SizedBox(width: 6),

                              Text(
                                book.status,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: book.status.toLowerCase() == "available"
                                      ? const Color(0xFF2EC4B6)
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- KOTAK SUMMARY (Ringkasan) ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withOpacity(0.12)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Summary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            book.summary,
                            style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.5, // Mengatur tinggi baris teks rangkuman agar mudah dibaca
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- BANNER PERIODE PINJAMAN ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF), // Latar belakang biru keunguan muda
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          '📚 14-day borrow period  •  No late fees',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4F46E5), // Warna teks indigo indigo
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- BOTTOM STATIONARY BUTTON (Tetap terkunci di bawah layar) ---
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                 onPressed: book.status.toLowerCase() != "available"
                  ? null
                  : () async {
                      // 1. Get User ID
                      final prefs = await SharedPreferences.getInstance();
                      final userId = prefs.getString('user_id') ?? '1';

                      // 2. Tampilkan loading dialog atau SnackBar indicator
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing borrow request...')),
                      );

                      // 3. Call API
                      final result = await ApiService.borrowBook(userId, book.id);
                      
                      if (!context.mounted) return;
                      
                      if (result['status'] == 'success') {
                        // AKSI NAVIGASI: Mengganti halaman detail langsung dengan halaman Sukses Pinjam
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BorrowSuccessScreen(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result['message'] ?? 'Failed to borrow book'), backgroundColor: Colors.red),
                        );
                      }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B4D8), // Warna hijau/teal tombol utama sesuai gambar
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 20),
                  label: const Text(
                    'Borrow This Book',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}