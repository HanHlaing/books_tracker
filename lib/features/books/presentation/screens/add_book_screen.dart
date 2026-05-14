import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/platform/adaptive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/book.dart';
import '../providers/book_provider.dart';

class AddBookScreen extends ConsumerStatefulWidget {
  const AddBookScreen({super.key});

  @override
  ConsumerState<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends ConsumerState<AddBookScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _titleCtrl  = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _pagesCtrl  = TextEditingController();
  bool _saving = false;

  String        _genre  = 'Fiction';
  String        _emoji  = '📖';
  Color         _color  = const Color(0xFF534AB7);
  ReadingStatus _status = ReadingStatus.wantToRead;

  // iOS validation state
  String? _titleError;
  String? _authorError;
  String? _pagesError;

  static const _genres = [
    'Fiction', 'Non-fiction', 'Sci-Fi', 'Fantasy',
    'Memoir', 'Self-help', 'History', 'Other',
  ];
  static const _emojis = [
    '📖', '🏔️', '🌊', '🌙', '🏜️', '🌿', '🔮', '⚡', '🎭', '🦋', '🌸', '🗺️',
  ];
  static const _colors = [
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
    if (isIOS) {
      final titleErr  = _titleCtrl.text.trim().isEmpty ? 'Required' : null;
      final authorErr = _authorCtrl.text.trim().isEmpty ? 'Required' : null;
      final pagesErr  = _pagesCtrl.text.trim().isEmpty
          ? 'Required'
          : int.tryParse(_pagesCtrl.text) == null
              ? 'Numbers only'
              : null;
      if (titleErr != null || authorErr != null || pagesErr != null) {
        setState(() {
          _titleError  = titleErr;
          _authorError = authorErr;
          _pagesError  = pagesErr;
        });
        return;
      }
    } else {
      if (!_formKey.currentState!.validate()) return;
    }

    setState(() => _saving = true);

    final book = Book(
      id:               DateTime.now().millisecondsSinceEpoch.toString(),
      title:            _titleCtrl.text.trim(),
      author:           _authorCtrl.text.trim(),
      genre:            _genre,
      coverEmoji:       _emoji,
      totalPages:       int.tryParse(_pagesCtrl.text) ?? 0,
      status:           _status,
      accentColorValue: _color.value,
    );

    await ref.read(bookListProvider.notifier).addBook(book);
    if (mounted) Navigator.pop(context);
  }

  void _showGenrePicker(BuildContext context) {
    final idx = _genres.indexOf(_genre);
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => Container(
        height: 260,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CupertinoButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
          Expanded(
            child: CupertinoPicker(
              itemExtent: 36,
              scrollController:
                  FixedExtentScrollController(initialItem: idx),
              onSelectedItemChanged: (i) =>
                  setState(() => _genre = _genres[i]),
              children: _genres
                  .map((g) => Center(child: Text(g)))
                  .toList(),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildCoverPicker() {
    return Center(
      child: Column(children: [
        Container(
          width: 96,
          height: 120,
          decoration: BoxDecoration(
            color: _color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _color.withOpacity(0.3), width: 2),
          ),
          child: Center(
            child: Text(_emoji, style: const TextStyle(fontSize: 48))),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          children: _emojis.map((e) => GestureDetector(
            onTap: () => setState(() => _emoji = e),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _emoji == e
                    ? _color.withOpacity(0.15)
                    : AppTheme.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _emoji == e ? _color : AppTheme.border),
              ),
              child: Center(
                child: Text(e, style: const TextStyle(fontSize: 20))),
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
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _color == c
                        ? AppTheme.textDark
                        : Colors.transparent,
                    width: 2.5,
                  ),
                ),
              ),
            ),
          )).toList(),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isIOS) return _buildCupertinoScaffold(context);
    return _buildMaterialScaffold(context);
  }

  // ── iOS ──────────────────────────────────────────────────────

  Widget _buildCupertinoScaffold(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.surface,
        border: const Border(
          bottom: BorderSide(color: AppTheme.border, width: 0.5)),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel',
            style: TextStyle(color: AppTheme.primary)),
        ),
        middle: const Text('Add a book',
          style: TextStyle(
            color: AppTheme.textDark, fontWeight: FontWeight.w700)),
        trailing: _saving
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _submit,
                child: const Text('Add',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary)),
              ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildCoverPicker(),
          const SizedBox(height: 28),

          const _Label('Title'),
          const SizedBox(height: 8),
          _CupertinoFormField(
            controller: _titleCtrl,
            placeholder: 'Book title',
            errorText: _titleError,
            onChanged: (_) {
              if (_titleError != null) setState(() => _titleError = null);
            },
          ),
          const SizedBox(height: 18),

          const _Label('Author'),
          const SizedBox(height: 8),
          _CupertinoFormField(
            controller: _authorCtrl,
            placeholder: 'Author name',
            errorText: _authorError,
            onChanged: (_) {
              if (_authorError != null) setState(() => _authorError = null);
            },
          ),
          const SizedBox(height: 18),

          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Label('Pages'),
                  const SizedBox(height: 8),
                  _CupertinoFormField(
                    controller: _pagesCtrl,
                    placeholder: '300',
                    keyboardType: TextInputType.number,
                    errorText: _pagesError,
                    onChanged: (_) {
                      if (_pagesError != null) {
                        setState(() => _pagesError = null);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Label('Genre'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showGenrePicker(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_genre,
                            style: const TextStyle(
                              color: AppTheme.textDark, fontSize: 15)),
                          const Icon(
                            CupertinoIcons.chevron_up_chevron_down,
                            size: 14, color: AppTheme.textMuted),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 24),

          const _Label('Status'),
          const SizedBox(height: 10),
          CupertinoSlidingSegmentedControl<ReadingStatus>(
            groupValue: _status,
            onValueChanged: (v) {
              if (v != null) setState(() => _status = v);
            },
            children: const {
              ReadingStatus.wantToRead: Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text('Want to\nread',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, height: 1.3)),
              ),
              ReadingStatus.reading: Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text('Reading', style: TextStyle(fontSize: 12)),
              ),
              ReadingStatus.finished: Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text('Finished', style: TextStyle(fontSize: 12)),
              ),
            },
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: CupertinoButton.filled(
              onPressed: _saving ? null : _submit,
              child: Text(_saving ? 'Saving…' : 'Add to library'),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Android ──────────────────────────────────────────────────

  Widget _buildMaterialScaffold(BuildContext context) {
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
            _buildCoverPicker(),
            const SizedBox(height: 28),

            const _Label('Title'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(hintText: 'Book title'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 18),

            const _Label('Author'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _authorCtrl,
              decoration: const InputDecoration(hintText: 'Author name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 18),

            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label('Pages'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _pagesCtrl,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(hintText: '300'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(v) == null) {
                          return 'Numbers only';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label('Genre'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _genre,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14)),
                      items: _genres
                          .map((g) => DropdownMenuItem(
                              value: g, child: Text(g)))
                          .toList(),
                      onChanged: (v) => setState(() => _genre = v!),
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 24),

            const _Label('Status'),
            const SizedBox(height: 10),
            ...ReadingStatus.values.map((s) => RadioListTile<ReadingStatus>(
              value: s,
              groupValue: _status,
              onChanged: (v) => setState(() => _status = v!),
              title: Text(_statusLabel(s),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
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
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.library_add_rounded),
                label: Text(_saving ? 'Saving…' : 'Add to library'),
                style:
                    ElevatedButton.styleFrom(backgroundColor: _color),
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

class _CupertinoFormField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final TextInputType? keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const _CupertinoFormField({
    required this.controller,
    required this.placeholder,
    this.keyboardType,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          keyboardType: keyboardType,
          onChanged: onChanged,
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.card,
            border: Border.all(
              color: errorText != null
                  ? CupertinoColors.destructiveRed
                  : AppTheme.border,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(errorText!,
              style: const TextStyle(
                color: CupertinoColors.destructiveRed, fontSize: 12)),
          ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppTheme.textMuted,
      letterSpacing: 0.5));
}
