import 'package:flutter/material.dart';
import '../../api_service.dart';
import '../../models/book_model.dart';

// =========================================================================
// 1. DETAIL SCREEN & MODAL DELETE BOOK (ANTI-GAGAL)
// =========================================================================
class AdminBookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> bookData;
  const AdminBookDetailScreen({super.key, required this.bookData});

  @override
  State<AdminBookDetailScreen> createState() => _AdminBookDetailScreenState();
}

class _AdminBookDetailScreenState extends State<AdminBookDetailScreen> {

  // Modal Bottom Sheet Khusus Konfirmasi Hapus Buku
  void _showDeleteConfirmation(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      useRootNavigator: true, // Dipaksa muncul di atas komponen layar apa pun tanpa bentrok
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gambar Lingkaran Ikon Sampah Merah Sesuai Desain
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(width: 95, height: 95, decoration: const BoxDecoration(color: Color(0xFFFFEAEA), shape: BoxShape.circle)),
                  Container(
                    width: 74,
                    height: 74,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFFFF4D4D), Color(0xFFFF2222)]),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 36),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF9800), size: 20),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Delete Book',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              // Kotak Nama Buku Yang Mau Dihapus
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.book_outlined, color: Color(0xFFEF4444), size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Are you sure you want to delete this book from the library? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
              ),
              const SizedBox(height: 32),
              // Tombol Cancel & Delete
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx); // Tutup bottom sheet dulu
                        final id = widget.bookData['id']?.toString() ?? '';
                        if (id.isEmpty) return;

                        final success = await ApiService.deleteBook(id);
                        if (!context.mounted) return;

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 10),
                                Text('Buku berhasil dihapus dari database!'),
                              ]),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                          Navigator.pop(context, 'deleted'); // Kirim sinyal ke halaman sebelumnya
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gagal menghapus buku. Coba lagi.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'All borrowing history for this book will be preserved',
                style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final coverUrl = widget.bookData['cover_url']?.toString() ?? '';
    final summaryText = widget.bookData['summary']?.toString() ?? '';
    final coverColor = widget.bookData['color'];
    final Color fallbackColor = (coverColor is Color) ? coverColor : const Color(0xFF3B82F6);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: const Text('Book Details', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // --- COVER BUKU ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: coverUrl.isNotEmpty && !coverUrl.contains('placeholder')
                        ? Image.network(
                            coverUrl,
                            width: 140,
                            height: 190,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildCoverPlaceholder(fallbackColor),
                          )
                        : _buildCoverPlaceholder(fallbackColor),
                  ),
                  const SizedBox(height: 24),

                  // --- INFO CARD ---
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(widget.bookData['title'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('by ${widget.bookData['author'] ?? ''}', style: const TextStyle(color: Colors.grey)),
                        const Divider(height: 32),
                        _row('Category', widget.bookData['category'] ?? '-'),
                        _row('Publisher', widget.bookData['publisher'] ?? '-'),
                        _row('Year', widget.bookData['year'] ?? '-'),
                        _row('ISBN', widget.bookData['isbn'] ?? '-'),
                        _row('Status', widget.bookData['status'] ?? 'Available', isStatus: true),
                      ],
                    ),
                  ),

                  // --- SUMMARY ---
                  if (summaryText.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(children: [
                            Icon(Icons.subject_rounded, color: Color(0xFF3B82F6), size: 20),
                            SizedBox(width: 8),
                            Text('Ringkasan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                          ]),
                          const SizedBox(height: 12),
                          Text(
                            summaryText,
                            style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.6),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AdminBookFormScreen(bookData: widget.bookData)));
                      if (result == 'saved' && context.mounted) {
                        Navigator.pop(context, 'saved');
                      }
                    },
                    icon: const Icon(Icons.edit_document, color: Colors.white),
                    label: const Text('Edit Book', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Builder(
                    builder: (buttonContext) {
                      return ElevatedButton.icon(
                        onPressed: () => _showDeleteConfirmation(buttonContext, widget.bookData['title'] ?? 'Selected Book'),
                        icon: const Icon(Icons.delete_outline, color: Colors.white),
                        label: const Text('Delete Book', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      );
                    }
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCoverPlaceholder(Color color) {
    return Container(
      width: 140,
      height: 190,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: const Center(child: Icon(Icons.menu_book_rounded, color: Colors.white, size: 65)),
    );
  }

  Widget _row(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          isStatus
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: value == 'Available' ? const Color(0xFFE6F9F0) : const Color(0xFFFFF2EC), borderRadius: BorderRadius.circular(12)),
                child: Text(value, style: TextStyle(color: value == 'Available' ? const Color(0xFF00C569) : const Color(0xFFFF6B2C), fontWeight: FontWeight.bold, fontSize: 13)),
              )
            : Expanded(
                child: Text(value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              ),
        ],
      ),
    );
  }
}

// =========================================================================
// 2. ADAPTIVE ADD & EDIT FORM SCREEN
// =========================================================================
class AdminBookFormScreen extends StatefulWidget {
  final Map<String, dynamic>? bookData;
  const AdminBookFormScreen({super.key, this.bookData});

  @override
  State<AdminBookFormScreen> createState() => _AdminBookFormScreenState();
}

class _AdminBookFormScreenState extends State<AdminBookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditMode = false;
  bool _isLoading = false;
  String _selectedStatus = 'Available';

  final _titleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _publisherCtrl = TextEditingController();
  final _isbnCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.bookData != null) {
      _isEditMode = true;
      _titleCtrl.text = widget.bookData!['title'] ?? '';
      _authorCtrl.text = widget.bookData!['author'] ?? '';
      _categoryCtrl.text = widget.bookData!['category'] ?? '';
      _yearCtrl.text = widget.bookData!['year'] ?? '';
      _publisherCtrl.text = widget.bookData!['publisher'] ?? '';
      _isbnCtrl.text = widget.bookData!['isbn'] ?? '';
      _summaryCtrl.text = widget.bookData!['summary'] ?? '';
      _urlCtrl.text = widget.bookData!['bookUrl'] ?? widget.bookData!['book_url'] ?? '';
      _selectedStatus = widget.bookData!['status'] ?? 'Available';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: Text(_isEditMode ? 'Edit Book' : 'Add Book', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Book Title', isReq: true),
                      _field(_titleCtrl, 'Enter book title', val: (v) => v!.isEmpty ? 'Required' : null),
                      const SizedBox(height: 16),
                      _label('Author', isReq: true),
                      _field(_authorCtrl, 'Enter author name', val: (v) => v!.isEmpty ? 'Required' : null),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Category'), _field(_categoryCtrl, 'e.g. Fiction')])),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Year'), _field(_yearCtrl, '2024', keyType: TextInputType.number)])),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Publisher'), _field(_publisherCtrl, 'Enter publisher')])),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('ISBN'), _field(_isbnCtrl, '978-0-00...')])),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _label('Book URL / Link'),
                      _field(_urlCtrl, 'Enter link to read book...'),
                      const SizedBox(height: 16),
                      _label('Summary'),
                      _field(_summaryCtrl, 'Brief description...', maxLines: 4),
                      const SizedBox(height: 16),
                      if (_isEditMode) ...[
                        _label('Availability Status'),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedStatus = 'Available'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(color: _selectedStatus == 'Available' ? Colors.white : const Color(0xFFF1F3F6), borderRadius: BorderRadius.circular(12)),
                                  child: Center(child: Text('Available', style: TextStyle(color: _selectedStatus == 'Available' ? const Color(0xFF00A86B) : Colors.grey, fontWeight: FontWeight.bold))),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedStatus = 'Borrowed'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(color: _selectedStatus == 'Borrowed' ? Colors.white : const Color(0xFFF1F3F6), borderRadius: BorderRadius.circular(12)),
                                  child: Center(child: Text('Borrowed', style: TextStyle(color: _selectedStatus == 'Borrowed' ? const Color(0xFFFF6B2C) : Colors.grey, fontWeight: FontWeight.bold))),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isLoading = true);
                        
                        final book = BookModel(
                          id: widget.bookData?['id']?.toString() ?? '',
                          title: _titleCtrl.text,
                          author: _authorCtrl.text,
                          category: _categoryCtrl.text,
                          coverUrl: widget.bookData?['cover_url'] ?? 'https://via.placeholder.com/150x220.png?text=No+Cover',
                          publisher: _publisherCtrl.text,
                          year: _yearCtrl.text,
                          isbn: _isbnCtrl.text,
                          summary: _summaryCtrl.text,
                          status: _selectedStatus,
                          bookUrl: _urlCtrl.text,
                        );

                        Map<String, dynamic> response;
                        if (_isEditMode) {
                          response = await ApiService.updateBook(book);
                        } else {
                          response = await ApiService.saveBookToLaragon(book);
                        }

                        if (!mounted) return;
                        setState(() => _isLoading = false);

                        if (response['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(response['message'] ?? 'Berhasil menyimpan buku!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context, 'saved');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(response['message'] ?? 'Gagal menyimpan buku'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Icon(_isEditMode ? Icons.edit_document : Icons.save_outlined, color: Colors.white),
                    label: Text(_isEditMode ? 'Update Book' : 'Save Book', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isEditMode ? const Color(0xFF4F46E5) : const Color(0xFF00A86B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text, {bool isReq = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text.rich(TextSpan(text: text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), children: [if (isReq) const TextSpan(text: ' *', style: TextStyle(color: Colors.red))])),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, {int maxLines = 1, TextInputType keyType = TextInputType.text, String? Function(String?)? val}) {
    return TextFormField(
      controller: ctrl, maxLines: maxLines, keyboardType: keyType, validator: val,
      decoration: InputDecoration(
        hintText: hint, filled: true, fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B59FF), width: 1.5)),
      ),
    );
  }
}