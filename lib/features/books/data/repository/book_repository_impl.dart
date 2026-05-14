import '../../domain/entities/book.dart';
import '../../domain/repository/book_repository.dart';
import '../datasource/book_local_datasource.dart';

class BookRepositoryImpl implements BookRepository {
  final BookLocalDataSource _local;
  BookRepositoryImpl(this._local);

  @override
  Future<List<Book>> getBooks() => _local.getBooks();

  @override
  Future<void> addBook(Book book) => _local.addBook(book);

  @override
  Future<void> updateBook(Book book) => _local.updateBook(book);

  @override
  Future<void> deleteBook(String id) => _local.deleteBook(id);
}
