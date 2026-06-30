import 'package:flutter/material.dart';
import '../../api_service.dart';
import '../../models/book_model.dart';
import '../../constants/colors.dart';

class AdminViewReportsScreen extends StatefulWidget {
  const AdminViewReportsScreen({super.key});

  @override
  State<AdminViewReportsScreen> createState() => _AdminViewReportsScreenState();
}

class _AdminViewReportsScreenState extends State<AdminViewReportsScreen> {
  bool _isLoading = false;
  List<BookModel> _allBooks = [];
  int _totalUsers = 0;
  int _adminCount = 0;
  int _studentCount = 0;

  // Derived stats
  int get _totalBooks => _allBooks.length;
  int get _availableBooks => _allBooks.where((b) => b.status.toLowerCase() == 'available').length;
  int get _borrowedBooks => _allBooks.where((b) => b.status.toLowerCase() == 'borrowed').length;
  int get _overdueBooks => _allBooks.where((b) => b.status.toLowerCase() == 'overdue').length;

  // Books by category
  Map<String, int> get _categoryMap {
    final map = <String, int>{};
    for (final b in _allBooks) {
      map[b.category] = (map[b.category] ?? 0) + 1;
    }
    final sorted = Map.fromEntries(map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
    return sorted;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final books = await ApiService.getBooks();
      final users = await ApiService.getUsers();
      if (mounted) {
        setState(() {
          _allBooks = books;
          _totalUsers = (users['total'] ?? 0) as int;
          
          final userList = users['users'] as List<dynamic>? ?? [];
          _adminCount = userList.where((u) => u['role'].toString().toLowerCase() == 'admin').length;
          _studentCount = userList.where((u) => u['role'].toString().toLowerCase() == 'student').length;
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Laporan Perpustakaan',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryBlue),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primaryBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- SUMMARY CARDS ---
                    const Text('Ringkasan Koleksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 14),

                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.5,
                      children: [
                        _buildSummaryCard('Total Buku', _totalBooks.toString(), Icons.library_books_rounded, const Color(0xFF3B82F6), const Color(0xFFEFF6FF)),
                        _buildSummaryCard('Tersedia', _availableBooks.toString(), Icons.check_circle_outline_rounded, const Color(0xFF10B981), const Color(0xFFECFDF5)),
                        _buildSummaryCard('Dipinjam', _borrowedBooks.toString(), Icons.bookmark_rounded, const Color(0xFFF59E0B), const Color(0xFFFFFBEB)),
                        _buildSummaryCard('Terlambat', _overdueBooks.toString(), Icons.warning_rounded, const Color(0xFFEF4444), const Color(0xFFFEF2F2)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- USER INFO ---
                    _buildSection(
                      icon: Icons.group_rounded,
                      iconBg: const Color(0xFFF3F0FF),
                      iconColor: const Color(0xFF8B5CF6),
                      title: 'Anggota Sistem',
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(children: [
                          Expanded(child: _buildMiniStat('Total Akun', _totalUsers.toString(), const Color(0xFF8B5CF6))),
                          Container(width: 1, height: 40, color: const Color(0xFFF1F5F9)),
                          Expanded(child: _buildMiniStat('Student', _studentCount.toString(), const Color(0xFF3B82F6))),
                          Container(width: 1, height: 40, color: const Color(0xFFF1F5F9)),
                          Expanded(child: _buildMiniStat('Admin', _adminCount.toString(), const Color(0xFF10B981))),
                        ]),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // --- STATUS BREAKDOWN BAR ---
                    _buildSection(
                      icon: Icons.bar_chart_rounded,
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: AppColors.primaryBlue,
                      title: 'Status Buku',
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        child: Column(children: [
                          _buildStatusBar('Tersedia', _availableBooks, _totalBooks, const Color(0xFF10B981)),
                          const SizedBox(height: 12),
                          _buildStatusBar('Dipinjam', _borrowedBooks, _totalBooks, const Color(0xFFF59E0B)),
                          const SizedBox(height: 12),
                          _buildStatusBar('Terlambat', _overdueBooks, _totalBooks, const Color(0xFFEF4444)),
                        ]),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // --- KATEGORI BUKU ---
                    _buildSection(
                      icon: Icons.category_rounded,
                      iconBg: const Color(0xFFFFFBEB),
                      iconColor: const Color(0xFFF59E0B),
                      title: 'Buku per Kategori',
                      child: _categoryMap.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: Text('Belum ada data kategori', style: TextStyle(color: AppColors.textSecondary))),
                            )
                          : Column(
                              children: _categoryMap.entries.take(8).map((entry) {
                                final percent = _totalBooks > 0 ? entry.value / _totalBooks : 0.0;
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: const BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                                  ),
                                  child: Row(children: [
                                    Expanded(
                                      child: Text(entry.key, maxLines: 1, overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 100,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: percent,
                                          backgroundColor: const Color(0xFFF1F5F9),
                                          color: AppColors.primaryBlue,
                                          minHeight: 6,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 28,
                                      child: Text(
                                        entry.value.toString(),
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      ),
                                    ),
                                  ]),
                                );
                              }).toList(),
                            ),
                    ),

                    const SizedBox(height: 16),

                    // --- DAFTAR BUKU OVERDUE ---
                    if (_overdueBooks > 0) ...[
                      _buildSection(
                        icon: Icons.schedule_rounded,
                        iconBg: const Color(0xFFFEF2F2),
                        iconColor: const Color(0xFFEF4444),
                        title: 'Buku Terlambat (${_overdueBooks})',
                        child: Column(
                          children: _allBooks
                              .where((b) => b.status.toLowerCase() == 'overdue')
                              .map((book) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: const BoxDecoration(
                                      border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                                    ),
                                    child: Row(children: [
                                      Container(
                                        width: 36, height: 36,
                                        decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8)),
                                        child: const Icon(Icons.book_outlined, color: Color(0xFFEF4444), size: 18),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                        Text(book.author, maxLines: 1, overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                      ])),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(8)),
                                        child: const Text('Terlambat', style: TextStyle(fontSize: 10, color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                                      ),
                                    ]),
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ]),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ]),
        ),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
        child,
      ]),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    ]);
  }

  Widget _buildStatusBar(String label, int count, int total, Color color) {
    final pct = total > 0 ? count / total : 0.0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
        Text('$count buku', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: pct,
          backgroundColor: const Color(0xFFF1F5F9),
          color: color,
          minHeight: 8,
        ),
      ),
    ]);
  }
}
