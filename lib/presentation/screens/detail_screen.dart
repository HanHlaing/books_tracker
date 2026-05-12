// ─────────────────────────────────────────────
//  PRESENTATION — Book Detail screen
// ─────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../domain/entities/book.dart';
import '../providers/book_provider.dart';

class BookDetailScreen extends ConsumerStatefulWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  ConsumerState<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen> {
  late int _currentPage;
  late ReadingStatus _status;
  late double _rating;
  late TextEditingController _notesCtrl;
  bool _saving = false;

  Color get accent => Color(widget.book.accentColorValue);

  @override
  void initState() {
    super.initState();
    _currentPage = widget.book.currentPage;
    _status      = widget.book.status;
    _rating      = widget.book.rating;
    _notesCtrl   = TextEditingController(text: widget.book.notes);
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final updated = widget.book.copyWith(
      currentPage: _currentPage,
      status:      _status,
      rating:      _rating,
      notes:       _notesCtrl.text,
    );
    await ref.read(bookListProvider.notifier).updateBook(updated);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove book?'),
        content: Text('Remove "${widget.book.title}" from your library?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await ref.read(bookListProvider.notifier).deleteBook(widget.book.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: accent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                onPressed: _delete,
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: accent,
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(book.coverEmoji, style: const TextStyle(fontSize: 72)),
                      const SizedBox(height: 12),
                      Text(book.title, style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800,
                        color: Colors.white, letterSpacing: -0.5),
                        textAlign: TextAlign.center),
                      const SizedBox(height: 4),
                      Text(book.author,
                        style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Genre + pages
                  Row(children: [
                    _Pill(label: book.genre, color: accent),
                    const SizedBox(width: 8),
                    _Pill(label: '${book.totalPages} pages', color: AppTheme.textMuted),
                  ]),
                  const SizedBox(height: 24),

                  // Status
                  const _Label('Status'),
                  const SizedBox(height: 10),
                  Row(children: ReadingStatus.values.map((s) {
                    final selected = _status == s;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _status = s;
                            if (s == ReadingStatus.finished) _currentPage = book.totalPages;
                            if (s == ReadingStatus.wantToRead) _currentPage = 0;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? accent : AppTheme.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: selected ? accent : AppTheme.border),
                            ),
                            child: Text(
                              s == ReadingStatus.wantToRead ? 'Want\nto read'
                                : s.name[0].toUpperCase() + s.name.substring(1),
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : AppTheme.textMuted, height: 1.3),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList()),
                  const SizedBox(height: 24),

                  // Progress slider
                  if (_status == ReadingStatus.reading) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _Label('Progress'),
                        Text('Page $_currentPage of ${book.totalPages}',
                          style: TextStyle(fontSize: 13, color: accent, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: accent,
                        inactiveTrackColor: AppTheme.border,
                        thumbColor: accent,
                        overlayColor: accent.withOpacity(0.1),
                        trackHeight: 5,
                      ),
                      child: Slider(
                        value: _currentPage.toDouble(),
                        min: 0, max: book.totalPages.toDouble(),
                        onChanged: (v) => setState(() => _currentPage = v.round()),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Star rating
                  if (_status == ReadingStatus.finished) ...[
                    const _Label('Your rating'),
                    const SizedBox(height: 10),
                    Row(children: List.generate(5, (i) => GestureDetector(
                      onTap: () => setState(() => _rating = (i + 1).toDouble()),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(
                          i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 36, color: const Color(0xFFD4860B),
                        ),
                      ),
                    ))),
                    const SizedBox(height: 24),
                  ],

                  // Notes
                  const _Label('Notes'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notesCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Key quotes, thoughts, ideas...',
                      hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check_rounded),
                      label: Text(_saving ? 'Saving…' : 'Save changes'),
                      style: ElevatedButton.styleFrom(backgroundColor: accent),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
  );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(
      fontSize: 13, fontWeight: FontWeight.w700,
      color: AppTheme.textMuted, letterSpacing: 0.5));
}