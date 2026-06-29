import 'package:flutter/material.dart';
import '../constants/colors.dart'; // Pastikan Anda sudah membuat AppColors

class BookGridWidget extends StatelessWidget {
  final List<dynamic> books; // List data buku dari Firestore/API

  const BookGridWidget({super.key, required this.books});

  // 1. Fungsi penentu kolom ditaruh di dalam kelas agar bisa diakses
  int _getResponsiveColumnCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1024) return 4; // Desktop
    if (width >= 768) return 3;  // Tablet
    return 2;                    // Mobile
  }

  @override
  Widget build(BuildContext context) {
    // 2. Gunakan LayoutBuilder atau MediaQuery langsung
    int crossAxisCount = _getResponsiveColumnCount(context);

    return GridView.builder(
      shrinkWrap: true, // Biar grid tidak makan memori berlebih
      physics: const ClampingScrollPhysics(), // Menghindari bentrokan scroll
      itemCount: books.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16, // Jarak antar kartu horizontal
        mainAxisSpacing: 16,  // Jarak antar kartu vertikal
        childAspectRatio: 0.7, // Rasio kartu (lebar / tinggi), sesuaikan agar tidak terpotong
      ),
      itemBuilder: (context, index) {
        final book = books[index];
        return BookCard(book: book);
      },
    );
  }
}

// 3. Komponen Kartu Buku Satuan (Dynamic Card)
class BookCard extends StatelessWidget {
  final dynamic book;

  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Sesuai prompt: Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Sesuai prompt: Soft shadows
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Sampul Buku
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                image: DecorationImage(
                  image: NetworkImage(book['cover_url'] ?? 'https://via.placeholder.com/150'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Info Buku (Judul & Author)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book['title'] ?? 'Unknown Title',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary, // Menggunakan warna kustom
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  book['author'] ?? 'Unknown Author',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}