import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api_service.dart';

class BorrowingHistoryScreen extends StatefulWidget {
  const BorrowingHistoryScreen({super.key});

  @override
  State<BorrowingHistoryScreen> createState() => _BorrowingHistoryScreenState();
}

class _BorrowingHistoryScreenState extends State<BorrowingHistoryScreen> {
  List<Map<String, dynamic>> _historyData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    if (userId.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final loans = await ApiService.getStudentLoans(userId);
      if (!mounted) return;
      setState(() {
        _historyData = List<Map<String, dynamic>>.from(loans);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int get _totalBooks => _historyData.length;
  int get _returnedCount => _historyData.where((l) => l['status'] == 'returned').length;
  int get _activeCount => _historyData.where((l) => l['status'] == 'active').length;
  int get _overdueCount => _historyData.where((l) => l['status'] == 'overdue').length;

  Color _getIconColor(int index) {
    final colors = [
      const Color(0xFF00C49F),
      const Color(0xFF4F46E5),
      const Color(0xFFD63384),
      const Color(0xFFFF6B35),
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Borrowing History',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 2),
            Text(
              '$_totalBooks total records',
              style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF3B82F6)),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchHistory();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
          : _historyData.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('No borrowing history yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      const SizedBox(height: 8),
                      const Text('Start browsing the catalog to borrow books!', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 10),
                        itemCount: _historyData.length,
                        itemBuilder: (context, index) {
                          final item = _historyData[index];
                          final status = (item['status'] ?? 'active').toString().toLowerCase();
                          final bool isOverdue = status == 'overdue';
                          final bool isActive = status == 'active';
                          final bool isReturned = status == 'returned';
                          final bool isLast = index == _historyData.length - 1;

                          final String borrowDate = item['borrow_date'] ?? '-';
                          final String dueDate = item['due_date'] ?? '-';
                          final String returnDate = item['return_date'] ?? '-';

                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: isOverdue
                                            ? const Color(0xFFFFEBEA)
                                            : isActive
                                                ? const Color(0xFFFFF3E0)
                                                : const Color(0xFFE8F5E9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          isOverdue
                                              ? Icons.access_time_filled_rounded
                                              : isActive
                                                  ? Icons.menu_book_rounded
                                                  : Icons.check_circle_rounded,
                                          color: isOverdue
                                              ? const Color(0xFFFF4B55)
                                              : isActive
                                                  ? const Color(0xFFFF9800)
                                                  : const Color(0xFF00C49F),
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                    if (!isLast)
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          color: Colors.grey.withOpacity(0.2),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 20.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.grey.withOpacity(0.12)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.01),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          )
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 44,
                                                height: 44,
                                                decoration: BoxDecoration(
                                                  color: _getIconColor(index),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 20),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item['title'] ?? 'Unknown Book',
                                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      item['author'] ?? 'Unknown Author',
                                                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 14),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text('Borrowed', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                              Text(borrowDate, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500)),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(isReturned ? 'Returned' : 'Due Date', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                              Text(isReturned ? returnDate : dueDate, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500)),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isOverdue
                                                  ? const Color(0xFFFFEBEA)
                                                  : isActive
                                                      ? const Color(0xFFFFF3E0)
                                                      : const Color(0xFFE8F5E9),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isOverdue
                                                    ? const Color(0xFFFF4B55).withOpacity(0.2)
                                                    : isActive
                                                        ? const Color(0xFFFF9800).withOpacity(0.2)
                                                        : const Color(0xFF00C49F).withOpacity(0.2),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  isOverdue
                                                      ? Icons.access_time_rounded
                                                      : isActive
                                                          ? Icons.menu_book_rounded
                                                          : Icons.check_circle_outline_rounded,
                                                  size: 14,
                                                  color: isOverdue
                                                      ? const Color(0xFFFF4B55)
                                                      : isActive
                                                          ? const Color(0xFFFF9800)
                                                          : const Color(0xFF00C49F),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  isActive ? 'Active' : isReturned ? 'Returned' : 'Overdue',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: isOverdue
                                                        ? const Color(0xFFFF4B55)
                                                        : isActive
                                                            ? const Color(0xFFFF9800)
                                                            : const Color(0xFF00C49F),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, -3),
                          )
                        ],
                      ),
                      child: SafeArea(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryItem(value: _totalBooks.toString(), label: 'Total Books', valueColor: Colors.black87),
                            _buildSummaryItem(value: _returnedCount.toString(), label: 'Returned', valueColor: const Color(0xFF00C49F)),
                            _buildSummaryItem(value: _activeCount.toString(), label: 'Active', valueColor: const Color(0xFFFF9800)),
                            _buildSummaryItem(value: _overdueCount.toString(), label: 'Overdue', valueColor: const Color(0xFFFF4B55)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSummaryItem({required String value, required String label, required Color valueColor}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: valueColor),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}