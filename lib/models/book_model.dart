class BookModel {
  final String id;
  final String title;
  final String author;
  final String category;
  final String coverUrl;
  final String publisher;
  final String year;
  final String isbn;
  final String summary;
  final String status;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.coverUrl,
    required this.publisher,
    required this.year,
    required this.isbn,
    required this.summary,
    required this.status,
  });

  // ==========================
  // API LIBRARY
  // ==========================
  factory BookModel.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};

    String authorData = 'Unknown Author';
    if (volumeInfo['authors'] != null &&
        (volumeInfo['authors'] as List).isNotEmpty) {
      authorData = volumeInfo['authors'][0].toString();
    }

    String categoryData = 'General';
    if (volumeInfo['categories'] != null &&
        (volumeInfo['categories'] as List).isNotEmpty) {
      categoryData = volumeInfo['categories'][0].toString();
    }

    String isbnData = 'No ISBN';
    if (volumeInfo['industryIdentifiers'] != null) {
      var ids = volumeInfo['industryIdentifiers'] as List;
      if (ids.isNotEmpty) {
        isbnData = ids[0]['identifier'] ?? 'No ISBN';
      }
    }

    String cover =
        'https://via.placeholder.com/150x220.png?text=No+Cover';

    if (volumeInfo['imageLinks'] != null) {
      cover = volumeInfo['imageLinks']['thumbnail'] ??
          volumeInfo['imageLinks']['smallThumbnail'] ??
          cover;

      if (cover.startsWith('http://')) {
        cover = cover.replaceFirst('http://', 'https://');
      }
    }

    return BookModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: volumeInfo['title'] ?? 'Untitled Book',
      author: authorData,
      category: categoryData,
      coverUrl: cover,
      publisher: volumeInfo['publisher'] ?? 'Unknown Publisher',
      year: volumeInfo['publishedDate'] != null
          ? volumeInfo['publishedDate'].toString().split('-')[0]
          : 'Unknown',
      isbn: isbnData,
      summary: volumeInfo['description'] ?? 'No description available.',
      status: 'Available',
    );
  }

  // ==========================
  // OPEN LIBRARY API
  // ==========================
  factory BookModel.fromOpenLibrary(Map<String, dynamic> json) {
    String cover =
        'https://via.placeholder.com/150x220.png?text=No+Cover';

    if (json['cover_i'] != null) {
      cover =
          'https://covers.openlibrary.org/b/id/${json['cover_i']}-L.jpg';
    }

    String authorData = 'Unknown Author';
    if (json['author_name'] != null &&
        (json['author_name'] as List).isNotEmpty) {
      authorData = json['author_name'][0].toString();
    }

    String categoryData = 'General';
    if (json['subject'] != null &&
        (json['subject'] as List).isNotEmpty) {
      categoryData = json['subject'][0].toString();
    }

    String publisherData = 'Unknown Publisher';
    if (json['publisher'] != null &&
        (json['publisher'] as List).isNotEmpty) {
      publisherData = json['publisher'][0].toString();
    }

    String isbnData = 'No ISBN';
    if (json['isbn'] != null &&
        (json['isbn'] as List).isNotEmpty) {
      isbnData = json['isbn'][0].toString();
    }

    return BookModel(
      id: json['key'] ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'Untitled Book',
      author: authorData,
      category: categoryData,
      coverUrl: cover,
      publisher: publisherData,
      year: json['first_publish_year']?.toString() ?? 'Unknown',
      isbn: isbnData,
      summary: 'No description available.',
      status: 'Available',
    );
  }
}