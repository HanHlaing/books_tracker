// ─────────────────────────────────────────────
//  DOMAIN LAYER — Repository interface (contract)
//  Abstract class only. No implementation here.
//  The data layer provides the concrete class.
// ─────────────────────────────────────────────

import '../entities/book.dart';

abstract class BookRepository {
  /// Returns all books, newest first.
  Future<List<Book>> getBooks();

  /// Persists a new book.
  Future<void> addBook(Book book);

  /// Replaces the stored book with the same id.
  Future<void> updateBook(Book book);

  /// Removes a book by id.
  Future<void> deleteBook(String id);
}