import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import 'book_details_screen.dart'; // Import halaman detail buku agar bisa pindah halaman

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({Key? key}) : super(key: key);

  // Mock data buku yang disesuaikan persis dengan gambar referensi Anda
  final List<Map<String, dynamic>> _books = const [
    {
      'title': 'The Great Gatsby',
      'author': 'F. Scott Fitzgerald',
      'coverColor': Color(0xFFFF9F00), // Orange
      'isAvailable': true,
    },
    {
      'title': 'To Kill a Mockingbird',
      'author': 'Harper Lee',
      'coverColor': Color(0xFF5B86FF), // Blue/Purple
      'isAvailable': false,
    },
    {
      'title': '1984',
      'author': 'George Orwell',
      'coverColor': Color(0xFFFF4B81), // Pink/Red
      'isAvailable': true,
    },
    {
      'title': 'Pride and Prejudice',
      'author': 'Jane Austen',
      'coverColor': Color(0xFFB066FF), // Light Purple
      'isAvailable': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Menggunakan warna background dari konstanta proyekmu
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER TITLE ---
            const Padding(
              padding: EdgeInsets.only(left: 20.0, top: 20.0, bottom: 12.0),
              child: Text(
                'Catalog',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // --- SEARCH BAR ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search books or authors...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // --- SUBTITLE ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Curated by Admin',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // --- GRID VIEW DAFTAR BUKU ---
            Expanded(
              child: GridView.builder(
                // Menggunakan EdgeInsets.only untuk menghindari error parameter 'bottom'
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                itemCount: _books.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,         // Menampilkan 2 kolom ke samping
                  childAspectRatio: 0.62,    // Rasio proporsional tinggi & lebar card agar tidak overflow
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  return _buildBookGridItem(context, _books[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER UNTUK ITEM CARD BUKU ---
  Widget _buildBookGridItem(BuildContext context, Map<String, dynamic> book) {
    bool isAvailable = book['isAvailable'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Sampul Buku (Warna Solid + Icon Buku)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: book['coverColor'],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Judul Buku
          Text(
            book['title'],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // Nama Penulis
          Text(
            book['author'],
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Label Status (Available / Unavailable)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isAvailable 
                  ? const Color(0xFFE8F5E9) // Hijau muda jika tersedia
                  : const Color(0xFFF1F3F5), // Abu-abu jika habis
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 3,
                  backgroundColor: isAvailable 
                      ? const Color(0xFF2EC4B6) // Titik Hijau
                      : Colors.grey,            // Titik Abu-abu
                ),
                const SizedBox(width: 6),
                Text(
                  isAvailable ? 'Available' : 'Unavailable',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isAvailable ? const Color(0xFF2EC4B6) : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Tombol Aksi (Borrow / Not Available)
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: isAvailable 
                  ? () {
                      // AKSI NAVIGASI: Pindah ke halaman BookDetailsScreen jika buku tersedia
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BookDetailsScreen(),
                        ),
                      );
                    } 
                  : null, // Jika dinonaktifkan (null), tombol otomatis terkunci bawaan Flutter
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B4D8), // Warna biru teal tombol 'Borrow' asli sesuai gambar
                disabledBackgroundColor: const Color(0xFFE9ECEF), // Warna abu pudar 'Not Available'
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isAvailable ? 'Borrow' : 'Not Available',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isAvailable ? Colors.white : Colors.black38,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}