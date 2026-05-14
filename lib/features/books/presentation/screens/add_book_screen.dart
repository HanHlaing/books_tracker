import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/book.dart';
import '../providers/book_provider.dart';

class AddBookScreen extends ConsumerStatefulWidget {
  const AddBookScreen({super.key});

  @override
  ConsumerState<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends ConsumerState<AddBookScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _titleCtrl    = TextEditingController();
  final _authorCtrl   = TextEditingController();
  final _pagesCtrl    = TextEditingController();
  bool _saving = false;

  String        _genre  = 'Fiction';
  String        _emoji  = '📖';
  Color         _color  = const Color(0xFF534AB7);
  ReadingStatus _status = ReadingStatus.wantToRead;

  static const _genres  = ['Fiction', 'Non-fiction', 'Sci-Fi', 'Fantasy', 'Memoir', 'Self-help', 'History', 'Other'];
  static const _emojis  = ['📖', '🏔️', '🌊', '🌙', '🏜️', '🌿', '🔮', '⚡', '🎭', '🦋', '🌸', '🗺️'];
  static const _colors  = [
    Color(0xFF534AB7), Color(0xFF2E7D5E), Color(0xFFD4860B),
    Color(0xFFB5451B), Color(0xFF3B5998), Color(0xFF7B3F6E),
    Color(0xFF1A6B6B), Color(0xFF8B4513),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _pagesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final book = Book(
      id:              DateTime.now().millisecondsSinceEpoch.toString(),
      title:           _titleCtrl.text.trim(),
      author:          _authorCtrl.text.trim(),
      genre:           _genre,
      coverEmoji:      _emoji,
      totalPages:      int.tryParse(_pagesCtrl.text) ?? 0,
      status:          _status,
      accentColorValue: _color.value,
    );

    await ref.read(bookListProvider.notifier).addBook(book);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a book'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(children: [
                Container(
                  width: 96, height: 120,
                  decoration: BoxDecoration(
                    color: _color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _color.withOpacity(0.3), width: 2),
                  ),
                  child: Center(child: Text(_emoji, style: const TextStyle(fontSize: 48))),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  children: _emojis.map((e) => GestureDetector(
                    onTap: () => setState(() => _emoji = e),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: _emoji == e ? _color.withOpacity(0.15) : AppTheme.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _emoji == e ? _color : AppTheme.border),
                      ),
                      child: Center(child: Text(e, style: const TextStyle(fontSize: 20))),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _colors.map((c) => GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        width: 26, height: 26,
                        decoration: BoxDecoration(
                          color: c, shape: BoxShape.circle,
                          border: Border.all(
                            color: _color == c ? AppTheme.textDark : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ]),
            ),
            const SizedBox(height: 28),

            const _Label('Title'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(hintText: 'Book title'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 18),

            const _Label('Author'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _authorCtrl,
              decoration: const InputDecoration(hintText: 'Author name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 18),

            Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Label('Pages'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _pagesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '300'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (int.tryParse(v) == null) return 'Numbers only';
                      return null;
                    },
                  ),
                ],
              )),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Label('Genre'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _genre,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
                    items: _genres.map((g) =>
                      DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (v) => setState(() => _genre = v!),
                  ),
                ],
              )),
            ]),
            const SizedBox(height: 24),

            const _Label('Status'),
            const SizedBox(height: 10),
            ...ReadingStatus.values.map((s) => RadioListTile<ReadingStatus>(
              value: s,
              groupValue: _status,
              onChanged: (v) => setState(() => _status = v!),
              title: Text(_statusLabel(s),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500,
                  color: AppTheme.textDark)),
              contentPadding: EdgeInsets.zero,
              activeColor: _color,
            )),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.library_add_rounded),
                label: Text(_saving ? 'Saving…' : 'Add to library'),
                style: ElevatedButton.styleFrom(backgroundColor: _color),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _statusLabel(ReadingStatus s) => switch (s) {
    ReadingStatus.reading    => 'Currently reading',
    ReadingStatus.finished   => 'Already finished it',
    ReadingStatus.wantToRead => 'Want to read',
  };
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
      color: AppTheme.textMuted, letterSpacing: 0.5));
}
