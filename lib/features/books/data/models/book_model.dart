import '../../domain/entities/book.dart';

class BookModel {
  static Book fromJson(Map<String, dynamic> json) {
    return Book(
      id:              json['id'] as String,
      title:           json['title'] as String,
      author:          json['author'] as String,
      genre:           json['genre'] as String,
      coverEmoji:      json['coverEmoji'] as String,
      totalPages:      json['totalPages'] as int,
      currentPage:     json['currentPage'] as int? ?? 0,
      status:          ReadingStatusX.fromString(json['status'] as String? ?? ''),
      rating:          (json['rating'] as num?)?.toDouble() ?? 0.0,
      notes:           json['notes'] as String? ?? '',
      accentColorValue: json['accentColorValue'] as int,
    );
  }

  static Map<String, dynamic> toJson(Book book) {
    return {
      'id':              book.id,
      'title':           book.title,
      'author':          book.author,
      'genre':           book.genre,
      'coverEmoji':      book.coverEmoji,
      'totalPages':      book.totalPages,
      'currentPage':     book.currentPage,
      'status':          book.status.name,
      'rating':          book.rating,
      'notes':           book.notes,
      'accentColorValue': book.accentColorValue,
    };
  }
}
