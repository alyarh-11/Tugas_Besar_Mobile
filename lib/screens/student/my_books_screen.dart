import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class MyBooksScreen extends StatelessWidget {
  const MyBooksScreen({Key? key}) : super(key: key);

  // Mock data daftar buku yang dipinjam sesuai dengan referensi gambar Anda
  final List<Map<String, dynamic>> _borrowedBooks = const [
    {
      'title': 'The Psychology of Money',
      'author': 'Morgan Housel',
      'borrowDate': 'June 1, 2026',
      'daysLeft': 7,
      'coverColor': Color(0xFF00C4B6), // Hijau Toska
    },
    {
      'title': 'Atomic Habits',
      'author': 'James Clear',
      'borrowDate': 'May 28, 2026',
      'daysLeft': 3,
      'coverColor': Color(0xFF5B86FF), // Biru
    },
    {
      'title': '1984',
      'author': 'George Orwell',
      'borrowDate': 'May 25, 2026',
      'daysLeft': 1,
      'coverColor': Color(0xFFFF4B81), // Pink/Red
    },
    {
      'title': 'Pride and Prejudice',
      'author': 'Jane Austen',
      'borrowDate': 'May 20, 2026',
      'daysLeft': 10,
      'coverColor': Color(0xFFB066FF), // Ungu
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Latar belakang abu-abu sangat terang
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER TITLE & SUBTITLE ---
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 24.0, bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Borrowed Books',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_borrowedBooks.length} books active',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // --- LIST VIEW DAFTAR BUKU AKTIF ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                itemCount: _borrowedBooks.length,
                itemBuilder: (context, index) {
                  return _buildBorrowedBookItem(context, _borrowedBooks[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER UNTUK KARTU BUKU PINJAMAN ---
  Widget _buildBorrowedBookItem(BuildContext context, Map<String, dynamic> book) {
    int daysLeft = book['daysLeft'];
    
    // Penentuan skema warna chip sisa hari berdasarkan urgensi (Persis seperti gambar)
    Color chipBgColor;
    Color chipTextColor;
    
    if (daysLeft <= 1) {
      chipBgColor = const Color(0xFFFFEBEA);  // Merah pudar (Urgensi tinggi)
      chipTextColor = const Color(0xFFFF4B55);
    } else if (daysLeft <= 3) {
      chipBgColor = const Color(0xFFFFF0E6);  // Oranye pudar (Urgensi sedang)
      chipTextColor = const Color(0xFFFF9F43);
    } else {
      chipBgColor = const Color(0xFFE8EFFF);  // Biru pudar (Aman)
      chipTextColor = const Color(0xFF5B86FF);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row Atas: Sampul, Informasi Judul, Penulis, Tanggal, dan Chip Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kotak Sampul Buku
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: book['coverColor'],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Detail Teks Informasi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      book['author'],
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // Informasi Tanggal Peminjaman
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          book['borrowDate'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Chip Sisa Hari (Kondisional Warna)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: chipBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$daysLeft days left',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: chipTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Tombol Pengembalian Buku ("Return Book")
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton(
              onPressed: () {
                // Tambahkan fungsi pengembalian buku ke repositori/API Anda di sini
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE61F2B), // Warna merah solid sesuai referensi gambar
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Return Book',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}