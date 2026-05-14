import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/book.dart';
import '../models/book_model.dart';

class BookLocalDataSource {
  static const _key = 'books_v1';

  final SharedPreferences _prefs;
  BookLocalDataSource(this._prefs);

  Future<List<Book>> getBooks() async {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    final List<dynamic> jsonList = jsonDecode(raw) as List<dynamic>;
    return jsonList
        .map((e) => BookModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveAll(List<Book> books) async {
    final encoded = jsonEncode(books.map(BookModel.toJson).toList());
    await _prefs.setString(_key, encoded);
  }

  Future<void> addBook(Book book) async {
    final books = await getBooks();
    books.insert(0, book);
    await _saveAll(books);
  }

  Future<void> updateBook(Book updated) async {
    final books = await getBooks();
    final idx = books.indexWhere((b) => b.id == updated.id);
    if (idx != -1) books[idx] = updated;
    await _saveAll(books);
  }

  Future<void> deleteBook(String id) async {
    final books = await getBooks();
    books.removeWhere((b) => b.id == id);
    await _saveAll(books);
  }

  Future<void> seedIfEmpty() async {
    final existing = await getBooks();
    if (existing.isNotEmpty) return;

    final defaults = [
      const Book(
        id: '1', title: 'Dune', author: 'Frank Herbert',
        genre: 'Sci-Fi', coverEmoji: '🏜️', totalPages: 412,
        currentPage: 280, status: ReadingStatus.reading,
        rating: 4.5, notes: 'The world-building is extraordinary.',
        accentColorValue: 0xFFD4860B,
      ),
      const Book(
        id: '2', title: 'Educated', author: 'Tara Westover',
        genre: 'Memoir', coverEmoji: '📚', totalPages: 334,
        currentPage: 334, status: ReadingStatus.finished,
        rating: 5.0, notes: 'One of the most moving books I have read.',
        accentColorValue: 0xFF2E7D5E,
      ),
      const Book(
        id: '3', title: 'The Midnight Library', author: 'Matt Haig',
        genre: 'Fiction', coverEmoji: '🌙', totalPages: 288,
        status: ReadingStatus.wantToRead,
        accentColorValue: 0xFF3B5998,
      ),
      const Book(
        id: '4', title: 'Atomic Habits', author: 'James Clear',
        genre: 'Self-help', coverEmoji: '⚛️', totalPages: 320,
        currentPage: 320, status: ReadingStatus.finished,
        rating: 4.0, notes: 'The 1% better every day framework.',
        accentColorValue: 0xFFB5451B,
      ),
    ];

    await _saveAll(defaults);
  }
}
