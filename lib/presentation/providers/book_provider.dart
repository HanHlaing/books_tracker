// ─────────────────────────────────────────────
//  PRESENTATION LAYER — Riverpod providers
//  Wires use cases → repository → datasource.
//  Screens only ever touch these providers.
// ─────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../application/usecases/book_usecases.dart';
import '../../data/datasources/book_local_datasource.dart';
import '../../data/repositories/book_repository_impl.dart';
import '../../domain/entities/book.dart';

// ── Infrastructure providers ──────────────────
// SharedPreferences must be initialised before runApp,
// then injected via ProviderScope overrides.
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});

final localDataSourceProvider = Provider<BookLocalDataSource>((ref) {
  return BookLocalDataSource(ref.read(sharedPrefsProvider));
});

final bookRepositoryProvider = Provider<BookRepositoryImpl>((ref) {
  return BookRepositoryImpl(ref.read(localDataSourceProvider));
});

// ── Use case providers ────────────────────────
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

// ── State provider — the books list ──────────
// AsyncNotifier handles loading / error / data states automatically.
class BookListNotifier extends AsyncNotifier<List<Book>> {
  @override
  Future<List<Book>> build() async {
    return ref.read(getBooksUseCaseProvider).call();
  }

  Future<void> addBook(Book book) async {
    await ref.read(addBookUseCaseProvider).call(book);
    ref.invalidateSelf(); // re-fetches from storage
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

// ── Filter provider ───────────────────────────
enum BookFilter { all, reading, finished, wantToRead }

final bookFilterProvider = StateProvider<BookFilter>((ref) => BookFilter.all);

// Derived provider: filtered view of the list
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