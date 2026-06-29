import 'package:flutter/material.dart';

class BorrowingHistoryScreen extends StatelessWidget {
  const BorrowingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> historyData = [
      {
        'title': 'The Psychology of Money',
        'author': 'Morgan Housel',
        'borrowed': 'May 15, 2026',
        'returned': 'May 29, 2026',
        'status': 'Returned',
        'iconColor': const Color(0xFF00C49F),
      },
      {
        'title': 'Atomic Habits',
        'author': 'James Clear',
        'borrowed': 'May 1, 2026',
        'returned': 'May 14, 2026',
        'status': 'Returned',
        'iconColor': const Color(0xFF4F46E5),
      },
      {
        'title': 'Thinking, Fast and Slow',
        'author': 'Daniel Kahneman',
        'borrowed': 'Apr 18, 2026',
        'returned': 'May 2, 2026',
        'status': 'Returned',
        'iconColor': const Color(0xFFD63384),
      },
      {
        'title': 'The Lean Startup',
        'author': 'Eric Ries',
        'borrowed': 'Apr 3, 2026',
        'returned': 'Apr 20, 2026',
        'status': 'Overdue',
        'iconColor': const Color(0xFFFF6B35),
      },
    ];

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
              '${historyData.length} total records',
              style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 10),
              itemCount: historyData.length,
              itemBuilder: (context, index) {
                final item = historyData[index];
                final bool isOverdue = item['status'] == 'Overdue';
                final bool isLast = index == historyData.length - 1;

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
                              color: isOverdue ? const Color(0xFFFFEBEA) : const Color(0xFFE8F5E9),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                isOverdue ? Icons.access_time_filled_rounded : Icons.check_circle_rounded,
                                color: isOverdue ? const Color(0xFFFF4B55) : const Color(0xFF00C49F),
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
                                        color: item['iconColor'],
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
                                            item['title'],
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            item['author'],
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
                                    Text(item['borrowed'], style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Returned', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    Text(item['returned'], style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isOverdue ? const Color(0xFFFFEBEA) : const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isOverdue ? const Color(0xFFFF4B55).withOpacity(0.2) : const Color(0xFF00C49F).withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isOverdue ? Icons.access_time_rounded : Icons.check_circle_outline_rounded,
                                        size: 14,
                                        color: isOverdue ? const Color(0xFFFF4B55) : const Color(0xFF00C49F),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item['status'],
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isOverdue ? const Color(0xFFFF4B55) : const Color(0xFF00C49F),
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
                  _buildSummaryItem(value: '12', label: 'Total Books', valueColor: Colors.black87),
                  _buildSummaryItem(value: '11', label: 'Returned', valueColor: const Color(0xFF00C49F)),
                  _buildSummaryItem(value: '1', label: 'Overdue', valueColor: const Color(0xFFFF4B55)),
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