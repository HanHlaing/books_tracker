import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/platform/adaptive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/book.dart';
import '../providers/book_provider.dart';
import '../widgets/book_card.dart';
import 'detail_screen.dart';
import 'add_book_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter        = ref.watch(bookFilterProvider);
    final filteredAsync = ref.watch(filteredBooksProvider);
    final allBooks      = ref.watch(bookListProvider).valueOrNull ?? [];

    final readingCount  = allBooks.where((b) => b.status == ReadingStatus.reading).length;
    final finishedCount = allBooks.where((b) => b.status == ReadingStatus.finished).length;

    void navigateToAdd() => Navigator.push(
      context, adaptiveRoute(builder: (_) => const AddBookScreen()));

    final body = CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Row(children: [
              _StatCard(label: 'Reading',  value: readingCount,    color: const Color(0xFFD4860B)),
              const SizedBox(width: 12),
              _StatCard(label: 'Finished', value: finishedCount,   color: const Color(0xFF2E7D5E)),
              const SizedBox(width: 12),
              _StatCard(label: 'Total',    value: allBooks.length, color: AppTheme.primary),
            ]),
          ),
        ),

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

        filteredAsync.when(
          loading: () => SliverFillRemaining(
            child: Center(child: adaptiveProgressIndicator()),
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
                        child: BookCard(
                          book: books[i],
                          onTap: () => Navigator.push(context,
                            adaptiveRoute(
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
    );

    if (isIOS) {
      return Scaffold(
        appBar: CupertinoNavigationBar(
          backgroundColor: AppTheme.surface,
          border: const Border(
            bottom: BorderSide(color: AppTheme.border, width: 0.5)),
          middle: const Text('My Library',
            style: TextStyle(
              color: AppTheme.textDark, fontWeight: FontWeight.w700)),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: navigateToAdd,
            child: const Icon(CupertinoIcons.add, color: AppTheme.primary),
          ),
        ),
        body: body,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: navigateToAdd,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAdd,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add book',
          style: TextStyle(fontWeight: FontWeight.w600)),
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
          Text('$value',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
              color: color, height: 1)),
          const SizedBox(height: 3),
          Text(label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted,
              fontWeight: FontWeight.w500)),
        ],
      ),
    ),
  );
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppTheme.primary : AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppTheme.primary : AppTheme.border),
      ),
      child: Text(label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppTheme.textMuted,
        )),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => const Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('📚', style: TextStyle(fontSize: 48)),
      SizedBox(height: 16),
      Text('No books here yet',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
          color: AppTheme.textMuted)),
    ]),
  );
}
