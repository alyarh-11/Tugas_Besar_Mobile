import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class BorrowSuccessScreen extends StatelessWidget {
  const BorrowSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Latar belakang abu-abu sangat terang sesuai gambar
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Spacer atas agar posisi konten seimbang di tengah
              const Spacer(),

              // --- IKON SUKSES BESAR ---
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9), // Lingkaran luar hijau muda pudar
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2EC4B6).withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00B4D8), // Warna hijau/teal solid di bagian dalam
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // --- TEKS JUDUL SUKSES ---
              const Text(
                'Book Borrowed Successfully',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // --- SUBTITLE ---
              const Text(
                'Happy reading! Don\'t forget to return on time.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // --- KARTU DETAIL PEMINJAMAN ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withOpacity(0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Row Informasi Buku (Sampul, Judul, Author, Tag)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 84,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5B86FF), // Warna sampul sesuai gambar
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.menu_book_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'To Kill a Mockingbird',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'by Harper Lee',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Tag Status Peminjaman
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9), // Latar tag hijau muda
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.menu_book_rounded,
                                      color: Color(0xFF2EC4B6),
                                      size: 13,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Borrowed',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2EC4B6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Garis Pemisah Tipis (Divider)
                    Divider(color: Colors.grey.withOpacity(0.15), thickness: 1),
                    const SizedBox(height: 12),

                    // Baris Informasi Tanggal Pinjam
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                            SizedBox(width: 8),
                            Text('Borrowed On', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const Text('June 8, 2026', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Baris Informasi Tanggal Jatuh Tempo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.access_time_rounded, size: 16, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('Due Date', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const Text('June 22, 2026', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Banner Informasi Sisa Hari Kembalian
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF), // Latar belakang ungu/biru pudar
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          '14 days remaining to return',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4F46E5), // Teks warna indigo
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Spacer bawah agar posisi tombol pas berada di area bawah layar
              const Spacer(),

              // --- TOMBOL UTAMA (View My Books) ---
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    // Masukkan aksi untuk mengarahkan pengguna kembali atau menuju halaman profil peminjaman
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5), // Warna biru keunguan (Indigo) sesuai gambar tombol
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'View My Books',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Teks Petunjuk Keterangan di bawah Tombol Utama
              const Text(
                'You can manage your borrowed books in your profile',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}