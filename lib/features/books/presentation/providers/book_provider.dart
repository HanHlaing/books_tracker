import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../books/data/datasource/book_local_datasource.dart';
import '../../../books/data/repository/book_repository_impl.dart';
import '../../../books/domain/entities/book.dart';
import '../../../books/domain/usecases/book_usecases.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});

final localDataSourceProvider = Provider<BookLocalDataSource>((ref) {
  return BookLocalDataSource(ref.read(sharedPrefsProvider));
});

final bookRepositoryProvider = Provider<BookRepositoryImpl>((ref) {
  return BookRepositoryImpl(ref.read(localDataSourceProvider));
});

final getBooksUseCaseProvider = Provider((ref) {
  return GetBooksUseCase(ref.read(bookRepositoryProvider));
});

final addBookUseCaseProvider = Provider((ref) {
  return AddBookUseCase(ref.read(bookRepositoryProvider));
});

final updateBookUseCaseProvider = Provider((ref) {
  return UpdateBookUseCase(ref.read(bookRepositoryProvider));
});

final deleteBookUseCaseProvider = Provider((ref) {
  return DeleteBookUseCase(ref.read(bookRepositoryProvider));
});

class BookListNotifier extends AsyncNotifier<List<Book>> {
  @override
  Future<List<Book>> build() async {
    return ref.read(getBooksUseCaseProvider).call();
  }

  Future<void> addBook(Book book) async {
    await ref.read(addBookUseCaseProvider).call(book);
    ref.invalidateSelf();
  }

  Future<void> updateBook(Book book) async {
    await ref.read(updateBookUseCaseProvider).call(book);
    ref.invalidateSelf();
  }

  Future<void> deleteBook(String id) async {
    await ref.read(deleteBookUseCaseProvider).call(id);
    ref.invalidateSelf();
  }
}

final bookListProvider =
    AsyncNotifierProvider<BookListNotifier, List<Book>>(BookListNotifier.new);

enum BookFilter { all, reading, finished, wantToRead }

final bookFilterProvider = StateProvider<BookFilter>((ref) => BookFilter.all);

final filteredBooksProvider = Provider<AsyncValue<List<Book>>>((ref) {
  final filter = ref.watch(bookFilterProvider);
  final books  = ref.watch(bookListProvider);

  return books.whenData((list) {
    if (filter == BookFilter.all) return list;
    final statusMap = {
      BookFilter.reading:    ReadingStatus.reading,
      BookFilter.finished:   ReadingStatus.finished,
      BookFilter.wantToRead: ReadingStatus.wantToRead,
    };
    return list.where((b) => b.status == statusMap[filter]).toList();
  });
});
