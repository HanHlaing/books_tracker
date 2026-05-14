import '../entities/book.dart';
import '../repository/book_repository.dart';

class GetBooksUseCase {
  final BookRepository _repo;
  GetBooksUseCase(this._repo);

  Future<List<Book>> call() => _repo.getBooks();
}

class AddBookUseCase {
  final BookRepository _repo;
  AddBookUseCase(this._repo);

  Future<void> call(Book book) => _repo.addBook(book);
}

class UpdateBookUseCase {
  final BookRepository _repo;
  UpdateBookUseCase(this._repo);

  Future<void> call(Book book) => _repo.updateBook(book);
}

class DeleteBookUseCase {
  final BookRepository _repo;
  DeleteBookUseCase(this._repo);

  Future<void> call(String id) => _repo.deleteBook(id);
}
