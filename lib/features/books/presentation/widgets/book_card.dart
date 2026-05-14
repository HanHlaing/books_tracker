import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  const BookCard({super.key, required this.book, required this.onTap});

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
