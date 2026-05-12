// ─────────────────────────────────────────────
//  PRESENTATION — Home screen
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../domain/entities/book.dart';
import '../providers/book_provider.dart';
import 'detail_screen.dart';
import 'add_book_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter       = ref.watch(bookFilterProvider);
    final filteredAsync = ref.watch(filteredBooksProvider);
    final allBooks     = ref.watch(bookListProvider).valueOrNull ?? [];

    final readingCount  = allBooks.where((b) => b.status == ReadingStatus.reading).length;
    final finishedCount = allBooks.where((b) => b.status == ReadingStatus.finished).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddBookScreen())),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Row(children: [
                _StatCard(label: 'Reading',  value: readingCount,      color: const Color(0xFFD4860B)),
                const SizedBox(width: 12),
                _StatCard(label: 'Finished', value: finishedCount,     color: const Color(0xFF2E7D5E)),
                const SizedBox(width: 12),
                _StatCard(label: 'Total',    value: allBooks.length,   color: AppTheme.primary),
              ]),
            ),
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: BookFilter.values.map((f) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: _filterLabel(f),
                    selected: filter == f,
                    onTap: () => ref.read(bookFilterProvider.notifier).state = f,
                  ),
                )).toList(),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Book list — handle all AsyncValue states
          filteredAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
            data: (books) => books.isEmpty
                ? const SliverFillRemaining(child: _EmptyState())
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _BookCard(
                            book: books[i],
                            onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                builder: (_) => BookDetailScreen(book: books[i]))),
                          ),
                        ),
                        childCount: books.length,
                      ),
                    ),
                  ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AddBookScreen())),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add book', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  String _filterLabel(BookFilter f) => switch (f) {
    BookFilter.all        => 'All',
    BookFilter.reading    => 'Reading',
    BookFilter.finished   => 'Finished',
    BookFilter.wantToRead => 'Want to read',
  };
}

// ── Sub-widgets ───────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$value', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color, height: 1)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
        ],
      ),
    ),
  );
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppTheme.primary : AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? AppTheme.primary : AppTheme.border),
      ),
      child: Text(label,
        style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppTheme.textMuted,
        )),
    ),
  );
}

class _BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  const _BookCard({required this.book, required this.onTap});

  Color get accent => Color(book.accentColorValue);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        // Cover
        Container(
          width: 60, height: 80,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent.withOpacity(0.25)),
          ),
          child: Center(child: Text(book.coverEmoji, style: const TextStyle(fontSize: 28))),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(book.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                    color: AppTheme.textDark, height: 1.2),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
                _StatusBadge(status: book.status),
              ]),
              const SizedBox(height: 3),
              Text(book.author, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
              const SizedBox(height: 10),
              if (book.status == ReadingStatus.reading)
                Row(children: [
                  Expanded(child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: book.progress,
                      backgroundColor: AppTheme.border,
                      color: accent, minHeight: 5,
                    ),
                  )),
                  const SizedBox(width: 10),
                  Text('${(book.progress * 100).round()}%',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accent)),
                ])
              else if (book.status == ReadingStatus.finished && book.rating > 0)
                Row(children: List.generate(5, (i) => Icon(
                  i < book.rating.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 16, color: const Color(0xFFD4860B),
                )))
              else
                Text(book.genre,
                  style: TextStyle(fontSize: 12, color: accent, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 20),
      ]),
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  final ReadingStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg, label) = switch (status) {
      ReadingStatus.reading    => (const Color(0xFFD4860B), const Color(0xFFFEF3CD), 'Reading'),
      ReadingStatus.finished   => (const Color(0xFF2E7D5E), const Color(0xFFE0F5EC), 'Done'),
      ReadingStatus.wantToRead => (AppTheme.textMuted,      AppTheme.border,         'Later'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => const Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('📚', style: TextStyle(fontSize: 48)),
      SizedBox(height: 16),
      Text('No books here yet', style: TextStyle(
        fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
    ]),
  );
}