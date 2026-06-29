import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/book_model.dart';

class ApiService {
  // === 1. KONFIGURASI URL LAUNCHER (Sesuai Slide 5) ===
  // PENTING: Ganti XX dengan angka IP Address laptop kamu dari hasil 'ipconfig' di CMD!
  static const String baseUrl = "http://192.168.100.51/pocket-api";

  // === 2. FUNGSI LOGIKA AUTENTIKASI MULTI-ROLE (Sesuai Slide 6) ===
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login.php"),
        body: {
          "email": email,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {"status": "error", "message": "Server bermasalah (${response.statusCode})"};
      }
    } catch (e) {
      // Penanganan Error Jaringan (Sesuai Slide 10)
      return {"status": "error", "message": "Gagal terhubung ke server backend!"};
    }
  }

  // === 3. FUNGSI AMBIL DATA DARI GOOGLE BOOKS API (Sesuai Slide 8 - Telah Diperbaiki) ===
  static Future<List<dynamic>> searchGoogleBooks(String query) async {
    // Uri.encodeComponent otomatis mengubah spasi menjadi format URL yang valid (%20 atau +)
    final url = "https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeComponent(query)}";
    
    try {
      print("Menembak Google API: $url"); // Memantau proses di Debug Console VS Code
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Data Google ditemukan: ${data['items']?.length ?? 0} buku");
        return data['items'] ?? []; // Mengembalikan list item buku dari Google
      } else {
        print("Google API Error Code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error Jaringan saat memanggil Google API: $e");
      return [];
    }
  }

  // === 4. FUNGSI SIKLUS CRUD: CREATE (Simpan ke MySQL Laragon - Sesuai Slide 9) ===
 static Future<Map<String, dynamic>> saveBookToLaragon(BookModel book) async {
  try {
    final response = await http.post(
      Uri.parse("$baseUrl/books.php"),
      body: {
        "title": book.title,
        "author": book.author,
        "category": book.category,
        "cover_url": book.coverUrl,
        "publisher": book.publisher,
        "publish_year": book.year,
        "isbn": book.isbn,
        "summary": book.summary,
        "status": book.status,
      },
    );

    print("STATUS CODE: ${response.statusCode}");
    print("RESPONSE BODY:");
    print(response.body);

    return json.decode(response.body);
  } catch (e) {
    print("ERROR: $e");

    return {
      "status": "error",
      "message": e.toString(),
    };
  }
}

  // === 5. FUNGSI SIKLUS CRUD: READ (Ambil dari MySQL Laragon - Sesuai Slide 9) ===
  static Future<List<dynamic>> getLocalBooks() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/books.php"));
      if (response.statusCode == 200) {
        return json.decode(response.body); // Mengembalikan list buku dari database Laragon
      }
      return [];
    } catch (e) {
      print("Error mengambil data lokal: $e");
      return [];
    }
  }

  // === 6. FUNGSI SIKLUS CRUD: DELETE (Hapus dari MySQL Laragon - Sesuai Slide 9) ===
  static Future<List<BookModel>> getBooks() async {
  try {
    final response = await http.get(
      Uri.parse("$baseUrl/books.php"),
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);

      return data
          .map((e) => BookModel(
                id: e["id"].toString(),
                title: e["title"] ?? "",
                author: e["author"] ?? "",
                category: e["category"] ?? "General",
                coverUrl: e["cover_url"] ??
                    "https://via.placeholder.com/150x220.png?text=No+Cover",
                publisher: e["publisher"] ?? "",
                year: e["publish_year"] ?? "",
                isbn: e["isbn"] ?? "",
                summary: e["summary"] ?? "",
                status: e["status"] ?? "Available",
              ))
          .toList();
    }

        return [];
      } catch (e) {
        print(e);
        return [];
      }
}
  static Future<bool> deleteBook(String id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/books.php"),
        body: {
          "id": id,
        },
      );

      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        return res["status"] == "success";
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // === 7. FUNGSI AMBIL DATA PENGGUNA AKTIF ===
  static Future<Map<String, dynamic>> getUsers() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/users.php"));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {"status": "error", "total": 0, "users": []};
    } catch (e) {
      return {"status": "error", "total": 0, "users": []};
    }
  }

  // === 8. FUNGSI REGISTRASI ANGGOTA BARU ===
  static Future<Map<String, dynamic>> registerUser(String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/users.php"),
        body: {
          "email": email,
          "password": password,
          "role": role,
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {"status": "error", "message": "Server error (${response.statusCode})"};
    } catch (e) {
      return {"status": "error", "message": "Gagal terhubung ke server!"};
    }
  }

  // === 9. FUNGSI HAPUS PENGGUNA ===
  static Future<bool> deleteUser(String id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/users.php"),
        body: {"id": id},
      );
      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        return res["status"] == "success";
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
