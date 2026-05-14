enum ReadingStatus { reading, finished, wantToRead }

extension ReadingStatusX on ReadingStatus {
  String get label {
    switch (this) {
      case ReadingStatus.reading:    return 'Reading';
      case ReadingStatus.finished:   return 'Finished';
      case ReadingStatus.wantToRead: return 'Want to read';
    }
  }

  static ReadingStatus fromString(String s) {
    return ReadingStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => ReadingStatus.wantToRead,
    );
  }
}

class Book {
  final String id;
  final String title;
  final String author;
  final String genre;
  final String coverEmoji;
  final int totalPages;
  final int currentPage;
  final ReadingStatus status;
  final double rating;
  final String notes;
  final int accentColorValue;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.coverEmoji,
    required this.totalPages,
    this.currentPage = 0,
    this.status = ReadingStatus.wantToRead,
    this.rating = 0,
    this.notes = '',
    required this.accentColorValue,
  });

  double get progress =>
      totalPages > 0 ? (currentPage / totalPages).clamp(0.0, 1.0) : 0.0;

  Book copyWith({
    String? title,
    String? author,
    String? genre,
    String? coverEmoji,
    int? totalPages,
    int? currentPage,
    ReadingStatus? status,
    double? rating,
    String? notes,
    int? accentColorValue,
  }) {
    return Book(
      id: id,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      coverEmoji: coverEmoji ?? this.coverEmoji,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      accentColorValue: accentColorValue ?? this.accentColorValue,
    );
  }

  @override
  bool operator ==(Object other) => other is Book && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
