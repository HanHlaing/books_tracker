// ─────────────────────────────────────────────
//  APPLICATION LAYER — Use cases
//  One class per user action. Each use case
//  depends only on the domain interface, never
//  on the concrete data implementation.
// ─────────────────────────────────────────────

import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';

// ── 1. Get all books ──────────────────────────
class GetBooksUseCase {
  final BookRepository _repo;
  GetBooksUseCase(this._repo);

  Future<List<Book>> call() => _repo.getBooks();
}

// ── 2. Add a book ─────────────────────────────
class AddBookUseCase {
  final BookRepository _repo;
  AddBookUseCase(this._repo);

  Future<void> call(Book book) => _repo.addBook(book);
}

// ── 3. Update a book ──────────────────────────
class UpdateBookUseCase {
  final BookRepository _repo;
  UpdateBookUseCase(this._repo);

  Future<void> call(Book book) => _repo.updateBook(book);
}

// ── 4. Delete a book ──────────────────────────
class DeleteBookUseCase {
  final BookRepository _repo;
  DeleteBookUseCase(this._repo);

  Future<void> call(String id) => _repo.deleteBook(id);
}