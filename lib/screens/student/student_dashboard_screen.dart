import 'package:flutter/material.dart';
import 'catalog_screen.dart';
import 'student_profile_screen.dart';
import 'borrowing_history_screen.dart'; 

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _currentIndex = 0;
  bool _showBorrowedBooksSubPage = false;

  final List<Map<String, dynamic>> _activeLoans = [
    {
      'title': 'The Psychology of Money',
      'author': 'Morgan Housel',
      'borrowedDate': 'June 1, 2026',
      'dueDate': 'June 8, 2026',
      'daysLeft': '7 days left',
      'iconColor': const Color(0xFF00C4B4),
    },
    {
      'title': 'Atomic Habits',
      'author': 'James Clear',
      'borrowedDate': 'May 28, 2026',
      'dueDate': 'June 4, 2026',
      'daysLeft': '3 days left',
      'iconColor': const Color(0xFF5B86FF),
    },
    {
      'title': '1984',
      'author': 'George Orwell',
      'borrowedDate': 'May 25, 2026',
      'dueDate': 'June 1, 2026',
      'daysLeft': '1 day left',
      'iconColor': const Color(0xFFFF4B72),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _showBorrowedBooksSubPage ? _buildBorrowedBooksPage() : _buildMainHomeTab(),
      const CatalogScreen(),
      const StudentProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2563EB),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              if (index != 0) {
                _showBorrowedBooksSubPage = false;
              }
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Catalog'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // DASHBOARD HOME UTAMA (SUDAH FULL WIDTH TIDAK DIBATASI 600)
  // =========================================================================
  Widget _buildMainHomeTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: const Text(
                        'KI',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back,', style: TextStyle(color: Color(0xFF93C5FD), fontSize: 13)),
                          SizedBox(height: 2),
                          Text('Karina Ismaya', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(child: _buildStatCard('3', 'Active Borrowed', Icons.bookmark_outline, const Color(0xFF10B981))),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard('1247', 'Available Books', Icons.menu_book_rounded, const Color(0xFF3B82F6))),
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Library Overview', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF6366F1)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Digital Library', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Explore thousands of books at your fingertips', style: TextStyle(color: Color(0xFFE0E7FF), fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text('Quick Access', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildQuickAccessItem('Browse Books', Icons.search_rounded, const Color(0xFFEFF6FF), const Color(0xFF3B82F6), () {
                        setState(() => _currentIndex = 1);
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAccessItem('My Borrowed\nBooks', Icons.bookmark_rounded, const Color(0xFFECFDF5), const Color(0xFF10B981), () {
                        setState(() => _showBorrowedBooksSubPage = true);
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAccessItem('Borrowing History', Icons.history_rounded, const Color(0xFFF5F3FF), const Color(0xFF8B5CF6), () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BorrowingHistoryScreen()),
                        );
                      }),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 14, backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 14)),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildQuickAccessItem(String title, IconData icon, Color bg, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 20, backgroundColor: bg, child: Icon(icon, color: iconColor, size: 18)),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155), height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // LIST BUKU PINJAMAN SUB-PAGE (SUDAH FULL WIDTH MENGIKUTI UKURAN LAYAR)
  // =========================================================================
  Widget _buildBorrowedBooksPage() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => setState(() => _showBorrowedBooksSubPage = false),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Borrowed Books', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 4),
            Text('${_activeLoans.length} books active', style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _activeLoans.length,
              itemBuilder: (context, index) {
                final book = _activeLoans[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(color: book['iconColor'], borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(book['title'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text(book['author'], style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFF94A3B8)),
                                    const SizedBox(width: 6),
                                    Text(book['borrowedDate'], style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: (book['daysLeft'] as String).contains('1') ? const Color(0xFFFFECEF) : const Color(0xFFEBF2FF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    book['daysLeft'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: (book['daysLeft'] as String).contains('1') ? const Color(0xFFFF4B72) : const Color(0xFF1A68FF),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReturnConfirmationScreen(
                                  bookTitle: book['title'],
                                  bookAuthor: book['author'],
                                  borrowedDate: book['borrowedDate'],
                                  bookIconColor: book['iconColor'],
                                ),
                              ),
                            );
                          },
                          child: const Text('Return Book', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// RETURN CONFIRMATION SCREEN (DIBATASI 420 AGAR BERBENTUK DIALOG TENGAH)
// =========================================================================
class ReturnConfirmationScreen extends StatelessWidget {
  final String bookTitle;
  final String bookAuthor;
  final String borrowedDate;
  final Color bookIconColor;

  const ReturnConfirmationScreen({
    super.key,
    required this.bookTitle,
    required this.bookAuthor,
    required this.borrowedDate,
    required this.bookIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: const BoxDecoration(color: Color(0xFFEBF2FF), shape: BoxShape.circle),
                      child: const Icon(Icons.menu_book_rounded, color: Color(0xFF1A68FF), size: 48),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Book Returned Successfully',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Kamu telah berhasil mengembalikan buku "$bookTitle". Terima kasih!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to My Books', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}