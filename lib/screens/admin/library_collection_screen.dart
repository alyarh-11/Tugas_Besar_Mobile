import 'package:flutter/material.dart';
import '../../api_service.dart';
import '../../models/book_model.dart';
import '../../constants/colors.dart';
import 'book_detail_and_form.dart';

class AdminLibraryCollectionScreen extends StatefulWidget {
  final String initialStatus;

  const AdminLibraryCollectionScreen({
    super.key,
    this.initialStatus = 'All',
  });

  @override
  State<AdminLibraryCollectionScreen> createState() => _AdminLibraryCollectionScreenState();
}

class _AdminLibraryCollectionScreenState extends State<AdminLibraryCollectionScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  List<BookModel> _allBooks = [];
  List<BookModel> _filteredBooks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialStatus;
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final books = await ApiService.getBooks();
      if (mounted) {
        setState(() {
          _allBooks = books;
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading library books: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    
    setState(() {
      _filteredBooks = _allBooks.where((book) {
        // 1. Status Filter
        bool matchesStatus = true;
        if (_selectedFilter != 'All') {
          matchesStatus = book.status.toLowerCase() == _selectedFilter.toLowerCase();
        }

        // 2. Search Query Filter
        bool matchesQuery = true;
        if (query.isNotEmpty) {
          matchesQuery = book.title.toLowerCase().contains(query) ||
                         book.author.toLowerCase().contains(query) ||
                         book.category.toLowerCase().contains(query) ||
                         book.isbn.toLowerCase().contains(query);
        }

        return matchesStatus && matchesQuery;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Koleksi Perpustakaan',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryBlue),
            onPressed: _loadBooks,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Pencarian & Filter Status
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                // Input Pencarian
                TextField(
                  controller: _searchController,
                  onChanged: (_) => _applyFilters(),
                  decoration: InputDecoration(
                    hintText: 'Cari berdasarkan judul, penulis, isbn...',
                    hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilters();
                            },
                          )
                        : null,
                    fillColor: AppColors.background,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Horizontal Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'Semua'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Available', 'Tersedia'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Borrowed', 'Dipinjam'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Overdue', 'Terlambat'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Daftar Buku
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBlue,
                    ),
                  )
                : _filteredBooks.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredBooks.length,
                        itemBuilder: (context, index) {
                          final book = _filteredBooks[index];
                          return _buildBookItem(book);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterType, String label) {
    final isSelected = _selectedFilter.toLowerCase() == filterType.toLowerCase();
    
    // Explicitly casting the Widget to ChoiceChip to maintain standard properties
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = filterType;
            _applyFilters();
          });
        }
      },
      selectedColor: AppColors.primaryBlue,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.grey.shade200,
        ),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildBookItem(BookModel book) {
    Color statusBgColor;
    Color statusTextColor;
    String statusText;

    switch (book.status.toLowerCase()) {
      case 'available':
        statusBgColor = const Color(0xFFE6F4EA);
        statusTextColor = const Color(0xFF137333);
        statusText = 'Tersedia';
        break;
      case 'borrowed':
        statusBgColor = const Color(0xFFEBF2FF);
        statusTextColor = const Color(0xFF1A68FF);
        statusText = 'Dipinjam';
        break;
      case 'overdue':
        statusBgColor = const Color(0xFFFEE2E2);
        statusTextColor = const Color(0xFFDC2626);
        statusText = 'Terlambat';
        break;
      default:
        statusBgColor = Colors.grey.shade200;
        statusTextColor = Colors.grey.shade700;
        statusText = book.status;
    }

    // Helper color palette untuk cover placeholder agar bervariasi secara deterministik
    final List<Color> placeholders = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
    ];
    final coverBgColor = placeholders[book.title.length % placeholders.length];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Buka Detail & Form Screen
          final bookData = {
            'id': book.id,
            'title': book.title,
            'author': book.author,
            'category': book.category,
            'cover_url': book.coverUrl,
            'publisher': book.publisher,
            'year': book.year,
            'isbn': book.isbn,
            'summary': book.summary,
            'status': book.status,
            'color': coverBgColor,
          };

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminBookDetailScreen(bookData: bookData),
            ),
          ).then((_) => _loadBooks()); // Reload books ketika kembali (siapa tahu buku diedit/dihapus)
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Buku
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 70,
                  height: 100,
                  color: coverBgColor.withValues(alpha: 0.1),
                  child: Image.network(
                    book.coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(Icons.book_rounded, color: coverBgColor, size: 30),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Detail Buku
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Judul Buku
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Penulis
                    Text(
                      'Oleh: ${book.author}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Kategori
                    Row(
                      children: [
                        const Icon(Icons.category_outlined, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            book.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 32.0),
                  child: Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: AppColors.primaryBlue,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tidak Ada Buku Ditemukan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada buku dengan status "${_selectedFilter == 'All' ? 'Semua' : _selectedFilter}" di database Laragon Anda.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadBooks,
              icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
              label: const Text('Refresh Data', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
